# Workflow OS guided setup launcher.

[CmdletBinding()]
param(
    [string]$PreferredRoot,
    [switch]$InstallMissingPrereqs,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WosInstall.psm1'
Import-Module $modulePath -Force

Write-WosSummary "Starting Workflow OS guided setup"
Write-Host ""

& (Join-Path $PSScriptRoot 'preflight.ps1') -PreferredRoot $PreferredRoot

if ($InstallMissingPrereqs) {
    & (Join-Path $PSScriptRoot 'install-prereqs.ps1') -Install -Yes:$Yes
    Write-Host ""
    Write-WosSummary "Rerunning preflight after prerequisite install"
    & (Join-Path $PSScriptRoot 'preflight.ps1') -PreferredRoot $PreferredRoot
}

Write-Host ""
if (-not $Yes) {
    Write-Host "If preflight found missing required tools, install them first." -ForegroundColor Yellow
    $answer = Read-Host "Type CONTINUE to prepare Codex now, or press Enter to stop"
    if ($answer -ne 'CONTINUE') {
        Write-WosSummary "Stopped before Codex setup." 'WARN'
        exit 1
    }
}

& (Join-Path $PSScriptRoot 'setup-codex.ps1') -PreferredRoot $PreferredRoot -Yes:$Yes
