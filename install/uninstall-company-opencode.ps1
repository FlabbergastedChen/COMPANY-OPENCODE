$ErrorActionPreference = 'Stop'

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$InstallRoot = if ($env:COMPANY_OPENCODE_HOME) { $env:COMPANY_OPENCODE_HOME } else { Join-Path $HomeDir '.company-opencode' }
$NpmPrefix = Join-Path $InstallRoot 'npm-global'

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

function Clear-Env {
  [Environment]::SetEnvironmentVariable('OPENCODE_CONFIG_DIR', $null, 'User')
  Write-Info 'Cleared User Env: OPENCODE_CONFIG_DIR'
  Remove-PathEntryFromUserPath $NpmPrefix
}

Clear-NpmPrefixIfManaged
Clear-Env
Remove-InstallRoot

Write-Info 'Done.'
Write-Info 'Project source files are untouched.'
Write-Info 'Open a new PowerShell session to refresh environment.'
