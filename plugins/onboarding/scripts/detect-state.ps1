# Workflow OS — onboarding state detector
# Reports whether Workflow OS data is installed, partial, or missing.
# Used by the welcome prompt before it asks any questions.
#
# Output: single JSON line on stdout.
#   { "state": "installed" | "partial" | "missing",
#     "data_root": "<path-or-null>",
#     "present": [ "<relative paths found>" ],
#     "missing": [ "<relative paths absent>" ] }

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
    'vault'
)

$present = @()
$missing = @()
foreach ($rel in $required) {
    $full = Join-Path $dataRoot $rel
    if (Test-Path $full) { $present += $rel } else { $missing += $rel }
}

$state = 'missing'
if ($present.Count -eq $required.Count) { $state = 'installed' }
elseif ($present.Count -gt 0)            { $state = 'partial' }

$result = [ordered]@{
    state     = $state
    data_root = if (Test-Path $dataRoot) { $dataRoot } else { $null }
    present   = $present
    missing   = $missing
}

$result | ConvertTo-Json -Compress
