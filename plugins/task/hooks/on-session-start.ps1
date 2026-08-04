# Workflow OS — task plugin SessionStart hook
# If no project marker is active but local.json has active_task, surface task
# resume context so task agenda work can continue without a manual command.
#
# Input: JSON on stdin (session_id, cwd, hook_event_name, source, ...).
# Output: plain text on stdout becomes developer context for the session.
# Always exits 0.

$ErrorActionPreference = 'Continue'

$cwd = (Get-Location).Path
try {
    $hookInput = [Console]::In.ReadToEnd()
    if ($hookInput) {
        $parsed = $hookInput | ConvertFrom-Json
        if ($parsed.cwd) { $cwd = $parsed.cwd }
    }
} catch { }

function Get-WosMarker {
    param([string]$StartDir)
    try {
        $dir = (Resolve-Path $StartDir).Path
    } catch {
        return $null
    }

    while ($true) {
        $candidate = Join-Path $dir 'WOS.md'
        if (Test-Path $candidate) { return $candidate }
        $parent = Split-Path $dir -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

# Project auto-resume wins. Tasks are fallback context for agenda and one-off work.
if (Get-WosMarker -StartDir $cwd) { exit 0 }

$sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (-not (Test-Path $sentinelPath)) { exit 0 }

try {
    $sentinel = Get-Content $sentinelPath -Raw | ConvertFrom-Json
    if (-not $sentinel.data_root) { exit 0 }
    $localPath = Join-Path $sentinel.data_root '.agent/local.json'
    if (-not (Test-Path $localPath)) { exit 0 }
    $local = Get-Content $localPath -Raw | ConvertFrom-Json
    if (-not $local.active_task) { exit 0 }
    $task = $local.active_task

    @"
[Workflow OS] Active task detected: $task

No project WOS.md marker was found for this cwd, so Workflow OS is surfacing task/agenda context.

To resume context, the model SHOULD call the memory-engine MCP:
  memory_search({ type: "task-state", project: "$task", limit: 1 })

Then summarize the task before doing anything else this turn:
  - if it is an agenda, show the saved agenda table
  - otherwise summarize status, due date, Jira key, blocker/dependency, next action, and whether the user wants a Jira read
"@
} catch { }

exit 0
