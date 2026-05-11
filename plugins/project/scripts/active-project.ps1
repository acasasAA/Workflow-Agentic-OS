# Workflow OS — active-project resolver
# Determines the currently-active project slug from two signals:
#   1. WOS.md marker in cwd or any parent directory (cascading)
#   2. local.json → active_project (fallback)
#
# Output: single JSON line on stdout.
#   { "slug": "<slug>", "source": "marker"|"local"|"none", "marker_dir": "<path-or-null>" }

[CmdletBinding()]
param([string]$Cwd = (Get-Location).Path)

$ErrorActionPreference = 'Continue'

function Get-WosMarker {
    param([string]$StartDir)
    $dir = (Resolve-Path $StartDir).Path
    while ($true) {
        $candidate = Join-Path $dir 'WOS.md'
        if (Test-Path $candidate) { return $candidate }
        $parent = Split-Path $dir -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

function Get-MarkerSlug {
    param([string]$Path)
    try {
        $content = Get-Content $Path -Raw
        # Simple frontmatter extraction. Expects:
        #   ---
        #   project_slug: foo
        #   ---
        if ($content -match '(?ms)^---\s*\r?\n(.*?)\r?\n---') {
            $front = $matches[1]
            if ($front -match '(?m)^project_slug\s*:\s*(\S+)') { return $matches[1] }
        }
    } catch { }
    return $null
}

$slug = $null
$source = 'none'
$markerDir = $null

$marker = Get-WosMarker -StartDir $Cwd
if ($marker) {
    $maybeSlug = Get-MarkerSlug -Path $marker
    if ($maybeSlug) {
        $slug = $maybeSlug
        $source = 'marker'
        $markerDir = Split-Path $marker -Parent
    }
}

if (-not $slug) {
    $sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
    if (Test-Path $sentinelPath) {
        try {
            $s = Get-Content $sentinelPath -Raw | ConvertFrom-Json
            $localPath = Join-Path $s.data_root '.agent/local.json'
            if (Test-Path $localPath) {
                $local = Get-Content $localPath -Raw | ConvertFrom-Json
                if ($local.active_project) {
                    $slug = $local.active_project
                    $source = 'local'
                }
            }
        } catch { }
    }
}

[ordered]@{
    slug       = $slug
    source     = $source
    marker_dir = $markerDir
} | ConvertTo-Json -Compress
