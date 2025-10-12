#!/bin/bash
# macOS one-click JATS → HTML (per-article)

# Editors: double-click → picker. Devs: --xml, --out, --verbose.
  # scripts/run-mac.command --xml "/path/to/articles/.../input/123_XML.xml" --verbose

# Custom Output Location
 #  scripts/run-mac.command --xml "/path/to/.../input/123_XML.xml" --out "/tmp/test-run/index.html" -v

# Convert Multiple Articles — find articles -type f -path "*/input/*_XML.xml" -print0 | while IFS= read -r -d '' xml; do
  # scripts/run-mac.command --xml "$xml" --verbose
  # done

# CI or automated smoke tests on macOS runners

set -u  # keep undefined-var safety; avoid -e to prevent silent aborts
OSASCRIPT="/usr/bin/osascript"

# Early bootstrap log
BOOTLOG="/tmp/jats-run-mac.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [info] launcher started" >> "$BOOTLOG"

# Version/meta
VERSION="${TRANSFORMER_VERSION:-$(cd "$(dirname "$0")/.." && git describe --tags --always 2>/dev/null || echo 'local')}"
BUILD_STAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# CLI flags
XML_OVERRIDE=""
OUT_OVERRIDE=""
VERBOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --xml)        XML_OVERRIDE="${2:-}"; shift 2 ;;
    --out)        OUT_OVERRIDE="${2:-}"; shift 2 ;;
    --verbose|-v) VERBOSE=1; shift ;;
    --help|-h)    echo "Usage: $(basename "$0") [--xml file] [--out path|dir] [--verbose]"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done

# Tools and templates
SAXON_JAR="$(ls "$REPO_ROOT"/tools/saxon-he-*.jar "$REPO_ROOT"/tools/Saxon-HE-*.jar 2>/dev/null | head -n1 || true)"
RESOLVER_JAR="$(ls "$REPO_ROOT"/tools/xmlresolver-*.jar 2>/dev/null | grep -v 'data' | head -n1 || true)"
RESOLVER_DATA_JAR="$(ls "$REPO_ROOT"/tools/xmlresolver-*-data.jar 2>/dev/null | head -n1 || true)"
MAIN_XSL="$REPO_ROOT/transformation-template/xslt/main.xsl"
ASSETS_SRC="$REPO_ROOT/transformation-template/assets"

# Logging helpers
LOG=""
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log_line() {
  local level="$1"; shift
  local line="[$(ts)] [$level] $*"
  [[ -n "$LOG" ]] && printf '%s\n' "$line" >> "$LOG"
  [[ $VERBOSE -eq 1 ]] && printf '%s\n' "$line" >&2
}
info()  { log_line info  "$*"; }
warn()  { log_line warn  "$*"; }
error() { log_line error "$*"; }

# 1) File picker (always first)
XML_PATH=""
if [[ -n "$XML_OVERRIDE" ]]; then
  XML_PATH="$XML_OVERRIDE"
else
  XML_PATH="$($OSASCRIPT -e 'try
    set f to choose file with prompt "Pick the article XML (…/input/<article>.xml)"
    POSIX path of f
  on error number -128
    return "" -- user canceled
  end try' 2>/dev/null || true)"
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [info] picker result: ${XML_PATH:-<empty>}" >> "$BOOTLOG"

if [[ -z "${XML_PATH:-}" ]]; then
  $OSASCRIPT -e 'display alert "Canceled" message "No file selected — nothing was changed."' || true
  exit 0
fi
XML_PATH="${XML_PATH//$'\r'/}"; XML_PATH="${XML_PATH//$'\n'/}"
if [[ ! -f "$XML_PATH" ]]; then
  $OSASCRIPT -e 'display alert "Selected XML not found" message "Please pick a valid JATS XML file." as critical' || true
  exit 1
