# Workflow OS — onboarding memory compatibility verifier
# Confirms the selected data_root can be used by wos-memory-engine.

[CmdletBinding()]
param(
    [string]$FrameworkRoot,
    [string]$SentinelPath = (Join-Path $env:USERPROFILE '.codex/workflow-os.json'),
    [string]$Username = $env:USERNAME
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SentinelPath)) {
    throw "sentinel not found at $SentinelPath"
}

$sentinel = Get-Content -LiteralPath $SentinelPath -Raw | ConvertFrom-Json
if (-not $sentinel.data_root) {
    throw "sentinel has no data_root; run this after onboarding writes data_root"
}

if (-not $FrameworkRoot) {
    if ($sentinel.framework_root) {
        $FrameworkRoot = $sentinel.framework_root
    } else {
        $FrameworkRoot = Resolve-Path (Join-Path $PSScriptRoot '../../..')
    }
}

$memoryCall = Join-Path $FrameworkRoot 'plugins/memory-engine/scripts/memory-call.mjs'
if (-not (Test-Path -LiteralPath $memoryCall)) {
    throw "memory-call helper not found at $memoryCall"
}

$env:WOS_SENTINEL = $SentinelPath
$project = "onboarding-$Username"
$body = "Workflow OS onboarding verified local SQLite memory for $Username."
$argsObj = [ordered]@{
    type = 'preference'
    source = 'wos-onboarding'
    project = $project
    title = "$project-memory-verified"
    body = $body
    frontmatter_extras = [ordered]@{
        user = $Username
        onboarding_verified = $true
    }
}
$argsJson = $argsObj | ConvertTo-Json -Depth 8 -Compress

$writeRaw = & node $memoryCall memory_write $argsJson
if ($LASTEXITCODE -ne 0) {
    throw "memory_write failed: $writeRaw"
}

$searchArgs = [ordered]@{
    type = 'preference'
    project = $project
    query = 'onboarding verified'
    limit = 1
} | ConvertTo-Json -Compress

$searchRaw = & node $memoryCall memory_search $searchArgs
if ($LASTEXITCODE -ne 0) {
    throw "memory_search failed: $searchRaw"
}

$memoryStore = Join-Path $sentinel.data_root '.index/memory.db'
[ordered]@{
    ok = $true
    data_root = $sentinel.data_root
    memory_store = $memoryStore
    memory_store_exists = (Test-Path -LiteralPath $memoryStore)
    write_result = ($writeRaw -join "`n")
    search_result = ($searchRaw -join "`n")
} | ConvertTo-Json -Depth 8
