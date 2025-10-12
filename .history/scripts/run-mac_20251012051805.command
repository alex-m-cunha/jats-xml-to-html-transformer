#!/bin/bash
# macOS one-click JATS → HTML (per-article)
# - prompts for XML
# - runs Saxon-HE
# - copies assets and per-article images
# - bundles CSS/JS
# - opens output
set -euo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LOG="$REPO_ROOT/transform-one.log"
: > "$LOG"
echo "[info] Start $(date)" >> "$LOG"

# Pick bundled JRE by arch; fallback to JAVA_HOME or system Java
arch="$(uname -m)"
JAVA_BIN=""
case "$arch" in
  arm64)
    for j in "$REPO_ROOT/jre/macos-arm64/bin/java" "$REPO_ROOT/jre/bin/java"; do
      [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }
    done
    ;;
  x86_64|amd64)
    for j in "$REPO_ROOT/jre/macos-x64/bin/java" "$REPO_ROOT/jre/bin/java"; do
      [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }
    done
    ;;
  *)
    for j in "$REPO_ROOT/jre/macos-x64/bin/java" "$REPO_ROOT/jre/bin/java"; do
      [[ -x "$j" ]] && { JAVA_BIN="$j"; break; }
    done
    ;;
esac
if [[ -z "${JAVA_BIN}" || ! -x "$JAVA_BIN" ]]; then
  [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]] && JAVA_BIN="$JAVA_HOME/bin/java"
fi
if [[ -z "${JAVA_BIN}" || ! -x "$JAVA_BIN" ]]; then
  JAVA_BIN="$(command -v java || true)"
fi
[[ -x "$JAVA_BIN" ]] || { osascript -e 'display alert "Java not found" message "Bundle a JRE in jre/macos-[arm64|x64] at repo root or set JAVA_HOME."' as critical; exit 1; }

# Tools and templates (resolved from repo root)
# Auto-detect Saxon/Resolver jars (any 12.x/5.x)
SAXON_JAR="$(ls "$REPO_ROOT"/tools/saxon-he-*.jar "$REPO_ROOT"/tools/Saxon-HE-*.jar 2>/dev/null | head -n1 || true)"
RESOLVER_JAR="$(ls "$REPO_ROOT"/tools/xmlresolver-*.jar 2>/dev/null | grep -v 'data' | head -n1 || true)"
RESOLVER_DATA_JAR="$(ls "$REPO_ROOT"/tools/xmlresolver-*-data.jar 2>/dev/null | head -n1 || true)"

MAIN_XSL="$REPO_ROOT/transformation-template/xslt/main.xsl"
ASSETS_SRC="$REPO_ROOT/transformation-template/assets"

# Per-article inputs/outputs
ARTICLE_IMG_SUB="article-img"      # change to 'input-img' if that’s your source folder
ARTICLE_IMG_ROOT="assets/img/"     # where images live in the output package
JAVA_HEAP="256m"

# Checks
[[ -f "$MAIN_XSL" ]] || { osascript -e 'display alert "Missing main.xsl" message "Check transformation-template/xslt/main.xsl"' as critical; exit 1; }
if [[ -z "$SAXON_JAR" || ! -f "$SAXON_JAR" ]]; then
  osascript -e 'display alert "Missing Saxon" message "Put Saxon-HE jar in tools/ (e.g., saxon-he-12.x.jar)"' as critical
  exit 1
fi

# Pick XML
XML_PATH="$(osascript -e 'set f to choose file with prompt "Pick the article XML (…/input/<article>.xml)" of type {"public.xml"}' -e 'POSIX path of f' 2>/dev/null || true)"
[[ -n "$XML_PATH" ]] || exit 0
XML_PATH="${XML_PATH//$'\r'/}"; XML_PATH="${XML_PATH//$'\n'/}"
[[ -f "$XML_PATH" ]] || { osascript -e 'display alert "Selected file not found"'; exit 1; }

XML_DIR="$(cd "$(dirname "$XML_PATH")" && pwd)"
AID="$(basename "$XML_PATH")"; AID="${AID%.xml}"
OUT_DIR="$(dirname "$XML_DIR")/output"
OUT_HTML="$OUT_DIR/index.html"
PDF_DIR="$XML_DIR/pdf"
PDF_SUFFIX="_PDF.pdf"

echo "[info] XML: $XML_PATH" >> "$LOG"
echo "[info] OUT: $OUT_HTML" >> "$LOG"

# Optional PDF param (relative to output assets)
PDF_ARG=()
PDF_FILE="$PDF_DIR/${BASE_ID}${PDF_SUFFIX}"
if [[ -f "$PDF_FILE" ]]; then
  PDF_ARG=("pdf-href=assets/multimedia/${BASE_ID}${PDF_SUFFIX}")
  echo "[info] PDF: $PDF_FILE" >> "$LOG"
else
  echo "[info] No PDF for $AID" >> "$LOG"
fi

