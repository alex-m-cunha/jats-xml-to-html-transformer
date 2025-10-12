# JATS → HTML (Windows)

## Quick start

1) Unzip the package.  
2) Double‑click `scripts/run-win.bat` (this launches `run-win.ps1`).  
3) Pick `...\articles\<volume>\<article>\input\<articleId>.xml`.  
4) Output: `...\articles\<volume>\<article>\output\` (index.html + assets).

## Requirements

- Windows 10/11
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

## Upload to OJS

- Zip the `output\` folder and upload as an HTML galley.  
- OJS will rewrite registered asset links to `/article/download/...`.

## Unblocking scripts

- SmartScreen: click “More info → Run anyway”.  
- Or right‑click the ZIP/script → Properties → Unblock.  
- PowerShell policy is handled by the `.bat` launcher (ExecutionPolicy Bypass).

## Troubleshooting

- No PDF link: ensure `input\pdf\<articleId>_PDF.pdf` exists.  
- Missing images: ensure files are in `article-img\` and match XML references.  
- Java not found: keep `jre\win-x64\` in place or install Java 17 system‑wide.