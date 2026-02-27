$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $repoRoot "logs\system-monitor.pid"
$exePath = Join-Path $repoRoot "system-monitor.exe"

function Get-SystemMonitorProcess {
    param(
        [int]$ProcessId,
        [string]$ExpectedExePath
    )

    $proc = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if (-not $proc) {
        return $null
    }

    try {
        $actualPath = $proc.Path
    }
    catch {
        return $null
    }

    if (-not $actualPath) {
        return $null
    }

    if ($actualPath -ieq $ExpectedExePath) {
        return $proc
    }

    return $null
}

if (-not (Test-Path $pidFile)) {
    Write-Host "No PID file found. System Monitor may not be running."
    exit 0
}

$pidValueRaw = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
$pidValue = 0
if (-not $pidValueRaw -or -not [int]::TryParse($pidValueRaw, [ref]$pidValue)) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "PID file was invalid."
    exit 0
}

$proc = Get-SystemMonitorProcess -ProcessId $pidValue -ExpectedExePath $exePath
if ($proc) {
    Stop-Process -Id $pidValue -Force
    Write-Host "System Monitor stopped. PID: $pidValue"
} else {
    Write-Host "Process with PID $pidValue was not the expected system-monitor process."
}

Remove-Item $pidFile -ErrorAction SilentlyContinue
