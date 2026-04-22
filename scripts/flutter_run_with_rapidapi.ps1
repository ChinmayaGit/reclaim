# Runs `flutter run` with ExerciseDB key from repo root `rapidapi.local.env` (gitignored).
# From repo root:  pwsh -File scripts/flutter_run_with_rapidapi.ps1
# Extra args go to flutter:  pwsh -File scripts/flutter_run_with_rapidapi.ps1 run -d chrome

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$envFile = Join-Path $root "rapidapi.local.env"
if (-not (Test-Path $envFile)) {
  Write-Host "Missing rapidapi.local.env — copy rapidapi.local.env.example to rapidapi.local.env and set RAPIDAPI_KEY." -ForegroundColor Yellow
  exit 1
}

$key = $null
Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -match '^\s*#' -or $line -eq "") { return }
  if ($line -match '^\s*RAPIDAPI_KEY\s*=\s*(.+)\s*$') {
    $key = $Matches[1].Trim().Trim('"').Trim("'")
  }
}

if ([string]::IsNullOrWhiteSpace($key) -or $key -eq "your_rapidapi_key_here") {
  Write-Host "Set a real RAPIDAPI_KEY in rapidapi.local.env." -ForegroundColor Yellow
  exit 1
}

if ($args.Count -eq 0) {
  flutter run "--dart-define=RAPIDAPI_KEY=$key"
} else {
  flutter @args "--dart-define=RAPIDAPI_KEY=$key"
}
