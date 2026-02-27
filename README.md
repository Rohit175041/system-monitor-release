# System Monitor (Windows, Go)

Windows desktop system monitor with tray UI, periodic metrics collection, local HTTP metrics, rotating logs, and crash logging.

## Features

- CPU, memory, disk, battery, and network sampling
- Async JSON and CSV metric logging
- Size-based log rotation (`.1`, `.2`, ...)
- Dedicated crash/error log file
- Tray status display with live values
- GUI build by default (no console window on launch)
- HTTP endpoints:
  - `GET /metrics`
  - `GET /health`

## Requirements

- Windows
- Go 1.22+ (or compatible with your `go.mod`)

## Build

From repo root:

```powershell
.\build\build.ps1
```

Useful options:

```powershell
.\build\build.ps1 -RunTests -Clean
.\build\build.ps1 -Output system-monitor-dev.exe
.\build\build.ps1 -NoGui
```

Output binary is created in repo root (default: `system-monitor.exe`).
Default build mode is GUI (`-ldflags=-H=windowsgui`).

## Run / Stop

Start with script (recommended):

```powershell
.\build\start.ps1
```

Start and rebuild first:

```powershell
.\build\start.ps1 -Rebuild
```

Stop:

```powershell
.\build\stop.ps1
```

## Logs

Default log files:

- `logs/system_metrics.log` (JSON metrics)
- `logs/system_metrics.csv` (CSV metrics)
- `logs/system_crash.log` (application errors/panics)
- `logs/process.out.log` (process stdout from `start.ps1`)
- `logs/process.err.log` (process stderr from `start.ps1`)
- `logs/system-monitor.pid` (PID file for stop script)

Rotation is controlled by:

- `log_max_size_mb`
- `log_max_backups`

When size limit is reached, files rotate to `*.1`, `*.2`, etc.

## Configuration

Config file: `configs/config_windows.json`

Main keys:

- `log_interval_sec`
- `tray_refresh_sec`
- `json_log_file`
- `csv_log_file`
- `crash_log_file`
- `log_max_size_mb`
- `log_max_backups`
- `battery_alert_percent`
- `cpu_alert_percent`
- `http_port`

## Project Structure

```text
system-monitor-windows/
|-- cmd/agent/main_windows.go
|-- configs/config_windows.json
|-- internal/
|   |-- alerts/
|   |-- autostart/
|   |-- collector/
|   |-- config/
|   |-- logger/
|   |-- model/
|   `-- server/
|-- build/
|   |-- build.ps1
|   |-- start.ps1
|   `-- stop.ps1
`-- logs/
```
