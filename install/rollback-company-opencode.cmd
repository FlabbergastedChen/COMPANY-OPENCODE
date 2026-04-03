@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%SCRIPT_DIR%rollback-company-opencode.ps1" %*
exit /b %errorlevel%
