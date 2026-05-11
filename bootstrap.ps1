# Workflow OS — bootstrap installer (v2)
#
# Run this once on a fresh machine after cloning the framework repo.
#
# What it does:
#   1. Validates prereqs (Codex CLI, Node LTS, git).
#   2. Writes ~/.codex/workflow-os.json sentinel pointing at framework_root.
#   3. Installs the global AGENTS.md and AGENTS.override.md (safety rails).
#   4. Writes a minimal block into ~/.codex/config.toml:
#        features.codex_hooks = true
#        project_doc_fallback_filenames += ["WOS.md"]
#   5. Adds this directory as a Codex plugin marketplace.
#   6. Tells the user to install plugins via /plugins and run $welcome.
#
# Idempotent: safe to re-run. Backups existing files before overwriting.

[CmdletBinding()]
param(
    [string]$FrameworkRoot = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

function Fail($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }
function Ok($msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }

Info "Workflow OS bootstrap"
Info "Framework root: $FrameworkRoot"

# ── 1. Prerequisites ───────────────────────────────────────────────────────

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Fail "Codex CLI not found on PATH. Install Codex first, then re-run."
}
Ok "Codex CLI found"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Fail "Node.js not found on PATH. Install Node LTS, then re-run."
}
$nodeVer = (node --version)
Ok "Node $nodeVer"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "git not found on PATH. Install git, then re-run."
}
Ok "git found"

# ── 2. Framework sanity ────────────────────────────────────────────────────

$required = @(
    'AGENTS.md',
    '.agent/system.md',
    '.agent/boundaries.md',
    'marketplace.json',
    'plugins/onboarding/.codex-plugin/plugin.json',
    'plugins/memory-engine/.codex-plugin/plugin.json',
    'plugins/jira/.codex-plugin/plugin.json',
    'plugins/project/.codex-plugin/plugin.json'
)
foreach ($rel in $required) {
    $full = Join-Path $FrameworkRoot $rel
    if (-not (Test-Path $full)) { Fail "Missing framework file: $rel" }
}
Ok "Framework structure looks correct"

# ── 3. Sentinel ────────────────────────────────────────────────────────────

$codexHome = Join-Path $env:USERPROFILE '.codex'
if (-not (Test-Path $codexHome)) { New-Item -ItemType Directory -Path $codexHome | Out-Null }
$sentinel = Join-Path $codexHome 'workflow-os.json'
$sentinelObj = [ordered]@{
    framework_root = $FrameworkRoot
    data_root      = $null
    bootstrap_at   = (Get-Date).ToUniversalTime().ToString('o')
    installed      = $false
}
$sentinelObj | ConvertTo-Json | Set-Content -Path $sentinel -Encoding UTF8
Ok "Wrote sentinel: $sentinel"

# ── 4. Global AGENTS.md and override ───────────────────────────────────────

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $backup = "$path.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $path $backup
        Info "Backed up $path to $backup"
    }
}

$globalAgents = Join-Path $codexHome 'AGENTS.md'
$globalOverride = Join-Path $codexHome 'AGENTS.override.md'

Backup-IfExists $globalAgents
Backup-IfExists $globalOverride

Copy-Item (Join-Path $FrameworkRoot 'AGENTS.md') $globalAgents -Force
Copy-Item (Join-Path $FrameworkRoot '.agent/boundaries.md') $globalOverride -Force
Ok "Installed AGENTS.md and AGENTS.override.md"

# ── 5. Minimal config.toml block ───────────────────────────────────────────

$configPath = Join-Path $codexHome 'config.toml'
$marker = '# === Workflow OS managed block (do not edit between markers) ==='
$endMarker = '# === end Workflow OS managed block ==='

$wosBlock = @"
$marker
# Auto-added by workflow-os/bootstrap.ps1
features.codex_hooks = true
project_doc_fallback_filenames = ["WOS.md"]
$endMarker
"@

if (Test-Path $configPath) {
    $existing = Get-Content $configPath -Raw
    if ($existing -match [regex]::Escape($marker)) {
        # Replace existing block
        $pattern = [regex]::Escape($marker) + '[\s\S]*?' + [regex]::Escape($endMarker)
        $new = [regex]::Replace($existing, $pattern, $wosBlock)
        Set-Content -Path $configPath -Value $new -Encoding UTF8
        Ok "Updated Workflow OS block in config.toml"
    } else {
        Add-Content -Path $configPath -Value "`n$wosBlock`n" -Encoding UTF8
        Ok "Appended Workflow OS block to config.toml"
    }
} else {
    Set-Content -Path $configPath -Value $wosBlock -Encoding UTF8
    Ok "Created config.toml with Workflow OS block"
}

# ── 6. Register marketplace ────────────────────────────────────────────────

Info "Registering Codex plugin marketplace at $FrameworkRoot"
try {
    & codex plugin marketplace add $FrameworkRoot
    if ($LASTEXITCODE -ne 0) {
        Info "codex plugin marketplace add returned exit $LASTEXITCODE — may already be registered. Continuing."
    } else {
        Ok "Marketplace registered"
    }
} catch {
    Info "codex plugin marketplace add failed: $_. You can register manually after bootstrap completes."
}

# ── 7. Done ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Bootstrap complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open a new Codex session (so it loads the global AGENTS.md and the new config)."
Write-Host "  2. Type:  /plugins"
Write-Host "     Install at minimum:  wos-onboarding"
Write-Host "     (Onboarding will offer to install the other three for you.)"
Write-Host "  3. Type:  `$welcome"
Write-Host "  4. Answer the onboarding questions. Workflow OS data will be created."
Write-Host ""
