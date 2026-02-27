param(
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$exePath = Join-Path $repoRoot "system-monitor.exe"
$pidFile = Join-Path $repoRoot "logs\system-monitor.pid"
$stdoutLog = Join-Path $repoRoot "logs\process.out.log"
$stderrLog = Join-Path $repoRoot "logs\process.err.log"
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

New-Item -ItemType Directory -Path (Join-Path $repoRoot "logs") -Force | Out-Null

if (Test-Path $pidFile) {
    $existingPidRaw = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    $existingPid = 0
    if ($existingPidRaw -and [int]::TryParse($existingPidRaw, [ref]$existingPid)) {
        $existingProc = Get-SystemMonitorProcess -ProcessId $existingPid -ExpectedExePath $exePath
        if ($existingProc) {
            Write-Host "System Monitor is already running with PID $existingPid"
            exit 0
        }
    }
    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

if ($Rebuild -or -not (Test-Path $exePath)) {
    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        throw "Go toolchain not found in PATH. Install Go or run .\build\build.ps1 first."
    }

    Push-Location $repoRoot
    try {
        go build -ldflags="-H=windowsgui" -o system-monitor.exe ./cmd/agent
    }
    finally {
        Pop-Location
    }
}

$proc = Start-Process -FilePath $exePath -WorkingDirectory $repoRoot -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog -PassThru
Set-Content -Path $pidFile -Value $proc.Id
Write-Host "System Monitor started. PID: $($proc.Id)"
