# Workflow OS — active-task helper
# Gets or sets local.json -> active_task.

[CmdletBinding()]
param(
    [string]$Set
)

$ErrorActionPreference = 'Continue'

$sentinelPath = Join-Path $env:USERPROFILE '.codex/workflow-os.json'
if (-not (Test-Path $sentinelPath)) {
    [ordered]@{ ok = $false; error = 'Workflow OS sentinel not found'; active_task = $null } | ConvertTo-Json -Compress
    exit 1
}

try {
    $s = Get-Content $sentinelPath -Raw | ConvertFrom-Json
    if (-not $s.data_root) { throw 'data_root is not set in sentinel' }
    $localPath = Join-Path $s.data_root '.agent/local.json'
    if (-not (Test-Path $localPath)) { throw "local.json not found at $localPath" }
    $local = Get-Content $localPath -Raw | ConvertFrom-Json

    if ($PSBoundParameters.ContainsKey('Set')) {
        $local | Add-Member -NotePropertyName active_task -NotePropertyValue $null -Force
        $local.active_task = if ([string]::IsNullOrWhiteSpace($Set)) { $null } else { $Set }
        $local | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $localPath -Encoding UTF8
    }

    [ordered]@{
        ok = $true
        active_task = $local.active_task
        local_json = $localPath
    } | ConvertTo-Json -Compress
    exit 0
} catch {
    [ordered]@{
        ok = $false
        error = $_.Exception.Message
        active_task = $null
    } | ConvertTo-Json -Compress
    exit 1
}
