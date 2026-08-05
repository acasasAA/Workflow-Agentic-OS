# Workflow OS — onboarding state detector
# Reports whether Workflow OS data is installed, partial, or missing.
# Used by the welcome prompt before it asks any questions.
#
# Output: single JSON line on stdout.
#   { "state": "installed" | "partial" | "missing",
#     "data_root": "<path-or-null>",
#     "present": [ "<relative paths found>" ],
#     "missing": [ "<relative paths absent>" ],
#     "setup_missing": [ "<mandatory setup keys absent>" ] }

$ErrorActionPreference = 'Stop'

$dataRoot = $null
$sentinel = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (Test-Path $sentinel) {
    try {
        $sCfg = Get-Content $sentinel -Raw | ConvertFrom-Json
        if ($sCfg.data_root) { $dataRoot = $sCfg.data_root }
    } catch { }
}
if (-not $dataRoot -and $env:WOS_DATA_ROOT) { $dataRoot = $env:WOS_DATA_ROOT }
if (-not $dataRoot) { $dataRoot = Join-Path $env:USERPROFILE 'workflow-os-data' }

$required = @(
    '.agent/local.json',
    'memory/users',
    '.index'
)

$mandatorySetup = @(
    'plugin_state.wos-jira.setup_completed_at',
    'plugin_state.wos-documentation.setup_completed_at',
    'plugin_state.wos-dr.setup_completed_at'
)

$present = @()
$missing = @()
foreach ($rel in $required) {
    $full = Join-Path $dataRoot $rel
    if (Test-Path $full) { $present += $rel } else { $missing += $rel }
}

$setupMissing = @()
$optionalPlugins = @()
if (Test-Path (Join-Path $dataRoot '.agent/local.json')) {
    try {
        $local = Get-Content (Join-Path $dataRoot '.agent/local.json') -Raw | ConvertFrom-Json
        if ($local.optional_plugins_selected) { $optionalPlugins = @($local.optional_plugins_selected) }
        foreach ($key in $mandatorySetup) {
            if ($key -eq 'plugin_state.wos-jira.setup_completed_at') {
                if (-not $local.plugin_state.'wos-jira'.setup_completed_at) { $setupMissing += $key }
            } elseif ($key -eq 'plugin_state.wos-documentation.setup_completed_at') {
                if (-not $local.plugin_state.'wos-documentation'.setup_completed_at) { $setupMissing += $key }
            } elseif ($key -eq 'plugin_state.wos-dr.setup_completed_at') {
                if (-not $local.plugin_state.'wos-dr'.setup_completed_at) { $setupMissing += $key }
            }
        }
    } catch {
        $setupMissing += $mandatorySetup
    }
} else {
    $setupMissing += $mandatorySetup
}

if ($optionalPlugins -contains 'wos-memory-engine') {
    $memoryDb = Join-Path $dataRoot '.index/memory.db'
    if (Test-Path $memoryDb) {
        if ($present -notcontains '.index/memory.db') { $present += '.index/memory.db' }
    } else {
        $missing += '.index/memory.db'
    }
}

$state = 'missing'
if (($present.Count -eq $required.Count) -and ($setupMissing.Count -eq 0)) { $state = 'installed' }
elseif ($present.Count -gt 0)            { $state = 'partial' }

$result = [ordered]@{
    state     = $state
    data_root = if (Test-Path $dataRoot) { $dataRoot } else { $null }
    present   = $present
    missing   = $missing
    setup_missing = $setupMissing
}

$result | ConvertTo-Json -Compress
