# Workflow OS DR helpers. Keep this ASCII-safe for Windows PowerShell parsing.

$script:WosDrVersion = '0.1.0'

function Get-WosDrTimestamp {
    (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
}

function Get-WosDrSentinelPath {
    Join-Path $env:USERPROFILE '.codex/workflow-os.json'
}

function Read-WosDrJsonFile {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-WosDrJsonFile {
    param(
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$true)][string]$Path
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $json = $Value | ConvertTo-Json -Depth 12
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
}

function Get-WosDrContext {
    $sentinelPath = Get-WosDrSentinelPath
    $sentinel = Read-WosDrJsonFile -Path $sentinelPath
    if (-not $sentinel) { throw "Workflow OS sentinel not found at $sentinelPath" }
    if (-not $sentinel.data_root) { throw "Workflow OS sentinel is missing data_root" }

    $dataRoot = [string]$sentinel.data_root
    $localPath = Join-Path $dataRoot '.agent/local.json'
    $local = Read-WosDrJsonFile -Path $localPath
    if (-not $local) { throw "Workflow OS local state not found at $localPath" }

    [pscustomobject]@{
        sentinel_path = $sentinelPath
        sentinel = $sentinel
        data_root = $dataRoot
        local_path = $localPath
        local = $local
    }
}

function Get-WosDrOneDriveRoot {
    param($LocalState)

    $candidates = @()
    if ($LocalState.onedrive_backup) { $candidates += [string]$LocalState.onedrive_backup }
    foreach ($name in 'OneDriveCommercial', 'OneDriveConsumer', 'OneDrive') {
        $value = [Environment]::GetEnvironmentVariable($name)
        if ($value) { $candidates += $value }
    }
    $profile = $env:USERPROFILE
    if ($profile) {
        $candidates += (Join-Path $profile 'OneDrive - Athens')
        $candidates += (Join-Path $profile 'OneDrive')
    }

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Container)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

function Get-WosDrConfig {
    $ctx = Get-WosDrContext
    $state = $ctx.local.plugin_state
    if (-not $state) { return $null }
    return $state.'wos-dr'
}

function Set-WosDrConfig {
    param(
        [Parameter(Mandatory=$true)][string]$BackupRoot,
        [string]$Frequency = 'Weekly',
        [string[]]$ProjectRoots = @(),
        [int]$RetentionCount = 12
    )

    $ctx = Get-WosDrContext
    if (-not $ctx.local.plugin_state) {
        $ctx.local | Add-Member -NotePropertyName plugin_state -NotePropertyValue ([pscustomobject]@{}) -Force
    }

    $config = [ordered]@{
        version = $script:WosDrVersion
        enabled = $true
        backup_root = $BackupRoot
        frequency = $Frequency
        project_roots = @($ProjectRoots)
        retention_count = $RetentionCount
        setup_completed_at = (Get-Date).ToUniversalTime().ToString('o')
    }

    $ctx.local.plugin_state | Add-Member -NotePropertyName 'wos-dr' -NotePropertyValue $config -Force
    Write-WosDrJsonFile -Value $ctx.local -Path $ctx.local_path
    return $config
}

function Get-WosDrBackupRoot {
    param($Context, [string]$Override)

    if ($Override) { return $Override }
    $config = $Context.local.plugin_state.'wos-dr'
    if ($config -and $config.backup_root) { return [string]$config.backup_root }

    $oneDrive = Get-WosDrOneDriveRoot -LocalState $Context.local
    if ($oneDrive) { return (Join-Path $oneDrive 'Workflow OS Backups') }

    return (Join-Path $Context.data_root 'onedrive_backup/Workflow OS Backups')
}

function Get-WosDrProjectRoots {
    param($Context, [string[]]$OverrideRoots = @())

    $roots = @()
    if ($OverrideRoots) { $roots += $OverrideRoots }
    $config = $Context.local.plugin_state.'wos-dr'
    if ($config -and $config.project_roots) { $roots += @($config.project_roots) }

    $unique = @()
    foreach ($root in $roots) {
        if (-not $root) { continue }
        if (Test-Path -LiteralPath $root -PathType Container) {
            $resolved = (Resolve-Path -LiteralPath $root).Path
            if ($unique -notcontains $resolved) { $unique += $resolved }
        }
    }
    return $unique
}

function Get-WosDrPluginVersions {
    $cacheRoot = Join-Path $env:USERPROFILE '.codex/plugins/cache/workflow-os'
    $versions = @()
    if (Test-Path -LiteralPath $cacheRoot) {
        Get-ChildItem -LiteralPath $cacheRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $pluginName = $_.Name
            Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $manifest = Join-Path $_.FullName '.codex-plugin/plugin.json'
                if (Test-Path -LiteralPath $manifest) {
                    try {
                        $json = Read-WosDrJsonFile -Path $manifest
                        $versions += [ordered]@{
                            name = $json.name
                            version = $json.version
                            path = $_.FullName
                        }
                    } catch {
                        $versions += [ordered]@{
                            name = $pluginName
                            version = $_.Name
                            path = $_.FullName
                            warning = $_.Exception.Message
                        }
                    }
                }
            }
        }
    }
    return $versions
}

function Get-WosDrProjectMarkers {
    param([string[]]$ProjectRoots = @())

    $markers = @()
    foreach ($root in $ProjectRoots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        Get-ChildItem -LiteralPath $root -Recurse -Filter 'WOS.md' -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|\.venv|venv|dist|build)\\' } |
            ForEach-Object {
                $markers += [ordered]@{
                    marker_path = $_.FullName
                    project_folder = Split-Path -Parent $_.FullName
                    relative_path = [System.IO.Path]::GetRelativePath($root, $_.FullName)
                    root = $root
                }
            }
    }
    return $markers
}

function Get-WosDrProjectStructure {
    param(
        [string[]]$ProjectRoots = @(),
        [int]$MaxItemsPerRoot = 5000
    )

    $excludedSegmentPattern = '\\(node_modules|\.git|\.venv|venv|dist|build|bin|obj|\.next|coverage)\\'
    $structures = @()
    foreach ($root in $ProjectRoots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        $items = @()
        $truncated = $false
        $count = 0
        Get-ChildItem -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $excludedSegmentPattern } |
            ForEach-Object {
                if ($count -ge $MaxItemsPerRoot) {
                    $truncated = $true
                    return
                }
                $count += 1
                $items += [ordered]@{
                    kind = if ($_.PSIsContainer) { 'directory' } else { 'file' }
                    relative_path = [System.IO.Path]::GetRelativePath($root, $_.FullName)
                    length = if ($_.PSIsContainer) { $null } else { $_.Length }
                    last_write_time_utc = $_.LastWriteTimeUtc.ToString('o')
                }
            }

        $structures += [ordered]@{
            root = $root
            item_count = $items.Count
            truncated = $truncated
            excluded_segments = @('node_modules', '.git', '.venv', 'venv', 'dist', 'build', 'bin', 'obj', '.next', 'coverage')
            items = $items
        }
    }
    return $structures
}

function Copy-WosDrFileIfPresent {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    if (Test-Path -LiteralPath $Source -PathType Leaf) {
        $dir = Split-Path -Parent $Destination
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        return $true
    }
    return $false
}

function Get-WosDrSha256 {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $null
}
