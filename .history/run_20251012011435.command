#!/bin/bash
# macOS one-click JATS → HTML (per-article)
# - prompts for XML
# - runs Saxon-HE
# - copies assets and per-article images
# - opens output
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

LOG="$ROOT/transform-one.log"
: > "$LOG"
echo "[info] Start $(date)" >> "$LOG"

JAVA_BIN="$ROOT/jre/bin/java"
SAXON_JAR="$ROOT/tools/saxon-he-12.9.jar"
RESOLVER_JAR="$ROOT/tools/xmlresolver-5.3.3.jar"
RESOLVER_DATA_JAR="$ROOT/tools/xmlresolver-5.3.3-data.jar"
MAIN_XSL="$ROOT/transformation-template/xslt/main.xsl"
ASSETS_SRC="$ROOT/transformation-template/assets"
ARTICLE_IMG_SUB="article-img"
ARTICLE_IMG_ROOT="assets/img/"
JAVA_HEAP="256m"

# Checks
for p in "$JAVA_BIN" "$SAXON_JAR" "$MAIN_XSL"; do
  if [[ ! -e "$p" ]]; then
    echo "[error] Missing $p" >> "$LOG"
  fi
done
[[ -x "$JAVA_BIN" ]] || { osascript -e 'display alert "Missing Java" message "Put JRE in jre/." as critical'; exit 1; }
[[ -f "$SAXON_JAR" ]] || { osascript -e 'display alert "Missing Saxon" message "Put saxon-he-12.9.jar in tools/." as critical'; exit 1; }
[[ -f "$MAIN_XSL" ]] || { osascript -e 'display alert "Missing main.xsl" message "Check transformation-template/xslt/main.xsl" as critical'; exit 1; }

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
PDF_SUFFIX=".pdf"

echo "[info] XML: $XML_PATH" >> "$LOG"
echo "[info] OUT: $OUT_HTML" >> "$LOG"

# Optional PDF
PDF_ARG=()
PDF_FILE="$PDF_DIR/${AID}${PDF_SUFFIX}"
if [[ -f "$PDF_FILE" ]]; then
  PDF_ARG=("pdf-href=assets/multimedia/${AID}${PDF_SUFFIX}")
  echo "[info] PDF: $PDF_FILE" >> "$LOG"
else
  echo "[info] No PDF for $AID" >> "$LOG"
fi

# Classpath (mac uses ':')
CLASSPATH="$SAXON_JAR"
[[ -f "$RESOLVER_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_JAR"
[[ -f "$RESOLVER_DATA_JAR" ]] && CLASSPATH="$CLASSPATH:$RESOLVER_DATA_JAR"
echo "[info] CP : $CLASSPATH" >> "$LOG"

# Run Saxon to temp first
TMP_HTML="$(mktemp -t jatshtmlXXXX).html"
set +e
TRANSFORM_ARGS=(
  -t
  "-s:$XML_PATH"
  "-xsl:$MAIN_XSL"
  "-o:$TMP_HTML"
  #"assets-path=${ASSETS_SRC%/}/"
  "assets-path=assets/"
  "article-img=$ARTICLE_IMG_ROOT"
)

if [[ ${#PDF_ARG[@]} -gt 0 ]]; then
  TRANSFORM_ARGS+=("${PDF_ARG[@]}")
fi

CATALOG_FILE="$ROOT/transformation-template/dtd/catalog.xml"
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
  tail -n 100 "$LOG" > "$ROOT/transform-one-error.txt" || true
  osascript -e 'display alert "Transform failed" message "See transform-one.log / transform-one-error.txt"' || true
  exit 1
fi

mkdir -p "$OUT_DIR"
mv -f "$TMP_HTML" "$OUT_HTML"

# Copy assets
if [[ -d "$ASSETS_SRC" ]]; then
  mkdir -p "$OUT_DIR/assets"
  rsync -a --exclude 'fonts/' "$ASSETS_SRC"/ "$OUT_DIR/assets/"
fi

# Copy per-article images into assets/img
if [[ -d "$XML_DIR/$ARTICLE_IMG_SUB" ]]; then
  mkdir -p "$OUT_DIR/assets/img"
  rsync -a "$XML_DIR/$ARTICLE_IMG_SUB"/ "$OUT_DIR/assets/img/"
fi

# Copy per-article PDFs into assets/multimedia
if [[ -d "$XML_DIR/pdf" ]]; then
  mkdir -p "$OUT_DIR/assets/multimedia"
  rsync -a "$XML_DIR/pdf/" "$OUT_DIR/assets/multimedia/"
fi

# --- Normalize asset structure after copy ---
ASSETS_DIR="$OUT_DIR/assets"

# css/js -> stylesheets (move contents)
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

if [[ ! -f "$OUT_HTML" ]]; then
  osascript -e 'display alert "No HTML produced" message "Check transform-one.log for details"' || true
  exit 1
fi

echo "[info] Done: $OUT_HTML" >> "$LOG"
osascript -e 'display notification "Built index.html and copied assets" with title "JATS → HTML ready"'
open "$OUT_HTML" >/dev/null 2>&1 || true
