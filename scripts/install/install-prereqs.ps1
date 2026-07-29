# Workflow OS prerequisite installer.
# Uses winget first, Chocolatey fallback. Nothing installs without confirmation.

[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WosInstall.psm1'
Import-Module $modulePath -Force

$toolStatus = Get-WosToolStatus
$winget = Get-Command winget -ErrorAction SilentlyContinue
$choco = Get-Command choco -ErrorAction SilentlyContinue

$packages = @{
    'PowerShell 7' = @{ winget = 'Microsoft.PowerShell'; choco = 'powershell-core' }
    'Git' = @{ winget = 'Git.Git'; choco = 'git' }
    'Node.js' = @{ winget = 'OpenJS.NodeJS.LTS'; choco = 'nodejs-lts' }
    'GitHub Desktop' = @{ winget = 'GitHub.GitHubDesktop'; choco = 'github-desktop' }
    'Visual C++ Redistributable' = @{ winget = 'Microsoft.VCRedist.2015+.x64'; choco = 'vcredist140' }
}

$missing = @()
foreach ($tool in $toolStatus.tools) {
    if ($packages.ContainsKey($tool.name) -and $tool.status -eq 'missing') {
        $missing += $tool.name
    }
}

if ($missing.Count -eq 0) {
    Write-WosSummary "All packaged prerequisites are detected." 'OK'
    exit 0
}

Write-WosSummary "Missing installable prerequisites:" 'WARN'
foreach ($name in $missing) { Write-Host "  - $name" }

if (-not $Install) {
    Write-Host ""
    Write-Host "Dry run only. Rerun with -Install to install missing prerequisites." -ForegroundColor Yellow
    exit 0
}

if (-not $winget -and -not $choco) {
    Write-WosSummary "No supported package manager found. Install winget or Chocolatey, then rerun." 'ERROR'
    exit 1
}

if (-not $Yes) {
    Write-Host ""
    Write-Host "Workflow OS can install the missing prerequisites listed above." -ForegroundColor Yellow
    Write-Host "This may require administrator prompts from Windows."
    $answer = Read-Host "Type INSTALL to continue"
    if ($answer -ne 'INSTALL') {
        Write-WosSummary "Install cancelled by user." 'WARN'
        exit 1
    }
}

foreach ($name in $missing) {
    $pkg = $packages[$name]
    if ($winget) {
        Write-WosSummary "Installing $name with winget"
        & winget install --id $pkg.winget --exact --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { Write-WosSummary "winget returned exit $LASTEXITCODE for $name" 'WARN' }
    } elseif ($choco) {
        Write-WosSummary "Installing $name with Chocolatey"
        & choco install $pkg.choco -y
        if ($LASTEXITCODE -ne 0) { Write-WosSummary "Chocolatey returned exit $LASTEXITCODE for $name" 'WARN' }
    }
}

Write-WosSummary "Prerequisite install pass complete. Close and reopen PowerShell/Codex so PATH changes are visible." 'OK'
