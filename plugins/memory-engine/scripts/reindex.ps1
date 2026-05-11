# Workflow OS — memory-engine reindex script
#
# Rebuilds <data_root>/.index/memory.db from the markdown vault.
# Use this for DR (lost index) or schema migrations.
#
# Discovery: reads ~/.codex/workflow-os.json for data_root.

[CmdletBinding()]
param([switch]$Force)

$ErrorActionPreference = 'Stop'

$sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (-not (Test-Path $sentinelPath)) { throw "sentinel not found at $sentinelPath; run bootstrap.ps1 first" }
$sentinel = Get-Content $sentinelPath -Raw | ConvertFrom-Json
$dataRoot = $sentinel.data_root
if (-not $dataRoot) { throw "sentinel has no data_root" }

$vault    = Join-Path $dataRoot 'vault'
$indexDir = Join-Path $dataRoot '.index'
$indexDb  = Join-Path $indexDir 'memory.db'

if (-not (Test-Path $vault)) { throw "vault not found at $vault" }
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

Write-Host "Reindexing vault: $vault"
node $reindexer
Write-Host "Done."
