# Windows one‑click JATS → HTML (per‑article)
# Editors: double-click → picker. Devs: -xml, -out, -verbose.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms | Out-Null

# ----------------------------
# Params (accept GNU-style aliases too)
# ----------------------------
param(
  [string]$xml,
  [string]$out,
  [switch]$verbose
)
# GNU aliases (--xml, --out, --verbose) for convenience
for ($i = 0; $i -lt $args.Length; $i++) {
  switch ($args[$i]) {
    '--xml'     { if ($i + 1 -lt $args.Length) { $xml = $args[$i+1]; $i++ } }
    '--out'     { if ($i + 1 -lt $args.Length) { $out = $args[$i+1]; $i++ } }
    '--verbose' { $verbose = $true }
  }
}

# ----------------------------
# Paths and version/meta
# ----------------------------
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Arch = 'win-x64'

# Version: environment override, else git describe, else 'local'
$Version = $env:TRANSFORMER_VERSION
if (-not $Version) {
  try {
    Push-Location $Root
    $Version = (& git describe --tags --always 2>$null)
    Pop-Location
  } catch {
    $Version = $null
  }
}
if (-not $Version) { $Version = 'local' }
$BuildStamp = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')

# Tools
$ToolsDir  = Join-Path $Root 'tools'
$MainXsl   = Join-Path $Root 'transformation-template\xslt\main.xsl'
$AssetsSrc = Join-Path $Root 'transformation-template\assets'
$Catalog   = Join-Path $Root 'transformation-template\dtd\catalog.xml'

# Behavior constants
$ArticleImgSub  = 'article-img'
$ArticleImgRoot = 'assets/img/'
$PdfSuffix      = '_PDF.pdf'
$Heap           = '256m'

# ----------------------------
# Helpers: logging and alerts
# ----------------------------
$Log = $null
function Ts { return (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') }
function Write-Log {
  param([string]$level,[string]$msg)
  $line = "[{0}] [{1}] {2}" -f (Ts), $level, $msg
  if ($Log) { Add-Content -Path $Log -Value $line }
  if ($verbose) { Write-Host $line }
}
function Info  { param([string]$m) Write-Log 'info'  $m }
function Warn  { param([string]$m) Write-Log 'warn'  $m }
function Error { param([string]$m) Write-Log 'error' $m }
function Alert {
  param([string]$title,[string]$msg,[string]$icon='Error')
  [System.Windows.Forms.MessageBox]::Show($msg,$title,'OK',$icon) | Out-Null
}

# ----------------------------
# Java selection (bundled → system)
# ----------------------------
$Java = $null
$javaCandidates = @(
  (Join-Path $Root 'jre\win-x64\bin\java.exe'),
  (Join-Path $Root 'jre\bin\java.exe')
)
foreach ($c in $javaCandidates) { if (Test-Path $c) { $Java = $c; break } }
if (-not $Java) { $Java = (Get-Command java -ErrorAction SilentlyContinue)?.Source }
if (-not $Java) {
  Alert "Missing Java" "Java not found. Bundle JRE at jre\win-x64 or install Java."
  exit 1
}

# ----------------------------
# Tools: detect Saxon/Resolver jars
# ----------------------------
$saxonFile = Get-ChildItem $ToolsDir -Filter 'saxon-he-*.jar' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $saxonFile) { $saxonFile = Get-ChildItem $ToolsDir -Filter 'Saxon-HE-*.jar' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $saxonFile) {
  Alert "Missing dependency" "Saxon-HE jar not found in tools\ (e.g., saxon-he-12.x.jar)."
  exit 1
}
$Saxon = $saxonFile.FullName
$resolverFile = Get-ChildItem $ToolsDir -Filter 'xmlresolver-*.jar' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch 'data' } | Select-Object -First 1
$resolverDataFile = Get-ChildItem $ToolsDir -Filter 'xmlresolver-*-data.jar' -ErrorAction SilentlyContinue | Select-Object -First 1
$Resolv  = $resolverFile?.FullName
$ResData = $resolverDataFile?.FullName

if (-not (Test-Path $MainXsl)) {
  Alert "Missing dependency" "Missing main.xsl:`n$MainXsl"
  exit 1
}

# ----------------------------
# XML selection (GUI unless -xml provided)
# ----------------------------
if (-not $xml) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = 'Pick the article XML (…\input\<article>.xml)'
  $dlg.Filter = 'XML Files (*.xml)|*.xml'
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $xml = $dlg.FileName
}
if (-not (Test-Path $xml)) { Alert "Error" "Selected file not found"; exit 1 }
if ([IO.Path]::GetExtension($xml).ToLower() -ne '.xml') { Alert "Error" "Please select a .xml file"; exit 1 }