# Classpath (mac uses ':')
CLASSPATH="$SAXON_JAR"
[[ -n "$RESOLVER_JAR" && -f "$RESOLVER_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_JAR"
[[ -n "$RESOLVER_DATA_JAR" && -f "$RESOLVER_DATA_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_DATA_JAR"
echo "[info] CP : $CLASSPATH" >> "$LOG"

# Transform to temp
TMP_HTML="$(mktemp -t jatshtmlXXXX).html"
set +e
TRANSFORM_ARGS=(
  -t
  "-s:$XML_PATH"
  "-xsl:$MAIN_XSL"
  "-o:$TMP_HTML"
  "assets-path=assets/"
  "article-img=$ARTICLE_IMG_ROOT"
)
if [[ ${#PDF_ARG[@]} -gt 0 ]]; then
  TRANSFORM_ARGS+=("${PDF_ARG[@]}")
fi

CATALOG_FILE="$REPO_ROOT/transformation-template/dtd/catalog.xml"
if [[ -f "$CATALOG_FILE" ]]; then
  TRANSFORM_ARGS+=("-catalog:$CATALOG_FILE")
  echo "[info] Catalog: $CATALOG_FILE" >> "$LOG"
else
  echo "[warn] No catalog.xml found; resolving DTD relative to XML" >> "$LOG"
fi

"$JAVA_BIN" -Xmx"$JAVA_HEAP" -cp "$CLASSPATH" net.sf.saxon.Transform \
  "${TRANSFORM_ARGS[@]}" >> "$LOG" 2>&1
status=$?
set -e
echo "[info] Saxon exit: $status" >> "$LOG"

if [[ $status -ne 0 || ! -s "$TMP_HTML" ]]; then
  tail -n 150 "$LOG" > "$REPO_ROOT/transform-one-error.txt" || true
  osascript -e 'display alert "Transform failed" message "See transform-one.log / transform-one-error.txt"' || true
  exit 1
fi

# Write output
mkdir -p "$OUT_DIR"
mv -f "$TMP_HTML" "$OUT_HTML"

# Copy base assets (exclude fonts/ and img/; images handled per article)
if [[ -d "$ASSETS_SRC" ]]; then
  mkdir -p "$OUT_DIR/assets"
  rsync -a --exclude 'fonts/' --exclude 'img/' "$ASSETS_SRC"/ "$OUT_DIR/assets/"
fi

# Copy per-article images
if [[ -d "$XML_DIR/$ARTICLE_IMG_SUB" ]]; then
  mkdir -p "$OUT_DIR/assets/img"
  rsync -a "$XML_DIR/$ARTICLE_IMG_SUB"/ "$OUT_DIR/assets/img/"
fi

# Copy per-article PDFs
if [[ -d "$XML_DIR/pdf" ]]; then
  mkdir -p "$OUT_DIR/assets/multimedia"
  rsync -a "$XML_DIR/pdf/" "$OUT_DIR/assets/multimedia/"
fi

# Bundle CSS/JS into assets/stylesheets
ASSETS_DIR="$OUT_DIR/assets"
for d in css js; do
  if [[ -d "$ASSETS_DIR/$d" ]]; then
    mkdir -p "$ASSETS_DIR/stylesheets"
    shopt -s dotglob nullglob
    mv "$ASSETS_DIR/$d/"* "$ASSETS_DIR/stylesheets/" 2>/dev/null || true
    shopt -u dotglob nullglob
    rmdir "$ASSETS_DIR/$d" 2>/dev/null || rm -rf "$ASSETS_DIR/$d"
  fi
done

STYLE_DIR="$ASSETS_DIR/stylesheets"
if [[ -d "$STYLE_DIR" ]]; then
  CSS_BUNDLE="$STYLE_DIR/css.css"
  : > "$CSS_BUNDLE"
  while IFS= read -r -d '' css; do
    [[ "$css" == "$CSS_BUNDLE" ]] && continue
    printf '/* %s */\n' "${css##*/}" >> "$CSS_BUNDLE"
    cat "$css" >> "$CSS_BUNDLE"
    printf '\n\n' >> "$CSS_BUNDLE"
  done < <(find "$STYLE_DIR" -maxdepth 1 -type f -name '*.css' -print0)
  find "$STYLE_DIR" -maxdepth 1 -type f -name '*.css' ! -name 'css.css' -delete

  JS_BUNDLE="$STYLE_DIR/javascript.js"
  : > "$JS_BUNDLE"
  while IFS= read -r -d '' js; do
    [[ "$js" == "$JS_BUNDLE" ]] && continue
    printf '/* %s */\n' "${js##*/}" >> "$JS_BUNDLE"
    cat "$js" >> "$JS_BUNDLE"
    printf '\n\n' >> "$JS_BUNDLE"
  done < <(find "$STYLE_DIR" -maxdepth 1 -type f -name '*.js' -print0)
  find "$STYLE_DIR" -maxdepth 1 -type f -name '*.js' ! -name 'javascript.js' -delete
fi

[[ -f "$OUT_HTML" ]] || { osascript -e 'display alert "No HTML produced" message "Check transform-one.log for details"' || true; exit 1; }

echo "[info] Done: $OUT_HTML" >> "$LOG"
osascript -e 'display notification "Built index.html and copied assets" with title "JATS → HTML ready"'
open "$OUT_HTML" >/dev/null 2>&1 || true
