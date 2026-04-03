$ErrorActionPreference = 'Stop'
$ConfirmPreference = 'None'

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$InstallRoot = if ($env:COMPANY_OPENCODE_HOME) { $env:COMPANY_OPENCODE_HOME } else { Join-Path $HomeDir '.company-opencode' }
$NpmPrefix = Join-Path $InstallRoot 'npm-global'
$GlobalConfigDir = if ($env:OPENCODE_GLOBAL_CONFIG_DIR) { $env:OPENCODE_GLOBAL_CONFIG_DIR } else { Join-Path $HomeDir '.config/opencode' }
$InstallBinDir = Join-Path $InstallRoot 'bin'

function Write-Info($msg) { Write-Host "[uninstall] $msg" }

function Remove-PathEntryFromUserPath([string]$entry) {
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (-not $userPath) { return }

  $parts = $userPath -split ';' | Where-Object { $_ -and ($_ -ne $entry) }
  $newPath = ($parts -join ';')
  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
  Write-Info "Removed PATH entry (if present): $entry"
}

function Clear-NpmPrefixIfManaged {
  $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
  if (-not $npmCmd) { return }

  try {
    $prefix = (npm config get prefix --location=user).Trim()
    if ($prefix -eq $NpmPrefix) {
      npm config delete prefix --location=user | Out-Null
      Write-Info 'Removed npm user prefix managed by COMPANY-OPENCODE'
    }
  } catch {
    # ignore
  }
}

function Remove-InstallRoot {
  if (Test-Path $InstallRoot) {
    Remove-Item -Path $InstallRoot -Recurse -Force
    Write-Info "Removed install root: $InstallRoot"
  } else {
    Write-Info "Install root not found (already removed): $InstallRoot"
  }
}

function Remove-GlobalCompatPaths {
  $dirs = @('agents', 'commands', 'skills', 'plugins', 'tools', 'themes', 'modes')
  foreach ($d in $dirs) {
    $p = Join-Path $GlobalConfigDir $d
    if (-not (Test-Path $p)) { continue }
    try {
      $item = Get-Item $p -Force
      if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        $target = $item.Target
        if ($target -and $target.ToString().StartsWith($InstallRoot)) {
          Remove-Item -Path $p -Force -ErrorAction SilentlyContinue
          Write-Info "Removed global compat link: $p"
        }
      }
    } catch {
      # ignore
    }
  }
}

function Clear-Env {
  [Environment]::SetEnvironmentVariable('OPENCODE_CONFIG_DIR', $null, 'User')
  $env:OPENCODE_CONFIG_DIR = $null
  Write-Info 'Cleared User Env: OPENCODE_CONFIG_DIR'
  Remove-PathEntryFromUserPath $NpmPrefix
  Remove-PathEntryFromUserPath $InstallBinDir
}

Clear-NpmPrefixIfManaged
Remove-GlobalCompatPaths
Clear-Env
Remove-InstallRoot

Write-Info 'Done.'
Write-Info 'Project source files are untouched.'
Write-Info 'Open a new PowerShell session to refresh environment.'
