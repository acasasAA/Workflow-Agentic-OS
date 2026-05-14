# Workflow OS preflight check.
# Read-only: reports machine, Codex, and repo readiness before onboarding.

[CmdletBinding()]
param(
    [string]$PreferredRoot,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WosInstall.psm1'
Import-Module $modulePath -Force

$repoResult = Find-WosRepoRoot -PreferredRoot $PreferredRoot
$toolStatus = Get-WosToolStatus

$codexHome = Join-Path $env:USERPROFILE '.codex'
$configPath = Join-Path $codexHome 'config.toml'
$sentinelPath = Join-Path $codexHome 'workflow-os.json'

$configExists = Test-Path -LiteralPath $configPath
$sentinelExists = Test-Path -LiteralPath $sentinelPath
$marketplaceConfigured = $false
$wosBlockPresent = $false

if ($configExists) {
    $configText = Get-Content -LiteralPath $configPath -Raw
    $marketplaceConfigured = ($configText -match '\[marketplaces\.workflow-os\]')
    $wosBlockPresent = ($configText -match '# === Workflow OS managed block')
}

$selectedPath = $null
$nestedWarning = $false
if ($repoResult.selected) {
    $selectedPath = $repoResult.selected.path
    foreach ($candidate in $repoResult.candidates) {
        if ($candidate.valid -and $candidate.path -ne $selectedPath -and $candidate.path -like "$selectedPath*") {
            $nestedWarning = $true
        }
        if ($selectedPath -like "$($candidate.path)*" -and $candidate.path -ne $selectedPath) {
            $nestedWarning = $true
        }
    }
}

$requiredMissing = @()
foreach ($tool in $toolStatus.tools) {
    if (($tool.name -in @('PowerShell 7', 'Codex CLI', 'Git', 'Node.js')) -and $tool.status -eq 'missing') {
        $requiredMissing += $tool.name
    }
}

$report = [ordered]@{
    timestamp = (Get-Date).ToUniversalTime().ToString('o')
    user = $env:USERNAME
    selected_repo = $selectedPath
    repo_candidates = $repoResult.candidates
    nested_repo_warning = $nestedWarning
    tools = $toolStatus.tools
    package_managers = $toolStatus.package_managers
    codex = [ordered]@{
        config_path = $configPath
        config_exists = $configExists
        sentinel_path = $sentinelPath
        sentinel_exists = $sentinelExists
        workflow_os_marketplace_configured = $marketplaceConfigured
        workflow_os_block_present = $wosBlockPresent
    }
    required_missing = $requiredMissing
    ready_for_setup = (($requiredMissing.Count -eq 0) -and ($null -ne $repoResult.selected) -and (-not $repoResult.selected.tracked_dirty))
}

if ($Json) {
    $report | ConvertTo-Json -Depth 8
    exit 0
}

Write-WosSummary "Workflow OS preflight"
Write-WosSummary "User: $env:USERNAME"

if ($repoResult.selected) {
    Write-WosSummary "Using repo: $($repoResult.selected.path)" 'OK'
    if ($repoResult.selected.tracked_dirty) {
        Write-WosSummary "Repo has tracked local changes. Setup should stop to avoid overwriting user work." 'ERROR'
    }
    if ($nestedWarning) {
        Write-WosSummary "Nested or duplicate Workflow OS checkout detected. This is recoverable; setup will use the best valid repo and will not move or delete folders." 'WARN'
    }
} else {
    Write-WosSummary "No valid Workflow OS checkout found." 'ERROR'
}

Write-Host ""
Write-Host "Tools:" -ForegroundColor Cyan
foreach ($tool in $toolStatus.tools) {
    $level = 'OK'
    if ($tool.status -eq 'missing') { $level = 'ERROR' }
    elseif ($tool.status -eq 'installed_not_on_path') { $level = 'WARN' }
    Write-WosSummary "$($tool.name): $($tool.status) - $($tool.note)" $level
}

Write-Host ""
Write-Host "Codex:" -ForegroundColor Cyan
Write-WosSummary "config.toml: $configExists"
Write-WosSummary "workflow-os.json sentinel: $sentinelExists"
Write-WosSummary "workflow-os marketplace configured: $marketplaceConfigured"

if ($report.ready_for_setup) {
    Write-WosSummary "Ready for setup-codex.ps1" 'OK'
} else {
    Write-WosSummary "Not ready yet. Fix required missing tools or tracked repo changes, then rerun preflight." 'WARN'
}