# ----------------------------
# Article paths and per-run log with rollover
# ----------------------------
$XmlPath = $xml
$XmlDir  = Split-Path -Parent $XmlPath
$AID     = [IO.Path]::GetFileNameWithoutExtension($XmlPath)
$BaseId  = ($AID -replace '_XML$','')
$ArticleDir = Split-Path -Parent $XmlDir

$Log = Join-Path $ArticleDir 'transformation.log'
$PrevLog = Join-Path $ArticleDir 'transformation.prev.log'
if (Test-Path $Log) { try { Move-Item -Force $Log $PrevLog } catch { Copy-Item -Force $Log $PrevLog } }
New-Item -ItemType File -Force -Path $Log | Out-Null

Info "Start build $BuildStamp | version=$Version | arch=$Arch"
Info "XML: $XmlPath"
Info "Saxon: $([IO.Path]::GetFileName($Saxon))"
if ($Resolv)  { Info "Resolver: $([IO.Path]::GetFileName($Resolv))" }
if ($ResData) { Info "Resolver data: $([IO.Path]::GetFileName($ResData))" }

# ----------------------------
# Output targets (default or -out override)
# ----------------------------
$DefaultOutDir = Join-Path $ArticleDir 'output'
$OutDir  = $DefaultOutDir
$OutHtml = Join-Path $OutDir 'index.html'
if ($out) {
  if ((Test-Path $out -PathType Container) -or $out.EndsWith('\') -or $out.EndsWith('/')) {
    $OutDir  = $out.TrimEnd('\','/')
    $OutHtml = Join-Path $OutDir 'index.html'
  } else {
    $OutDir  = Split-Path -Parent $out
    $OutHtml = $out
  }
}
try {
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
} catch {
  Error "Cannot create output folder: $OutDir"
  Alert "Cannot create output folder" $OutDir
  exit 1
}
Info "OUT dir: $OutDir"
Info "OUT file: $OutHtml"

# ----------------------------
# Build Java classpath and transform args
# ----------------------------
$cpParts = @($Saxon)
if ($Resolv)  { $cpParts += $Resolv }
if ($ResData) { $cpParts += $ResData }
$CP = ($cpParts -join ';')
Info "CP: $CP"

$TmpHtml = [IO.Path]::GetTempFileName() -replace '\.tmp$','.html'
$argsBase = @(
  '-t'
  ("-s:{0}" -f $XmlPath)
  ("-xsl:{0}" -f $MainXsl)
  ("-o:{0}" -f $TmpHtml)
  'assets-path=assets/'
  ("article-img={0}" -f $ArticleImgRoot)
)

# Optional PDF param (relative to output assets)
$PdfDir  = Join-Path $XmlDir 'pdf'
$PdfFile = Join-Path $PdfDir "$BaseId$PdfSuffix"
if (Test-Path $PdfFile) {
  $argsBase += ("pdf-href=assets/multimedia/{0}" -f ([IO.Path]::GetFileName($PdfFile)))
  Info "PDF: $PdfFile"
} else {
  Info "No PDF for $BaseId"
}

if (Test-Path $Catalog) {
  $argsBase += ("-catalog:{0}" -f $Catalog)
  Info "Catalog: $Catalog"
} else {
  Warn "No catalog.xml found; resolving DTD relative to XML"
}

# Exact Java command (for logs)
$javaArgsForLog = @("-Xmx$Heap", '-cp', $CP, 'net.sf.saxon.Transform') + $argsBase
$execLine = ('Exec: "{0}" {1}' -f $Java, ($javaArgsForLog | ForEach-Object {
  if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ }
}) -join ' ')
Info $execLine

# ----------------------------
# Run transform (append Saxon output to our log)
# ----------------------------
& $Java @javaArgsForLog 2>&1 | Tee-Object -FilePath $Log -Append | Out-Null
$exit = $LASTEXITCODE
Info ("Saxon exit: {0}" -f $exit)

if ($exit -ne 0 -or -not (Test-Path $TmpHtml) -or (Get-Item $TmpHtml).Length -eq 0) {
  Error "Transform failed; tmp html missing or empty: $TmpHtml"
  try {
    Get-Content -Tail 100 $Log | Set-Content (Join-Path $ArticleDir 'transformation-error.txt')
  } catch {}
  Alert "Transform failed" "Check transformation.log (next to the article folder)"
  exit 1
}

# ----------------------------
# Write output and tag build
# ----------------------------
Move-Item -Force $TmpHtml $OutHtml
$buildTag = "<!-- Built by JATS → HTML | version=$Version | arch=$Arch | saxon=$([IO.Path]::GetFileName($Saxon)) | $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')) -->`r`n"
Set-Content -Path $OutHtml -Value ($buildTag + (Get-Content $OutHtml -Raw))

# ----------------------------
# Copy assets and per-article media
# ----------------------------
if (Test-Path $AssetsSrc) {
  New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'assets') | Out-Null
  Info "Copy assets (excluding fonts/ and img/)"
  # Robocopy exit codes: 0/1 OK-ish; we log output but don't hard-fail here
  robocopy "$AssetsSrc" (Join-Path $OutDir 'assets') /E /XD fonts img | Tee-Object -FilePath $Log -Append | Out-Null
}

