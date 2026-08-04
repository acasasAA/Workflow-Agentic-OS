# Workflow OS — onboarding SessionStart hook
# Fires on every session startup. If install is not complete, nudges the user
# toward running the welcome prompt. Stays silent otherwise.
#
# Input: JSON on stdin (session_id, cwd, hook_event_name, source, ...)
# Output: plain text on stdout is added as developer context. Exit 0 always.

$ErrorActionPreference = 'Stop'

# Read sentinel written by bootstrap.ps1 for the authoritative data_root.
# Fall back to env var and the default location.
$candidates = @()
$sentinel = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (Test-Path $sentinel) {
    try {
        $sCfg = Get-Content $sentinel -Raw | ConvertFrom-Json
        if ($sCfg.data_root) { $candidates += $sCfg.data_root }
    } catch { }
}
if ($env:WOS_DATA_ROOT) { $candidates += $env:WOS_DATA_ROOT }
$candidates += (Join-Path $env:USERPROFILE 'workflow-os-data')

$installed = $false
$setupMissing = @()
foreach ($root in $candidates) {
    $marker = Join-Path $root '.agent/local.json'
    $indexDir = Join-Path $root '.index'
    $memoryDb = Join-Path $root '.index/memory.db'
    if (Test-Path $marker) {
        try {
            $cfg = Get-Content $marker -Raw | ConvertFrom-Json
            $state = $cfg.plugin_state.'wos-onboarding'
            $jiraSetup = $cfg.plugin_state.'wos-jira'.setup_completed_at
            $documentationSetup = $cfg.plugin_state.'wos-documentation'.setup_completed_at
            $optionalPlugins = @()
            if ($cfg.optional_plugins_selected) { $optionalPlugins = @($cfg.optional_plugins_selected) }
            $missingForRoot = @()
            if (-not $jiraSetup) { $missingForRoot += 'wos-jira setup' }
            if (-not $documentationSetup) { $missingForRoot += 'wos-documentation setup' }
            if (($optionalPlugins -contains 'wos-memory-engine') -and -not (Test-Path $memoryDb)) {
                $missingForRoot += 'wos-memory-engine verification'
            }
            if ($state -and $state.disabled -eq $true -and (Test-Path $indexDir) -and $missingForRoot.Count -eq 0) {
                $installed = $true
                break
            } elseif ($state -or (Test-Path $indexDir)) {
                $setupMissing = $missingForRoot
            }
        } catch {
            # malformed local.json — treat as not installed
        }
    }
}

if (-not $installed) {
    if ($setupMissing.Count -gt 0) {
        $missingText = ($setupMissing -join ', ')
        @"
[Workflow OS] Setup is not complete.
Finish mandatory setup before continuing: $missingText.
Run `$welcome`; if Jira or Documentation asks for setup, finish `$jira-setup` and `$documentation-setup`.
"@
        exit 0
    }

    @"
[Workflow OS] Not yet installed on this machine.
Run the onboarding skill: type `$welcome` to begin setup.
"@
}

exit 0
