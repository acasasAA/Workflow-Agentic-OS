# Workflow OS Codex setup.
# Mutates only WOS-owned Codex config sections, sentinel, AGENTS files, and marketplace registration.

[CmdletBinding()]
param(
    [string]$PreferredRoot,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WosInstall.psm1'
Import-Module $modulePath -Force

$repoResult = Find-WosRepoRoot -PreferredRoot $PreferredRoot
if (-not $repoResult.selected) {
    Write-WosSummary "No valid Workflow OS repo found. Cannot continue." 'ERROR'
    exit 1
}

$frameworkRoot = $repoResult.selected.path
if ($repoResult.selected.tracked_dirty) {
    Write-WosSummary "Selected repo has tracked local changes. Stop and review before setup: $frameworkRoot" 'ERROR'
    exit 1
}

Write-WosSummary "Workflow OS setup will use: $frameworkRoot" 'OK'

foreach ($candidate in $repoResult.candidates) {
    if ($candidate.valid -and $candidate.path -ne $frameworkRoot) {
        Write-WosSummary "Additional valid checkout detected and ignored: $($candidate.path)" 'WARN'
    }
}

if (-not $Yes) {
    Write-Host ""
    Write-Host "Workflow OS needs temporary install access so it can:" -ForegroundColor Yellow
    Write-Host "- write Codex configuration"
    Write-Host "- register the Workflow OS plugin marketplace"
    Write-Host "- install global AGENTS safety files"
    Write-Host "- create the local Workflow OS sentinel"
    Write-Host ""
    Write-Host "This does not bypass Jira delete protections, email/send guardrails, or no-auto-commit rules."
    $answer = Read-Host "Type SETUP to continue"
    if ($answer -ne 'SETUP') {
        Write-WosSummary "Setup cancelled by user." 'WARN'
        exit 1
    }
}

$codexHome = Join-Path $env:USERPROFILE '.codex'
if (-not (Test-Path -LiteralPath $codexHome)) {
    New-Item -ItemType Directory -Path $codexHome -Force | Out-Null
}

$sentinelPath = Join-Path $codexHome 'workflow-os.json'
$sentinel = [ordered]@{
    framework_root = $frameworkRoot
    data_root = $null
    bootstrap_at = (Get-Date).ToUniversalTime().ToString('o')
    installed = $false
}
$sentinel | ConvertTo-Json | Set-Content -LiteralPath $sentinelPath -Encoding UTF8
Write-WosSummary "Wrote sentinel: $sentinelPath" 'OK'

foreach ($pair in @(
    @{ source = 'AGENTS.md'; target = 'AGENTS.md' },
    @{ source = '.agent/boundaries.md'; target = 'AGENTS.override.md' }
)) {
    $sourcePath = Join-Path $frameworkRoot $pair.source
    $targetPath = Join-Path $codexHome $pair.target
    if (Test-Path -LiteralPath $targetPath) {
        $backupPath = "$targetPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $targetPath -Destination $backupPath -Force
        Write-WosSummary "Backed up $targetPath to $backupPath"
    }
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    Write-WosSummary "Installed $($pair.target)" 'OK'
}

$marketplace = Get-WosMarketplaceSource -FrameworkRoot $frameworkRoot
$templatePath = Join-Path $frameworkRoot 'templates/codex/config.wos.toml'
$merge = Merge-WosCodexConfig -ConfigPath (Join-Path $codexHome 'config.toml') -TemplatePath $templatePath -MarketplaceSource $marketplace.source -MarketplaceRef $marketplace.ref
if ($merge.backup_path) { Write-WosSummary "Backed up Codex config to $($merge.backup_path)" }
Write-WosSummary "Merged WOS Codex config for marketplace $($merge.marketplace_source) ref $($merge.marketplace_ref)" 'OK'

$codex = Get-Command codex -ErrorAction SilentlyContinue
if ($codex) {
    try {
        & codex plugin marketplace remove workflow-os 2>$null | Out-Null
    } catch { }
    if ($marketplace.ref) {
        & codex plugin marketplace add $marketplace.source --ref $marketplace.ref
    } else {
        & codex plugin marketplace add $marketplace.source
    }
    if ($LASTEXITCODE -eq 0) {
        Write-WosSummary "Registered workflow-os marketplace through Codex CLI" 'OK'
    } else {
        Write-WosSummary "Codex marketplace add returned exit $LASTEXITCODE. Config was still merged; restart Codex and check /plugins." 'WARN'
    }
} else {
    Write-WosSummary "Codex CLI not on PATH. Config was merged; install/fix Codex CLI before opening /plugins." 'WARN'
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Fully close and reopen Codex."
Write-Host "2. Open /plugins."
Write-Host "3. Install wos-onboarding from workflow-os."
Write-Host '4. Run: $welcome'