# Per-article images
$ArticleImgSrc = Join-Path $XmlDir $ArticleImgSub
if (Test-Path $ArticleImgSrc) {
  $imgDest = Join-Path $OutDir 'assets\img'
  New-Item -ItemType Directory -Force -Path $imgDest | Out-Null
  Info "Copy per-article images from $ArticleImgSrc -> $imgDest"
  robocopy "$ArticleImgSrc" "$imgDest" /E | Tee-Object -FilePath $Log -Append | Out-Null
}

# Per-article PDFs
$PdfSrc = $PdfDir
if (Test-Path $PdfSrc) {
  $pdfDest = Join-Path $OutDir 'assets\multimedia'
  New-Item -ItemType Directory -Force -Path $pdfDest | Out-Null
  Info "Copy per-article PDFs from $PdfSrc -> $pdfDest"
  robocopy "$PdfSrc" "$pdfDest" /E | Tee-Object -FilePath $Log -Append | Out-Null
}

# ----------------------------
# Bundle CSS/JS into assets\stylesheets (log every merged file)
# Keeps existing behavior: move from assets\css and assets\js, then bundle.
# ----------------------------
$assetsDir = Join-Path $OutDir 'assets'
$styleDir  = Join-Path $assetsDir 'stylesheets'
New-Item -ItemType Directory -Force -Path $styleDir | Out-Null

foreach ($d in @('css','js')) {
  $srcDir = Join-Path $assetsDir $d
  if (Test-Path $srcDir) {
    Info "Flatten $d -> stylesheets/"
    Get-ChildItem -Path $srcDir -File | ForEach-Object {
      Move-Item -Force $_.FullName (Join-Path $styleDir $_.Name)
    }
    Remove-Item -Recurse -Force $srcDir
  }
}

# Bundle CSS
$cssBundle = Join-Path $styleDir 'css.css'
Set-Content -Path $cssBundle -Value ''
$cssCount = 0
Get-ChildItem -Path $styleDir -Filter *.css -File | Where-Object { $_.Name -ne 'css.css' } | ForEach-Object {
  Info ("Merge CSS: {0}" -f $_.Name)
  Add-Content -Path $cssBundle -Value ("/* {0} */" -f $_.Name)
  Add-Content -Path $cssBundle -Value (Get-Content $_.FullName -Raw)
  Add-Content -Path $cssBundle -Value "`r`n"
  Remove-Item $_.FullName
  $cssCount++
}
Info ("CSS bundled files: {0} -> {1}" -f $cssCount, $cssBundle)

# Bundle JS
$jsBundle = Join-Path $styleDir 'javascript.js'
Set-Content -Path $jsBundle -Value ''
$jsCount = 0
Get-ChildItem -Path $styleDir -Filter *.js -File | Where-Object { $_.Name -ne 'javascript.js' } | ForEach-Object {
  Info ("Merge JS: {0}" -f $_.Name)
  Add-Content -Path $jsBundle -Value ("/* {0} */" -f $_.Name)
  Add-Content -Path $jsBundle -Value (Get-Content $_.FullName -Raw)
  Add-Content -Path $jsBundle -Value "`r`n"
  Remove-Item $_.FullName
  $jsCount++
}
Info ("JS bundled files: {0} -> {1}" -f $jsCount, $jsBundle)

# ----------------------------
# Final checks and open
# ----------------------------
if (-not (Test-Path $OutHtml) -or (Get-Item $OutHtml).Length -eq 0) {
  Error "No HTML produced at $OutHtml"
  Alert "No HTML produced" "Check transformation.log for details"
  exit 1
}
Info "Done: $OutHtml"
Start-Process "$OutHtml"
[System.Windows.Forms.MessageBox]::Show("Built index.html and copied assets.`n`n$OutHtml","JATS → HTML") | Out-Null