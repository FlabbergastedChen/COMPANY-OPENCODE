$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Info($msg) { Write-Host "[upgrade] $msg" }

$installScript = Join-Path $ScriptDir 'install-company-opencode.ps1'
if (-not (Test-Path $installScript)) {
  throw "Install script not found: $installScript"
}

Write-Info 'Running install script as upgrade flow...'
& $installScript @args

