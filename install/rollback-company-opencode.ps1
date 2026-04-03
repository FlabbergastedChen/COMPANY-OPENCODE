$ErrorActionPreference = 'Stop'
$ConfirmPreference = 'None'

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$InstallRoot = if ($env:COMPANY_OPENCODE_HOME) { $env:COMPANY_OPENCODE_HOME } else { Join-Path $HomeDir '.company-opencode' }
$CurrentLink = Join-Path $InstallRoot 'current'
$BackupsDir = Join-Path $InstallRoot 'backups'
$GlobalConfigDir = if ($env:OPENCODE_GLOBAL_CONFIG_DIR) { $env:OPENCODE_GLOBAL_CONFIG_DIR } else { Join-Path $HomeDir '.config/opencode' }

function Write-Info($msg) { Write-Host "[rollback] $msg" }
function Write-WarnMsg($msg) { Write-Host "[rollback][warn] $msg" -ForegroundColor Yellow }

function Ensure-GlobalCompatLinks {
  New-Item -ItemType Directory -Force -Path $GlobalConfigDir | Out-Null
  $dirs = @('agents', 'commands', 'skills', 'plugins', 'tools', 'themes', 'modes')

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
          Remove-Item -Path $dst -Recurse -Force -ErrorAction SilentlyContinue
        }
      } catch {
        Remove-Item -Path $dst -Recurse -Force -ErrorAction SilentlyContinue
      }
    }

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

if (-not (Test-Path $BackupsDir)) {
  throw "Backups directory not found: $BackupsDir"
}

$backupFile = Get-ChildItem -Path $BackupsDir -Filter 'previous-current-*.txt' -File |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $backupFile) {
  throw "No rollback checkpoint found under: $BackupsDir"
}

$target = (Get-Content -Path $backupFile.FullName -Raw).Trim()
if (-not $target) {
  throw "Rollback checkpoint is empty: $($backupFile.FullName)"
}
if (-not (Test-Path $target)) {
  throw "Rollback target not found: $target"
}

if (Test-Path $CurrentLink) {
  Remove-Item -Path $CurrentLink -Recurse -Force -ErrorAction SilentlyContinue
}

try {
  New-Item -ItemType Junction -Path $CurrentLink -Target $target | Out-Null
  Write-Info "Current bundle rolled back (junction) -> $target"
} catch {
  Write-WarnMsg "Cannot create current junction. Falling back to directory copy."
  New-Item -ItemType Directory -Force -Path $CurrentLink | Out-Null
  Copy-Item -Path (Join-Path $target '*') -Destination $CurrentLink -Recurse -Force
  Write-Info "Current bundle copied to: $CurrentLink"
}

$env:OPENCODE_CONFIG_DIR = $CurrentLink
[Environment]::SetEnvironmentVariable('OPENCODE_CONFIG_DIR', $CurrentLink, 'User')
Ensure-GlobalCompatLinks

Write-Info 'Done.'
Write-Info "Rolled back using checkpoint: $($backupFile.Name)"
