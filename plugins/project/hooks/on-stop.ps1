# Workflow OS — project plugin Stop hook
# Auto-checkpoint: after every turn, if a project is active, write a
# session-summary receipt via the memory-engine MCP.
#
# Strategy: we can't call MCP servers from a hook directly (no client
# library available in PowerShell, and adding one would bloat the hook).
# Instead, we emit a directive on stdout that the LLM follows on the NEXT
# turn. For Stop hooks specifically, this is fine because the user only
# sees the directive if Codex auto-continues — and a Stop hook returning
# plain text just adds it as context, not a forced continuation.
#
# Alternative implementation note: a fuller version would shell out to a
# small Node helper at ${plugin_root}/scripts/write-summary.mjs that
# spawns the memory-engine MCP server's stdio, sends a memory_write, and
# exits. Deferred to v0.2 — adds a dependency on the MCP server being
# discoverable from a hook context, which is an extra moving part.
#
# v0.1 behavior: just append a one-line note to a daily log file. The
# LLM/user can run a periodic compaction to convert these into proper
# session-summary memory receipts.

$ErrorActionPreference = 'Continue'

# Read hook input.
$cwd = (Get-Location).Path
$turnId = ''
try {
    $hookInput = [Console]::In.ReadToEnd()
    if ($hookInput) {
        $parsed = $hookInput | ConvertFrom-Json
        if ($parsed.cwd)     { $cwd = $parsed.cwd }
        if ($parsed.turn_id) { $turnId = $parsed.turn_id }
    }
} catch { }

# Resolve active project.
$pluginRoot = Split-Path -Parent $PSScriptRoot
$resolver = Join-Path $pluginRoot 'scripts/active-project.ps1'
$active = & $resolver -Cwd $cwd 2>$null | ConvertFrom-Json
if (-not $active -or -not $active.slug) { exit 0 }

# Resolve data_root.
$sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (-not (Test-Path $sentinelPath)) { exit 0 }
$sentinel = Get-Content $sentinelPath -Raw | ConvertFrom-Json
$dataRoot = $sentinel.data_root
if (-not $dataRoot) { exit 0 }

# Append a marker to the daily log. A compaction pass (future skill) will
# fold these into proper session-summary memory receipts.
$logsDir = Join-Path $dataRoot ".logs/wos-project/$($active.slug)"
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
$today = Get-Date -Format 'yyyy-MM-dd'
$logFile = Join-Path $logsDir "$today.jsonl"

$entry = [ordered]@{
    ts      = (Get-Date).ToUniversalTime().ToString('o')
    turn_id = $turnId
    project = $active.slug
    cwd     = $cwd
    note    = "turn-stop"
} | ConvertTo-Json -Compress

Add-Content -Path $logFile -Value $entry -Encoding UTF8

exit 0
