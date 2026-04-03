$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Resolve-Path (Join-Path $ScriptDir '..')
$BundleSrc = Join-Path $PackageRoot 'bundle'

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$InstallRoot = if ($env:COMPANY_OPENCODE_HOME) { $env:COMPANY_OPENCODE_HOME } else { Join-Path $HomeDir '.company-opencode' }
$BundlesDir = Join-Path $InstallRoot 'bundles'
$CurrentLink = Join-Path $InstallRoot 'current'
$NpmPrefix = Join-Path $InstallRoot 'npm-global'
$GlobalConfigDir = if ($env:OPENCODE_GLOBAL_CONFIG_DIR) { $env:OPENCODE_GLOBAL_CONFIG_DIR } else { Join-Path $HomeDir '.config/opencode' }
$InstallScriptsDir = Join-Path $InstallRoot 'install'
$InstallBinDir = Join-Path $InstallRoot 'bin'

function Write-Info($msg) { Write-Host "[install] $msg" }
function Write-WarnMsg($msg) { Write-Host "[install][warn] $msg" -ForegroundColor Yellow }
function Write-ErrMsg($msg) { Write-Host "[install][error] $msg" -ForegroundColor Red }

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

  $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
  if (-not $npmCmd) {
    throw 'npm not found. Please install Node.js first: https://nodejs.org/'
  }

  # Avoid global permission errors by forcing a per-user npm prefix.
  New-Item -ItemType Directory -Force -Path $NpmPrefix | Out-Null
  npm config set prefix "$NpmPrefix" --location=user | Out-Null

  if (-not ($env:Path -split ';' | Where-Object { $_ -eq $NpmPrefix })) {
    $env:Path = "$NpmPrefix;$env:Path"
  }

  Write-Info "opencode not found. Installing via npm install -g opencode-ai (user prefix: $NpmPrefix)"
  try {
    npm install -g opencode-ai
  } catch {
    Write-ErrMsg 'npm global install failed. This is often caused by permission policies.'
    Write-ErrMsg "Try running PowerShell as your normal user and ensure $NpmPrefix is writable."
    throw
  }

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
    Remove-Item -Path $CurrentLink -Recurse -Force -ErrorAction SilentlyContinue
  }

  # SymbolicLink may require elevated privileges on Windows.
  # Prefer junction first; fall back to a directory copy.
  try {
    New-Item -ItemType Junction -Path $CurrentLink -Target $dst | Out-Null
    Write-Info "Current bundle (junction) -> $dst"
  } catch {
    Write-WarnMsg "Cannot create junction at $CurrentLink. Falling back to directory copy."
    New-Item -ItemType Directory -Force -Path $CurrentLink | Out-Null
    Copy-Item -Path (Join-Path $dst '*') -Destination $CurrentLink -Recurse -Force
    Write-Info "Current bundle copied to: $CurrentLink"
  }
}

function Ensure-GlobalCompatLinks {
  New-Item -ItemType Directory -Force -Path $GlobalConfigDir | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $InstallRoot 'backups') | Out-Null

  $dirs = @('agents', 'commands', 'skills', 'plugins', 'tools', 'themes', 'modes')
  $ts = Get-Date -Format 'yyyyMMdd-HHmmss'

  foreach ($d in $dirs) {
    $src = Join-Path $CurrentLink $d
    if (-not (Test-Path $src)) { continue }

    $dst = Join-Path $GlobalConfigDir $d
    if (Test-Path $dst) {
      try {
        $item = Get-Item $dst -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
          Remove-Item -Path $dst -Force -ErrorAction SilentlyContinue
        } else {
          $backup = Join-Path (Join-Path $InstallRoot 'backups') ("compat-$d-$ts")
          Write-WarnMsg "Found existing non-link at $dst; moving to $backup"
          Move-Item -Path $dst -Destination $backup -Force
        }
      } catch {
        Remove-Item -Path $dst -Recurse -Force -ErrorAction SilentlyContinue
      }
    }

    # Prefer junctions for directory links on Windows.
    try {
      New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    } catch {
      Write-WarnMsg "Cannot create junction $dst -> $src. Falling back to directory copy."
      New-Item -ItemType Directory -Force -Path $dst | Out-Null
      Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
    }
  }

  Write-Info "Global compatibility paths ensured under: $GlobalConfigDir"
}