fi
ext_lc="$(printf '%s' "${XML_PATH##*.}" | tr '[:upper:]' '[:lower:]')"
if [[ "$ext_lc" != "xml" ]]; then
  $OSASCRIPT -e 'display alert "Not an XML file" message "Please select a .xml JATS file." as critical' || true
  exit 1
fi

# 2) Per-article paths and log
XML_DIR="$(cd "$(dirname "$XML_PATH")" && pwd)"
AID="$(basename "$XML_PATH")"; AID="${AID%.xml}"
BASE_ID="${AID%_XML}"
ARTICLE_DIR="$(dirname "$XML_DIR")"

LOG="$ARTICLE_DIR/transformation.log"
if [[ -f "$LOG" ]]; then
  mv -f "$LOG" "$ARTICLE_DIR/transformation.prev.log" 2>/dev/null || cp -f "$LOG" "$ARTICLE_DIR/transformation.prev.log"
fi
: > "$LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [info] created per-article log: $LOG" >> "$BOOTLOG"
info "Start build $BUILD_STAMP | version=$VERSION"
info "XML: $XML_PATH"

# 3) Java detection (after picker/log so we can always alert)
arch="$(uname -m)"
JAVA_BIN=""
case "$arch" in
  arm64)
    for j in "$REPO_ROOT/jre/macos-arm64/bin/java" "$REPO_ROOT/jre/bin/java"; do [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }; done ;;
  x86_64|amd64)
    for j in "$REPO_ROOT/jre/macos-x64/bin/java" "$REPO_ROOT/jre/bin/java"; do [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }; done ;;
  *) for j in "$REPO_ROOT/jre/macos-x64/bin/java" "$REPO_ROOT/jre/bin/java"; do [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }; done ;;
esac
[[ -z "$JAVA_BIN" && -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]] && JAVA_BIN="$JAVA_HOME/bin/java"
[[ -z "$JAVA_BIN" ]] && JAVA_BIN="$(command -v java 2>/dev/null || true)"
if [[ -z "$JAVA_BIN" || ! -x "$JAVA_BIN" ]]; then
  error "Java not found"
  $OSASCRIPT -e 'display alert "Java not found" message "Bundle a JRE in jre/macos-[arm64|x64] or set JAVA_HOME." as critical' || true
  exit 1
fi
info "Java: $JAVA_BIN"

# 4) Validate essentials
if [[ -z "$SAXON_JAR" || ! -f "$SAXON_JAR" ]]; then
  error "Missing Saxon jar"
  $OSASCRIPT -e 'display alert "Missing Saxon" message "Put Saxon-HE jar in tools/ (e.g., saxon-he-12.x.jar)" as critical' || true
  exit 1
fi
if [[ ! -f "$MAIN_XSL" ]]; then
  error "Missing main.xsl"
  $OSASCRIPT -e 'display alert "Missing main.xsl" message "Check transformation-template/xslt/main.xsl" as critical' || true
  exit 1
fi
info "Saxon: $(basename "$SAXON_JAR")"
[[ -n "${RESOLVER_JAR:-}" && -f "$RESOLVER_JAR" ]] && info "Resolver: $(basename "$RESOLVER_JAR")"
[[ -n "${RESOLVER_DATA_JAR:-}" && -f "$RESOLVER_DATA_JAR" ]] && info "Resolver data: $(basename "$RESOLVER_DATA_JAR")"

# 5) Output targets
DEFAULT_OUT_DIR="$(dirname "$XML_DIR")/output"
OUT_DIR="$DEFAULT_OUT_DIR"
OUT_HTML="$DEFAULT_OUT_DIR/index.html"
if [[ -n "$OUT_OVERRIDE" ]]; then
  if [[ "$OUT_OVERRIDE" == */ || -d "$OUT_OVERRIDE" ]]; then
    OUT_DIR="${OUT_OVERRIDE%/}"
    OUT_HTML="$OUT_DIR/index.html"
  else
    OUT_DIR="$(dirname "$OUT_OVERRIDE")"
    OUT_HTML="$OUT_OVERRIDE"
  fi
fi
mkdir -p "$OUT_DIR" || { error "Cannot create output folder: $OUT_DIR"; $OSASCRIPT -e "display alert \"Cannot create output folder\" message \"$OUT_DIR\" as critical" || true; exit 1; }
info "OUT dir: $OUT_DIR"
info "OUT file: $OUT_HTML"

