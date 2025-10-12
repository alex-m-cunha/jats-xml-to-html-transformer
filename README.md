# JATS XML → HTML Transformer
Transforms JATS XML into OJS‑ready HTML using XSLT. Includes macOS and Windows launchers, plus scripts to package editor‑friendly ZIPs.

## Repo Structure
<img width="310" height="442" alt="Screenshot 2025-10-12 at 15 49 57" src="https://github.com/user-attachments/assets/bd130a94-073d-4aa8-bba5-c3f2c8ecea20" />

## Example Transformation

### JATS XML input
<img width="1181" height="678" alt="Screenshot 2025-10-12 at 15 48 42" src="https://github.com/user-attachments/assets/39249ccb-2eff-4afa-8c52-4aa250ea25e0" />

### HTML output
<img width="1728" height="967" alt="Screenshot 2025-10-12 at 15 46 41" src="https://github.com/user-attachments/assets/52cc3cca-261d-4ec4-9400-a201dca72119" />


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
