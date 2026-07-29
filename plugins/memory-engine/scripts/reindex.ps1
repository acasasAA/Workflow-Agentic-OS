# Workflow OS — memory-engine legacy markdown import script
#
# Imports existing markdown memory notes into <data_root>/.index/memory.db.
# SQLite is the canonical memory store; this is a migration/compatibility bridge.
#
# Discovery: reads ~/.codex/workflow-os.json for data_root.

[CmdletBinding()]
param(
    [switch]$Force,
    [string]$LegacyVault
)

$ErrorActionPreference = 'Stop'

$sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (-not (Test-Path $sentinelPath)) { throw "sentinel not found at $sentinelPath; run bootstrap.ps1 first" }
$sentinel = Get-Content $sentinelPath -Raw | ConvertFrom-Json
$dataRoot = $sentinel.data_root
if (-not $dataRoot) { throw "sentinel has no data_root" }

$indexDir = Join-Path $dataRoot '.index'
$indexDb  = Join-Path $indexDir 'memory.db'

if (-not (Test-Path $indexDir)) { New-Item -ItemType Directory -Path $indexDir | Out-Null }

if ((Test-Path $indexDb) -and $Force) {
    Remove-Item $indexDb -Force
    Write-Host "Removed existing index"
}

# Shell out to a small Node helper that uses the same DB schema as the MCP server.
$framework = $sentinel.framework_root
if (-not $framework) { throw "sentinel has no framework_root" }
$reindexer = Join-Path $framework 'plugins/memory-engine/mcp/reindex.js'
if (-not (Test-Path $reindexer)) { throw "reindexer not found at $reindexer" }

$env:WOS_LEGACY_VAULT = if ($LegacyVault) { $LegacyVault } else { $null }
Write-Host "Importing legacy markdown memory into $indexDb"
node $reindexer
Write-Host "Done."
