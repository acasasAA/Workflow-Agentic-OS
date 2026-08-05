# Create a Workflow OS Disaster Recovery v1 snapshot.

[CmdletBinding()]
param(
    [string]$BackupRoot,
    [string[]]$ProjectsRoot = @(),
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WosDr.psm1') -Force

$ctx = Get-WosDrContext
$backupRoot = Get-WosDrBackupRoot -Context $ctx -Override $BackupRoot
$machine = $env:COMPUTERNAME
if (-not $machine) { $machine = 'unknown-machine' }
$stamp = Get-WosDrTimestamp
$snapshotRoot = Join-Path (Join-Path (Join-Path $backupRoot 'Snapshots') $machine) $stamp
New-Item -ItemType Directory -Path $snapshotRoot -Force | Out-Null

$warnings = @()
$included = @()

if (Copy-WosDrFileIfPresent -Source $ctx.sentinel_path -Destination (Join-Path $snapshotRoot 'codex/workflow-os.json')) {
    $included += 'codex/workflow-os.json'
} else { $warnings += "Missing sentinel: $($ctx.sentinel_path)" }

if (Copy-WosDrFileIfPresent -Source $ctx.local_path -Destination (Join-Path $snapshotRoot 'data/.agent/local.json')) {
    $included += 'data/.agent/local.json'
} else { $warnings += "Missing local state: $($ctx.local_path)" }

$memoryDir = Join-Path $ctx.data_root '.index'
$memoryFiles = @('memory.db', 'memory.db-wal', 'memory.db-shm')
foreach ($file in $memoryFiles) {
    $source = Join-Path $memoryDir $file
    $dest = Join-Path $snapshotRoot ("data/.index/$file")
    if (Copy-WosDrFileIfPresent -Source $source -Destination $dest) {
        $included += "data/.index/$file"
    } elseif ($file -eq 'memory.db') {
        $warnings += "Missing memory database: $source"
    }
}

$userMemory = Join-Path $ctx.data_root 'memory'
if (Test-Path -LiteralPath $userMemory -PathType Container) {
    $dest = Join-Path $snapshotRoot 'data/memory'
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -LiteralPath $userMemory -Destination (Join-Path $snapshotRoot 'data') -Recurse -Force
    $included += 'data/memory'
}

$projectRoots = @(Get-WosDrProjectRoots -Context $ctx -OverrideRoots $ProjectsRoot)
$markers = @(Get-WosDrProjectMarkers -ProjectRoots $projectRoots)
$markerRoot = Join-Path $snapshotRoot 'project-markers'
foreach ($marker in $markers) {
    $safeRel = ($marker.relative_path -replace '[:*?"<>|]', '_')
    $dest = Join-Path $markerRoot $safeRel
    Copy-WosDrFileIfPresent -Source $marker.marker_path -Destination $dest | Out-Null
}

$checksums = @()
Get-ChildItem -LiteralPath $snapshotRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne 'manifest.json' -and $_.Name -ne 'checksums.sha256' } |
    ForEach-Object {
        $rel = [System.IO.Path]::GetRelativePath($snapshotRoot, $_.FullName)
        $checksums += [ordered]@{
            path = $rel
            sha256 = Get-WosDrSha256 -Path $_.FullName
        }
    }

$manifest = [ordered]@{
    schema = 'wos-dr-snapshot-v1'
    created = (Get-Date).ToUniversalTime().ToString('o')
    wos_dr_version = '0.1.0'
    machine = $machine
    user = $env:USERNAME
    data_root = $ctx.data_root
    framework_root = $ctx.sentinel.framework_root
    backup_root = $backupRoot
    snapshot_path = $snapshotRoot
    included = $included
    project_roots = $projectRoots
    project_markers = $markers
    project_structures = @(Get-WosDrProjectStructure -ProjectRoots $projectRoots)
    plugin_versions = @(Get-WosDrPluginVersions)
    warnings = $warnings
}

Write-WosDrJsonFile -Value $manifest -Path (Join-Path $snapshotRoot 'manifest.json')
($checksums | ForEach-Object { "$($_.sha256)  $($_.path)" }) | Set-Content -LiteralPath (Join-Path $snapshotRoot 'checksums.sha256') -Encoding UTF8

$latestPath = Join-Path (Join-Path $backupRoot 'Snapshots') $machine
New-Item -ItemType Directory -Force -Path $latestPath | Out-Null
Write-WosDrJsonFile -Value ([ordered]@{ latest_snapshot = $snapshotRoot; updated = (Get-Date).ToUniversalTime().ToString('o') }) -Path (Join-Path $latestPath 'latest.json')

if (-not $Quiet) {
    Write-Host "WOS DR snapshot created: $snapshotRoot"
    Write-Host "Project markers: $($markers.Count)"
    if ($warnings.Count -gt 0) {
        Write-Host "Warnings:"
        foreach ($warning in $warnings) { Write-Host "- $warning" }
    }
}

[pscustomobject]@{
    snapshot_path = $snapshotRoot
    project_markers = $markers.Count
    warnings = $warnings
}
