# Workflow OS — project plugin SessionStart hook
# Auto-resume: if a project is active for this cwd, surface its state +
# last checkpoint + recent session summaries so Codex picks up where the
# user left off — no manual command needed.
#
# Input: JSON on stdin (session_id, cwd, hook_event_name, source, ...)
# Output: plain text on stdout becomes developer context for the session.
# Always exits 0.

$ErrorActionPreference = 'Continue'

# Read cwd from hook input JSON.
$cwd = (Get-Location).Path
try {
    $hookInput = [Console]::In.ReadToEnd()
    if ($hookInput) {
        $parsed = $hookInput | ConvertFrom-Json
        if ($parsed.cwd) { $cwd = $parsed.cwd }
    }
} catch { }

$pluginRoot = Split-Path -Parent $PSScriptRoot
$resolver = Join-Path $pluginRoot 'scripts/active-project.ps1'

$active = & $resolver -Cwd $cwd 2>$null | ConvertFrom-Json
if (-not $active -or -not $active.slug) { exit 0 }   # no active project; silent

$slug = $active.slug

# Emit a structured note for the LLM. The LLM is expected to invoke
# the memory-engine MCP itself (memory.search) to fetch the actual notes —
# we don't fetch them here because hooks shouldn't depend on MCP servers
# being up (chicken/egg on first start), and stdout is added as context
# the model can act on.
@"
[Workflow OS] Active project detected: $slug (source: $($active.source))

To resume context, the model SHOULD call the memory-engine MCP:
  memory_search({ type: "project-state", project: "$slug", limit: 1 })
  memory_search({ type: "checkpoint",     project: "$slug", limit: 1 })
  memory_search({ type: "session-summary", project: "$slug", limit: 3 })

Then summarize the picture in 3-5 bullets before doing anything else this turn.
This is the auto-resume behavior — the user did not type a command.
"@

exit 0
