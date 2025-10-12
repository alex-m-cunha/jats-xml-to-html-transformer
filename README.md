# JATS XML → HTML Transformer (Beta)
Transforms JATS XML into OJS‑ready HTML using XSLT. Includes macOS and Windows launchers, plus scripts to package editor‑friendly ZIPs.

## Supported Platforms
- MacOS 13+ (Apple Silicon/Intel)
- Windows 10/11

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
- Generated files (stable structure):
  - output/index.html
  - output/assets/stylesheets/css.css
  - output/assets/stylesheets/javascript.js
  - output/assets/img/*                 (copied from article-img/)
  - output/assets/multimedia/<articleId>_PDF.pdf  (if input/pdf/<articleId>_PDF.pdf exists)

## Troubleshooting
If something goes wrong, check `transformation.log` inside the article folder.

### Java not found / app won’t open
- **Cause:** Missing or incompatible JRE.
- **Fix (macOS/Windows):** Use the packaged release, which includes its own JRE. If running from source, install Java 21+.

### No HTML produced
- **Check:** Open `transformation.log` and look for “Error” or “FATAL”.
- **Possible causes:** Invalid JATS XML, wrong path, or missing stylesheet.
- **Fix:** Verify your `input/<articleId>.xml` and that `transformation-template/` is intact.

### “Missing DTD” or resolver error
- **Fix:** Keep the `tools/` folder and resolver catalog unchanged. Don’t edit the DOCTYPE in the XML.

### macOS permissions
If macOS says “App can’t be opened”:
```bash
chmod +x scripts/run-mac.command
xattr -dr com.apple.quarantine scripts/run-mac.command
```
### Windows console closes instantly
- **Cause:** Running from a protected folder or an invalid path with spaces.
- **Fix:**
  1. Move the folder to a writable location, e.g. `C:\Users\<you>\Documents\Transformer\`.
  2. Open Command Prompt and run:
     ```bat
     cd path\to\transformer
     run-win.bat
     ```
  3. Read any messages shown in the terminal; if errors appear, check `transformation.log`.

## License

MIT License
Copyright (c) 2025 Only A Studio, Lda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Third‑party software and licenses
This package redistributes Saxon‑HE (MPL‑2.0), XML Resolver (Apache‑2.0), and, in editor builds, an OpenJDK runtime (GPLv2 + Classpath Exception). See THIRD-PARTY-NOTICES.md for details and redistribution requirements.