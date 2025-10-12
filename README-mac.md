# JATS → HTML (macOS)

## Quick start

1) Unzip the package.  
2) Double‑click `scripts/run-mac.command` (if blocked: right‑click → Open → Open).  
3) Pick `…/articles/<volume>/<article>/input/<articleId>.xml`.  
4) Output: `…/articles/<volume>/<article>/output/` (index.html + assets).

## Requirements

- macOS
- Bundled JRE (included). If removed, install Java 17.

## Folder structure
```
<article>/
  input/
    <articleId>.xml
    pdf/
      <articleId>_PDF.pdf  (optional)
  article-img/
    <images referenced by XML>
  output/  (generated)
```

## Conventions

- PDF name must be `<articleId>_PDF.pdf`.
- Images: filenames must match `@xlink:href` in the XML.
- One folder per article.
- CSS/JS are bundled into `assets/stylesheets/css.css` and `assets/stylesheets/javascript.js`.

## Upload to OJS

- Zip the `output/` folder and upload as an HTML galley.  
- OJS will register and rewrite asset links to `/article/download/...`.

## Unblocking the script

- If Gatekeeper blocks it: right‑click `scripts/run-mac.command` → Open → Open.  
- Or run once in Terminal:
  ```
  xattr -d com.apple.quarantine "scripts/run-mac.command"
  ```

## Troubleshooting

- No PDF link: ensure `input/pdf/<articleId>_PDF.pdf` exists.  
- Missing images: ensure files are in `article-img/` and match XML references.  
- Java not found: keep `jre/macos-[arm64|x64]/` in place or install Java 17.- If blocked: chmod +x scripts/run-mac.command; xattr -dr com.apple.quarantine scripts/run-mac.command
- Logs: transformation.log next to the article folder; bootstrap: /tmp/jats-run-mac.log

# macOS Guide

- Double‑click scripts/run-mac.command
- Pick input/<articleId>.xml
- Output: output/index.html opens automatically
