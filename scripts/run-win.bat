@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "PS1=%SCRIPT_DIR%run-win.ps1"

rem Prefer PowerShell 7 (pwsh), fallback to Windows PowerShell; forward all args; use STA for dialogs
where pwsh >nul 2>&1
if %ERRORLEVEL%==0 (
  pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%PS1%" %*
  exit /b %ERRORLEVEL%
)

where powershell.exe >nul 2>&1
if %ERRORLEVEL%==0 (
  powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%PS1%" %*
  exit /b %ERRORLEVEL%
)

echo ERROR: PowerShell not found. Install PowerShell 7 or ensure Windows PowerShell is available.
pause
exit /b 1