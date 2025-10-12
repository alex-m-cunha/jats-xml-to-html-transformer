# JATS XML → HTML Transformer

Transforms JATS XML into OJS‑ready HTML using XSLT. Includes macOS and Windows launchers, plus scripts to package editor‑friendly ZIPs.

## Downloads (for editors)
Get prebuilt packages from Releases:
- https://github.com/alex-m-cunha/jats-xml-to-html-transformer/releases

Use the OS guide:
- macOS: see README-mac.md
- Windows: see README-windows.md

## Repo layout
- transformation-template/ … XSLT and assets
- scripts/ … launchers (run-mac.command, run-win.bat/.ps1)
- tools/ … Saxon/XML Resolver jars (fetched or bundled in Releases)
- jre/ … per‑OS JREs (bundled only in Release ZIPs)

## Input structure (per article)
```
<article>/
  input/
    <articleId>.xml
    pdf/
      <articleId>_PDF.pdf  (optional)
  article-img/
  output/  (generated)
```

## Notes
- The repo excludes heavy binaries (jre/, jars, output/, dist/). Packages for editors are attached to Releases.
- CSS/JS are bundled into assets/stylesheets/css.css and assets/stylesheets/javascript.js.