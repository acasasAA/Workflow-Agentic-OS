# Show Workflow OS Disaster Recovery v1 status.

[CmdletBinding()]
param(
    [switch]$ListSnapshots
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WosDr.psm1') -Force

$ctx = Get-WosDrContext
$config = Get-WosDrConfig
$backupRoot = Get-WosDrBackupRoot -Context $ctx
$machine = $env:COMPUTERNAME
if (-not $machine) { $machine = 'unknown-machine' }
$snapshotsRoot = Join-Path (Join-Path (Join-Path $backupRoot 'Snapshots') $machine) ''
$latestFile = Join-Path $snapshotsRoot 'latest.json'
$latest = Read-WosDrJsonFile -Path $latestFile
$task = Get-ScheduledTask -TaskName 'Workflow OS DR Snapshot' -ErrorAction SilentlyContinue

$status = [ordered]@{
    configured = [bool]$config
    backup_root = $backupRoot
    frequency = if ($config) { $config.frequency } else { $null }
    project_roots = if ($config) { @($config.project_roots) } else { @() }
    latest_snapshot = if ($latest) { $latest.latest_snapshot } else { $null }
    scheduled_task = if ($task) { $task.State.ToString() } else { $null }
    data_root = $ctx.data_root
}

if ($ListSnapshots) {
    $items = @()
    if (Test-Path -LiteralPath $snapshotsRoot -PathType Container) {
        $items = @(Get-ChildItem -LiteralPath $snapshotsRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            Select-Object -First 20 |
            ForEach-Object { $_.FullName })
    }
    $status.snapshots = $items
}

$status | ConvertTo-Json -Depth 8