# 6) Build Saxon command
ARTICLE_IMG_SUB="article-img"
ARTICLE_IMG_ROOT="assets/img/"
JAVA_HEAP="256m"

PDF_DIR="$XML_DIR/pdf"
PDF_SUFFIX="_PDF.pdf"
PDF_PARAM=""
PDF_FILE="$PDF_DIR/${BASE_ID}${PDF_SUFFIX}"
if [[ -f "$PDF_FILE" ]]; then
  PDF_PARAM="pdf-href=assets/multimedia/${BASE_ID}${PDF_SUFFIX}"
  info "PDF: $PDF_FILE"
else
  info "No PDF for $BASE_ID"
fi

CLASSPATH="$SAXON_JAR"
[[ -n "${RESOLVER_JAR:-}" && -f "$RESOLVER_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_JAR"
[[ -n "${RESOLVER_DATA_JAR:-}" && -f "$RESOLVER_DATA_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_DATA_JAR"
info "CP: $CLASSPATH"

TMP_HTML="$(mktemp -t jatshtmlXXXX).html"
CATALOG_FILE="$REPO_ROOT/transformation-template/dtd/catalog.xml"
CATALOG_ARG=""
[[ -f "$CATALOG_FILE" ]] && { CATALOG_ARG="-catalog:$CATALOG_FILE"; info "Catalog: $CATALOG_FILE"; } || warn "No catalog.xml found; resolving DTD relative to XML"

# Log exact command
CMD_DESC="\"$JAVA_BIN\" -Xmx$JAVA_HEAP -cp \"$CLASSPATH\" net.sf.saxon.Transform -t -s:\"$XML_PATH\" -xsl:\"$MAIN_XSL\" -o:\"$TMP_HTML\" assets-path=assets/ article-img=$ARTICLE_IMG_ROOT"
[[ -n "$PDF_PARAM" ]] && CMD_DESC="$CMD_DESC $PDF_PARAM"
[[ -n "$CATALOG_ARG" ]] && CMD_DESC="$CMD_DESC $CATALOG_ARG"
info "Exec: $CMD_DESC"

# 7) Run transform
set +o pipefail
if [[ -n "$PDF_PARAM" && -n "$CATALOG_ARG" ]]; then
  "$JAVA_BIN" -Xmx"$JAVA_HEAP" -cp "$CLASSPATH" net.sf.saxon.Transform -t \
    -s:"$XML_PATH" -xsl:"$MAIN_XSL" -o:"$TMP_HTML" \
    assets-path=assets/ "article-img=$ARTICLE_IMG_ROOT" "$PDF_PARAM" "$CATALOG_ARG" >> "$LOG" 2>&1
elif [[ -n "$PDF_PARAM" ]]; then
  "$JAVA_BIN" -Xmx"$JAVA_HEAP" -cp "$CLASSPATH" net.sf.saxon.Transform -t \
    -s:"$XML_PATH" -xsl:"$MAIN_XSL" -o:"$TMP_HTML" \
    assets-path=assets/ "article-img=$ARTICLE_IMG_ROOT" "$PDF_PARAM" >> "$LOG" 2>&1
elif [[ -n "$CATALOG_ARG" ]]; then
  "$JAVA_BIN" -Xmx"$JAVA_HEAP" -cp "$CLASSPATH" net.sf.saxon.Transform -t \
    -s:"$XML_PATH" -xsl:"$MAIN_XSL" -o:"$TMP_HTML" \
    assets-path=assets/ "article-img=$ARTICLE_IMG_ROOT" "$CATALOG_ARG" >> "$LOG" 2>&1
else
  "$JAVA_BIN" -Xmx"$JAVA_HEAP" -cp "$CLASSPATH" net.sf.saxon.Transform -t \
    -s:"$XML_PATH" -xsl:"$MAIN_XSL" -o:"$TMP_HTML" \
    assets-path=assets/ "article-img=$ARTICLE_IMG_ROOT" >> "$LOG" 2>&1
fi
status=$?
set -o pipefail
info "Saxon exit: $status"

if [[ $status -ne 0 || ! -s "$TMP_HTML" ]]; then
  error "Transform failed or empty: $TMP_HTML"
  tail -n 100 "$LOG" > "$ARTICLE_DIR/transformation-error.txt" 2>/dev/null || true
  $OSASCRIPT -e 'display alert "Transform failed" message "Check transformation.log (next to the article folder)" as critical' || true
  exit 1
fi

# 8) Write output and tag
mv -f "$TMP_HTML" "$OUT_HTML"
{ printf '<!-- Built by JATS → HTML | version=%s | arch=%s | saxon=%s | %s UTC -->\n' "$VERSION" "$(uname -m)" "$(basename "$SAXON_JAR")" "$BUILD_STAMP"; cat "$OUT_HTML"; } > "${OUT_HTML}.tagged" && mv -f "${OUT_HTML}.tagged" "$OUT_HTML"

# 9) Copy assets
RSYNC_OK_CODES="0 24"
if [[ -d "$ASSETS_SRC" ]]; then
  mkdir -p "$OUT_DIR/assets"
  info "Copy assets (excluding fonts/ and img/)"
  rsync -a --exclude 'fonts/' --exclude 'img/' "$ASSETS_SRC"/ "$OUT_DIR/assets/" >> "$LOG" 2>&1 || true
fi
if [[ -d "$XML_DIR/article-img" ]]; then
  mkdir -p "$OUT_DIR/assets/img"
  info "Copy per-article images"
  rsync -a "$XML_DIR/article-img"/ "$OUT_DIR/assets/img/" >> "$LOG" 2>&1 || true
fi
if [[ -d "$XML_DIR/pdf" ]]; then
  mkdir -p "$OUT_DIR/assets/multimedia"
  info "Copy per-article PDFs"
  rsync -a "$XML_DIR/pdf/" "$OUT_DIR/assets/multimedia/" >> "$LOG" 2>&1 || true
fi

# 10) Bundle CSS/JS
ASSETS_DIR="$OUT_DIR/assets"
STYLE_DIR="$ASSETS_DIR/stylesheets"
mkdir -p "$STYLE_DIR"
for d in css js; do
  if [[ -d "$ASSETS_DIR/$d" ]]; then
    info "Flatten $d → stylesheets/"
    shopt -s dotglob nullglob
    mv "$ASSETS_DIR/$d/"* "$STYLE_DIR/" 2>/dev/null || true
    shopt -u dotglob nullglob
    rmdir "$ASSETS_DIR/$d" 2>/dev/null || rm -rf "$ASSETS_DIR/$d"
  fi
done

CSS_BUNDLE="$STYLE_DIR/css.css"; : > "$CSS_BUNDLE"
while IFS= read -r -d '' css; do
  [[ "$css" == "$CSS_BUNDLE" ]] && continue
  info "Merge CSS: ${css##*/}"
  { printf '/* %s */\n' "${css##*/}"; cat "$css"; printf '\n\n'; } >> "$CSS_BUNDLE"
done < <(find "$STYLE_DIR" -maxdepth 1 -type f -name '*.css' -print0)
find "$STYLE_DIR" -maxdepth 1 -type f -name '*.css' ! -name 'css.css' -delete

JS_BUNDLE="$STYLE_DIR/javascript.js"; : > "$JS_BUNDLE"
while IFS= read -r -d '' js; do
  [[ "$js" == "$JS_BUNDLE" ]] && continue
  info "Merge JS: ${js##*/}"
  { printf '/* %s */\n' "${js##*/}"; cat "$js"; printf '\n\n'; } >> "$JS_BUNDLE"
done < <(find "$STYLE_DIR" -maxdepth 1 -type f -name '*.js' -print0)
find "$STYLE_DIR" -maxdepth 1 -type f -name '*.js' ! -name 'javascript.js' -delete

# Done
if [[ ! -s "$OUT_HTML" ]]; then
  error "No HTML produced at $OUT_HTML"
  $OSASCRIPT -e 'display alert "No HTML produced" message "Check transformation.log for details" as critical' || true
  exit 1
fi
info "Done: $OUT_HTML"
$OSASCRIPT -e 'display notification "Built index.html and copied assets" with title "JATS → HTML ready"' || true
open "$OUT_HTML" >/dev/null 2>&1 || true
