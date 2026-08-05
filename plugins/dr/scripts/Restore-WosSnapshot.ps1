# Restore Workflow OS-owned state from a Disaster Recovery v1 snapshot.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SnapshotPath,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WosDr.psm1') -Force

if (-not (Test-Path -LiteralPath $SnapshotPath -PathType Container)) {
    throw "Snapshot path not found: $SnapshotPath"
}

$manifestPath = Join-Path $SnapshotPath 'manifest.json'
$manifest = Read-WosDrJsonFile -Path $manifestPath
if (-not $manifest -or $manifest.schema -ne 'wos-dr-snapshot-v1') {
    throw "Not a WOS DR v1 snapshot: $SnapshotPath"
}

$ctx = Get-WosDrContext
$currentBackupRoot = Join-Path $ctx.data_root ('.logs/dr-restore-backup-' + (Get-WosDrTimestamp))
New-Item -ItemType Directory -Force -Path $currentBackupRoot | Out-Null

Write-Host "Snapshot: $SnapshotPath"
Write-Host "Current state backup: $currentBackupRoot"
Write-Host "This will restore WOS-owned sentinel, local state, and memory database files."
Write-Host "It will not restore Codex private chat/sidebar sessions."

if (-not $Yes) {
    $answer = Read-Host "Type RESTORE to continue"
    if ($answer -ne 'RESTORE') {
        Write-Host "Restore cancelled."
        exit 1
    }
}

$restorePairs = @(
    @{ Source = 'codex/workflow-os.json'; Destination = $ctx.sentinel_path },
    @{ Source = 'data/.agent/local.json'; Destination = $ctx.local_path },
    @{ Source = 'data/.index/memory.db'; Destination = (Join-Path $ctx.data_root '.index/memory.db') },
    @{ Source = 'data/.index/memory.db-wal'; Destination = (Join-Path $ctx.data_root '.index/memory.db-wal') },
    @{ Source = 'data/.index/memory.db-shm'; Destination = (Join-Path $ctx.data_root '.index/memory.db-shm') }
)

foreach ($pair in $restorePairs) {
    $src = Join-Path $SnapshotPath $pair.Source
    $dest = $pair.Destination
    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { continue }
    if (Test-Path -LiteralPath $dest -PathType Leaf) {
        $backupDest = Join-Path $currentBackupRoot ($pair.Source -replace '/', '\')
        Copy-WosDrFileIfPresent -Source $dest -Destination $backupDest | Out-Null
    }
    Copy-WosDrFileIfPresent -Source $src -Destination $dest | Out-Null
}

$memorySnapshot = Join-Path $SnapshotPath 'data/memory'
if (Test-Path -LiteralPath $memorySnapshot -PathType Container) {
    $memoryDest = Join-Path $ctx.data_root 'memory'
    if (Test-Path -LiteralPath $memoryDest -PathType Container) {
        $backupMemory = Join-Path $currentBackupRoot 'data/memory'
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backupMemory) | Out-Null
        Copy-Item -LiteralPath $memoryDest -Destination (Split-Path -Parent $backupMemory) -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $memoryDest | Out-Null
    Get-ChildItem -LiteralPath $memorySnapshot -Force | Copy-Item -Destination $memoryDest -Recurse -Force
}

Write-Host "WOS DR restore complete."
Write-Host "Fully close and reopen Codex before continuing."
