# Windows one‑click JATS → HTML (per‑article)
# - prompts for XML
# - runs Saxon-HE
# - copies assets and per-article images
# - bundles CSS/JS
# - opens output

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms | Out-Null

$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Java    = Join-Path $Root 'jre\bin\java.exe'
$Saxon   = Join-Path $Root 'tools\saxon-he-12.9.jar'
$Resolv  = Join-Path $Root 'tools\xmlresolver-5.3.3.jar'
$ResData = Join-Path $Root 'tools\xmlresolver-5.3.3-data.jar'
$MainXsl = Join-Path $Root 'transformation-template\xslt\main.xsl'
$AssetsSrc = Join-Path $Root 'transformation-template\assets'
$ArticleImgSub = 'article-img'   # keep in sync with mac script
$ArticleImgRoot = 'assets/img/'
$PdfSuffix = '_PDF.pdf'
$Heap = '256m'

foreach ($p in @($Java,$Saxon,$MainXsl)) {
  if (-not (Test-Path $p)) { [System.Windows.Forms.MessageBox]::Show("Missing: `n$($p)","Missing dependency",'OK','Error') ; exit 1 }
}

# Pick XML
$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Title = 'Pick the article XML (…\input\<article>.xml)'
$dlg.Filter = 'XML Files (*.xml)|*.xml'
if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
$XmlPath = $dlg.FileName
if (-not (Test-Path $XmlPath)) { [System.Windows.Forms.MessageBox]::Show("Selected file not found","Error",'OK','Error'); exit 1 }

$XmlDir  = Split-Path -Parent $XmlPath
$AID     = [IO.Path]::GetFileNameWithoutExtension($XmlPath)
$OutDir  = Join-Path (Split-Path -Parent $XmlDir) 'output'
$OutHtml = Join-Path $OutDir 'index.html'
$PdfDir  = Join-Path $XmlDir 'pdf'

# Classpath (Windows uses ';')
$cpParts = @($Saxon)
if (Test-Path $Resolv)  { $cpParts += $Resolv }
if (Test-Path $ResData) { $cpParts += $ResData }
$CP = ($cpParts -join ';')

# Transform to temp
$TmpHtml = [IO.Path]::GetTempFileName() -replace '\.tmp$','.html'
$args = @(
  '-t'
  "-s:$XmlPath"
  "-xsl:$MainXsl"
  "-o:$TmpHtml"
  'assets-path=assets/'
  "article-img=$ArticleImgRoot"
)

$PdfFile = Join-Path $PdfDir "$AID$PdfSuffix"
if (Test-Path $PdfFile) {
  $args += "pdf-href=assets/multimedia/$AID$PdfSuffix"
}

$catalog = Join-Path $Root 'transformation-template\dtd\catalog.xml'
if (Test-Path $catalog) { $args += "-catalog:$catalog" }

& $Java "-Xmx$Heap" -cp "$CP" net.sf.saxon.Transform @args | Out-Null

if (-not (Test-Path $TmpHtml) -or (Get-Item $TmpHtml).Length -eq 0) {
  [System.Windows.Forms.MessageBox]::Show("Transform failed (no HTML produced)","Error",'OK','Error'); exit 1
}

# Copy output
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Move-Item -Force $TmpHtml $OutHtml

# Copy assets (exclude fonts/ and img/)
if (Test-Path $AssetsSrc) {
  New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'assets') | Out-Null
  # robocopy returns non-zero for some normal cases; ignore > 7
  robocopy "$AssetsSrc" (Join-Path $OutDir 'assets') /E /XD fonts img | Out-Null
}

# Per-article images
$ArticleImgSrc = Join-Path $XmlDir $ArticleImgSub
if (Test-Path $ArticleImgSrc) {
  $imgDest = Join-Path $OutDir 'assets\img'
  New-Item -ItemType Directory -Force -Path $imgDest | Out-Null
  robocopy "$ArticleImgSrc" "$imgDest" /E | Out-Null
}

# Per-article PDFs
if (Test-Path $PdfDir) {
  $pdfDest = Join-Path $OutDir 'assets\multimedia'
  New-Item -ItemType Directory -Force -Path $pdfDest | Out-Null
  robocopy "$PdfDir" "$pdfDest" /E | Out-Null
}

# Bundle CSS/JS into assets\stylesheets\css.css and javascript.js
$assetsDir = Join-Path $OutDir 'assets'
$styleDir  = Join-Path $assetsDir 'stylesheets'
foreach ($d in @('css','js')) {
  $srcDir = Join-Path $assetsDir $d
  if (Test-Path $srcDir) {
    New-Item -ItemType Directory -Force -Path $styleDir | Out-Null
    Get-ChildItem -Path $srcDir -File | ForEach-Object {
      Move-Item -Force $_.FullName (Join-Path $styleDir $_.Name)
    }
    Remove-Item -Recurse -Force $srcDir
  }
}

if (Test-Path $styleDir) {
  $cssBundle = Join-Path $styleDir 'css.css'
  Set-Content -Path $cssBundle -Value ''
  Get-ChildItem -Path $styleDir -Filter *.css -File | Where-Object { $_.Name -ne 'css.css' } | ForEach-Object {
    Add-Content -Path $cssBundle -Value ("/* {0} */" -f $_.Name)
    Add-Content -Path $cssBundle -Value (Get-Content $_.FullName -Raw)
    Add-Content -Path $cssBundle -Value "`r`n"
    Remove-Item $_.FullName
  }

  $jsBundle = Join-Path $styleDir 'javascript.js'
  Set-Content -Path $jsBundle -Value ''
  Get-ChildItem -Path $styleDir -Filter *.js -File | Where-Object { $_.Name -ne 'javascript.js' } | ForEach-Object {
    Add-Content -Path $jsBundle -Value ("/* {0} */" -f $_.Name)
    Add-Content -Path $jsBundle -Value (Get-Content $_.FullName -Raw)
    Add-Content -Path $jsBundle -Value "`r`n"
    Remove-Item $_.FullName
  }
}

# Open result
Start-Process "$OutHtml"
[System.Windows.Forms.MessageBox]::Show("Built index.html and copied assets.`n`n$OutHtml","JATS → HTML") | Out-Null