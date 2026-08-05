# Configure Workflow OS Disaster Recovery v1 and register a user scheduled task.

[CmdletBinding()]
param(
    [ValidateSet('Weekly', 'EveryOtherDay')]
    [string]$Frequency = 'Weekly',
    [string]$BackupRoot,
    [string[]]$ProjectsRoot = @(),
    [int]$RetentionCount = 12,
    [switch]$NoSchedule,
    [switch]$RunNow
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WosDr.psm1') -Force

$ctx = Get-WosDrContext
$resolvedBackupRoot = Get-WosDrBackupRoot -Context $ctx -Override $BackupRoot
New-Item -ItemType Directory -Force -Path $resolvedBackupRoot | Out-Null

$resolvedProjectRoots = @(Get-WosDrProjectRoots -Context $ctx -OverrideRoots $ProjectsRoot)
$config = Set-WosDrConfig -BackupRoot $resolvedBackupRoot -Frequency $Frequency -ProjectRoots $resolvedProjectRoots -RetentionCount $RetentionCount

if (-not $NoSchedule) {
    $taskName = 'Workflow OS DR Snapshot'
    $scriptPath = Join-Path $PSScriptRoot 'New-WosSnapshot.ps1'
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if (-not $pwsh) { $pwsh = 'powershell.exe' }

    $argument = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Quiet"
    $action = New-ScheduledTaskAction -Execute $pwsh -Argument $argument
    if ($Frequency -eq 'EveryOtherDay') {
        $trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 2 -At 9am
    } else {
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
    }
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description 'Creates Workflow OS Disaster Recovery snapshots in OneDrive.' -Force | Out-Null
}

if ($RunNow) {
    & (Join-Path $PSScriptRoot 'New-WosSnapshot.ps1') -BackupRoot $resolvedBackupRoot
}

Write-Host "WOS DR configured."
Write-Host "Backup root: $resolvedBackupRoot"
Write-Host "Frequency: $Frequency"
Write-Host "Project roots: $($resolvedProjectRoots -join '; ')"
if ($NoSchedule) { Write-Host "Schedule: not registered" } else { Write-Host "Schedule: Workflow OS DR Snapshot" }