function Install-HelpersAndWrappers {
  New-Item -ItemType Directory -Force -Path $InstallScriptsDir | Out-Null
  New-Item -ItemType Directory -Force -Path $InstallBinDir | Out-Null

  $scriptFiles = @(
    'install-company-opencode.ps1',
    'upgrade-company-opencode.ps1',
    'rollback-company-opencode.ps1',
    'uninstall-company-opencode.ps1'
  )

  foreach ($name in $scriptFiles) {
    $src = Join-Path $ScriptDir $name
    if (Test-Path $src) {
      Copy-Item -Path $src -Destination (Join-Path $InstallScriptsDir $name) -Force
    }
  }

  $wrapper = @"
@echo off
setlocal
if defined COMPANY_OPENCODE_HOME (
  set "ROOT=%COMPANY_OPENCODE_HOME%"
) else (
  set "ROOT=%USERPROFILE%\.company-opencode"
)
set "OPENCODE_CONFIG_DIR=%ROOT%\current"
opencode %*
"@
  Set-Content -Path (Join-Path $InstallBinDir 'opencode-company.cmd') -Value $wrapper -Encoding Ascii

  $upgradeWrapper = @"
@echo off
setlocal
if defined COMPANY_OPENCODE_HOME (
  set "ROOT=%COMPANY_OPENCODE_HOME%"
) else (
  set "ROOT=%USERPROFILE%\.company-opencode"
)
powershell -ExecutionPolicy Bypass -File "%ROOT%\install\upgrade-company-opencode.ps1" %*
"@
  Set-Content -Path (Join-Path $InstallBinDir 'opencode-company-upgrade.cmd') -Value $upgradeWrapper -Encoding Ascii

  $rollbackWrapper = @"
@echo off
setlocal
if defined COMPANY_OPENCODE_HOME (
  set "ROOT=%COMPANY_OPENCODE_HOME%"
) else (
  set "ROOT=%USERPROFILE%\.company-opencode"
)
powershell -ExecutionPolicy Bypass -File "%ROOT%\install\rollback-company-opencode.ps1" %*
"@
  Set-Content -Path (Join-Path $InstallBinDir 'opencode-company-rollback.cmd') -Value $rollbackWrapper -Encoding Ascii

  $uninstallWrapper = @"
@echo off
setlocal
if defined COMPANY_OPENCODE_HOME (
  set "ROOT=%COMPANY_OPENCODE_HOME%"
) else (
  set "ROOT=%USERPROFILE%\.company-opencode"
)
powershell -ExecutionPolicy Bypass -File "%ROOT%\install\uninstall-company-opencode.ps1" %*
"@
  Set-Content -Path (Join-Path $InstallBinDir 'opencode-company-uninstall.cmd') -Value $uninstallWrapper -Encoding Ascii

  Write-Info "Installed wrappers into: $InstallBinDir"
}

function Set-PersistentEnv {
  $configDir = Join-Path $InstallRoot 'current'
  [Environment]::SetEnvironmentVariable('OPENCODE_CONFIG_DIR', $configDir, 'User')
  $env:OPENCODE_CONFIG_DIR = $configDir
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (-not $userPath) { $userPath = '' }
  $parts = $userPath -split ';' | Where-Object { $_ -ne '' }
  if (-not ($parts | Where-Object { $_ -eq $NpmPrefix })) {
    $newPath = if ($userPath) { "$NpmPrefix;$userPath" } else { $NpmPrefix }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Info "Persisted User Env: PATH += $NpmPrefix"
  } else {
    Write-Info 'User PATH already contains npm user prefix'
  }
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $parts = $userPath -split ';' | Where-Object { $_ -ne '' }
  if (-not ($parts | Where-Object { $_ -eq $InstallBinDir })) {
    $newPath = if ($userPath) { "$InstallBinDir;$userPath" } else { $InstallBinDir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Info "Persisted User Env: PATH += $InstallBinDir"
  } else {
    Write-Info 'User PATH already contains wrapper bin'
  }
  if (-not ($env:Path -split ';' | Where-Object { $_ -eq $NpmPrefix })) {
    $env:Path = "$NpmPrefix;$env:Path"
  }
  if (-not ($env:Path -split ';' | Where-Object { $_ -eq $InstallBinDir })) {
    $env:Path = "$InstallBinDir;$env:Path"
  }
  Write-Info 'Persisted User Env: OPENCODE_CONFIG_DIR'
}

Ensure-OpenCode
Copy-BundleFromPackage
Ensure-GlobalCompatLinks
Install-HelpersAndWrappers
Set-PersistentEnv

Write-Info 'Done.'
Write-Info 'Use: opencode-company --version'
Write-Info 'Use: opencode-company'
