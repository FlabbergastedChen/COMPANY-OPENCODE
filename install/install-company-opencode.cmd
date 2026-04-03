@echo off
setlocal

set "SCRIPT_DIR=%~dp0"

powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-company-opencode.ps1"
if errorlevel 1 (
  echo [install][error] PowerShell install failed.
  exit /b 1
)

rem Make wrappers available immediately in this CMD session.
set "PATH=%USERPROFILE%\.company-opencode\bin;%USERPROFILE%\.company-opencode\npm-global;%PATH%"
set "OPENCODE_CONFIG_DIR=%USERPROFILE%\.company-opencode\current"

echo [install] Done.
echo [install] Current CMD session updated:
echo [install]   PATH includes %%USERPROFILE%%\.company-opencode\bin and npm-global
echo [install]   OPENCODE_CONFIG_DIR=%%USERPROFILE%%\.company-opencode\current
echo [install] Try: opencode-company --version

endlocal & (
  set "PATH=%PATH%"
  set "OPENCODE_CONFIG_DIR=%OPENCODE_CONFIG_DIR%"
)
