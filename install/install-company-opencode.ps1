$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Resolve-Path (Join-Path $ScriptDir '..')
$BundleSrc = Join-Path $PackageRoot 'bundle'

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$InstallRoot = if ($env:COMPANY_OPENCODE_HOME) { $env:COMPANY_OPENCODE_HOME } else { Join-Path $HomeDir '.company-opencode' }
$BundlesDir = Join-Path $InstallRoot 'bundles'
$CurrentLink = Join-Path $InstallRoot 'current'

function Write-Info($msg) { Write-Host "[install] $msg" }
function Write-WarnMsg($msg) { Write-Host "[install][warn] $msg" -ForegroundColor Yellow }

function Get-BundleVersion {
  $manifest = Join-Path $BundleSrc 'bundle-manifest.json'
  if (-not (Test-Path $manifest)) { return (Get-Date -Format 'yyyy.MM.dd-HHmmss') }
  $json = Get-Content $manifest -Raw | ConvertFrom-Json
  if ($json.version) { return [string]$json.version }
  return (Get-Date -Format 'yyyy.MM.dd-HHmmss')
}

function Ensure-OpenCode {
  $cmd = Get-Command opencode -ErrorAction SilentlyContinue
  if ($cmd) {
    Write-Info "Detected opencode: $(opencode --version)"
    return
  }

  Write-Info 'opencode not found. Installing via npm install -g opencode-ai'
  npm install -g opencode-ai

  $cmd2 = Get-Command opencode -ErrorAction SilentlyContinue
  if (-not $cmd2) {
    throw 'opencode install finished but command not found in PATH'
  }
  Write-Info "Installed opencode: $(opencode --version)"
}

function Copy-BundleFromPackage {
  $version = Get-BundleVersion
  $dst = Join-Path $BundlesDir $version

  New-Item -ItemType Directory -Force -Path $BundlesDir | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $InstallRoot 'backups') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $InstallRoot 'logs') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $InstallRoot 'cache') | Out-Null

  if (-not (Test-Path $dst)) {
    Write-Info "Copying bundle from package: $BundleSrc -> $dst"
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Path (Join-Path $BundleSrc '*') -Destination $dst -Recurse -Force
  } else {
    Write-Info "Bundle version already exists: $version"
  }

  if (Test-Path $CurrentLink) {
    $backupDir = Join-Path $InstallRoot 'backups'
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    try {
      $existing = (Get-Item $CurrentLink -Force).Target
      if ($existing) {
        Set-Content -Path (Join-Path $backupDir "previous-current-$ts.txt") -Value $existing
      }
    } catch {
      # ignore
    }
    Remove-Item -Path $CurrentLink -Force -ErrorAction SilentlyContinue
  }

  New-Item -ItemType SymbolicLink -Path $CurrentLink -Target $dst | Out-Null
  Write-Info "Current bundle -> $dst"
}

function Set-PersistentEnv {
  [Environment]::SetEnvironmentVariable('OPENCODE_CONFIG_DIR', (Join-Path $InstallRoot 'current'), 'User')
  Write-Info 'Persisted User Env: OPENCODE_CONFIG_DIR'
}

Ensure-OpenCode
Copy-BundleFromPackage
Set-PersistentEnv

Write-Info 'Done.'
Write-Info 'Use: opencode --version'
