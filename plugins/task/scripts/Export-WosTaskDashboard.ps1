param(
    [string]$OutputDir = (Join-Path (Get-Location) 'wos-task-dashboard'),
    [string]$AgendaSlug = '',
    [int]$Limit = 200,
    [switch]$SkipTemplateCopy,
    [switch]$SkipIndexSeedInject
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginRoot = Split-Path -Parent $ScriptDir
$TemplateDir = Join-Path $PluginRoot 'templates\task-dashboard'

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw 'Node.js is required to read WOS memory through memory-call.mjs.'
}

function Resolve-MemoryCall {
    $pluginParent = Split-Path -Parent $PluginRoot
    $candidates = @(
        (Join-Path $pluginParent 'memory-engine\scripts\memory-call.mjs'),
        (Join-Path $pluginParent 'wos-memory-engine\scripts\memory-call.mjs')
    )

    $cacheRoot = Join-Path $env:USERPROFILE '.codex\plugins\cache\workflow-os'
    if (Test-Path $cacheRoot) {
        $cacheCandidates = Get-ChildItem -Path $cacheRoot -Recurse -Filter 'memory-call.mjs' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '\\wos-memory-engine\\|\\memory-engine\\' } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -ExpandProperty FullName
        $candidates += $cacheCandidates
    }

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw 'Could not find memory-call.mjs. Install or upgrade wos-memory-engine first.'
}

function Get-ToolText {
    param([object]$ToolResult)

    if ($ToolResult.content) {
        $textBlock = @($ToolResult.content | Where-Object { $_.type -eq 'text' } | Select-Object -First 1)
        if ($textBlock.Count -gt 0) { return [string]$textBlock[0].text }
    }

    return ($ToolResult | ConvertTo-Json -Depth 100)
}

function ConvertTo-Lane {
    param([string]$Status)
    $s = ''
    if ($null -ne $Status) { $s = $Status.ToLowerInvariant() }
    if ($s -match 'done|complete|completed|closed|cancelled|canceled') { return 'archive' }
    if ($s -match 'waiting|blocked|hold|pending') { return 'waiting' }
    if ($s -match 'active|in progress|in-progress|doing') { return 'now' }
    return 'next'
}

function ConvertTo-Priority {
    param([object]$Task)
    $text = @($Task.task, $Task.next_action, $Task.status, ($Task.links -join ' ')) -join ' '
    if ($text -match '(?i)urgent|critical|asap|today|blocked') { return 'High' }
    if ($text -match '(?i)low|someday|backlog') { return 'Low' }
    return 'Medium'
}

function ConvertTo-DueDate {
    param([object]$Due)
    if ($null -eq $Due -or [string]::IsNullOrWhiteSpace([string]$Due)) { return '' }
    try {
        return ([datetimeoffset]::Parse([string]$Due)).ToString('yyyy-MM-dd')
    } catch {
        return [string]$Due
    }
}

function ConvertTo-Link {
    param([object[]]$Links)
    foreach ($link in @($Links)) {
        $value = [string]$link
        if ($value -match '^https?://') { return $value }
    }
    return ''
}

function ConvertTo-Score {
    param([object]$Task)
    $score = 60
    $priority = ConvertTo-Priority -Task $Task
    $lane = ConvertTo-Lane -Status ([string]$Task.status)
    if ($priority -eq 'High') { $score += 30 }
    if ($lane -eq 'now') { $score += 12 }
    if ($lane -eq 'waiting') { $score += 4 }
    if ($lane -eq 'archive') { $score = 20 }
    return [Math]::Min(100, $score)
}

if (-not (Test-Path $TemplateDir)) {
    throw "Dashboard template not found at $TemplateDir"
}

$memoryCall = Resolve-MemoryCall
$args = @{
    type = 'task-state'
    limit = [Math]::Max(1, [Math]::Min($Limit, 1000))
}
if (-not [string]::IsNullOrWhiteSpace($AgendaSlug)) {
    $args.project = $AgendaSlug
}

$argsJson = $args | ConvertTo-Json -Compress
$raw = & node $memoryCall memory_export $argsJson
if ($LASTEXITCODE -ne 0) {
    throw "memory_export failed: $raw"
}

$toolResult = ($raw -join "`n") | ConvertFrom-Json
$receiptText = Get-ToolText -ToolResult $toolResult
$receipts = @($receiptText | ConvertFrom-Json)
$agendaReceipts = @($receipts | Where-Object { $_.source -eq 'wos-task' -and $_.metadata -and $_.metadata.tasks })

$seen = @{}
$dashboardTasks = New-Object System.Collections.Generic.List[object]

foreach ($receipt in $agendaReceipts) {
    $project = if ($receipt.metadata.task_slug) { [string]$receipt.metadata.task_slug } else { [string]$receipt.project }
    foreach ($task in @($receipt.metadata.tasks)) {
        $sourceId = if ($task.id) { [string]$task.id } else { [guid]::NewGuid().ToString('N').Substring(0, 8) }
        $key = "$project|$sourceId"
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true

        $links = @($task.links)
        $nextAction = [string]$task.next_action
        $evidenceParts = @()
        if (-not [string]::IsNullOrWhiteSpace($nextAction)) { $evidenceParts += "Next: $nextAction" }
        if ($links.Count -gt 0) { $evidenceParts += ('Links: ' + (($links | ForEach-Object { [string]$_ }) -join '; ')) }

        $dashboardTasks.Add([pscustomobject]@{
            id = "wos-$project-$sourceId"
            displayId = $sourceId
            title = [string]$task.task
            source = if ($task.source) { [string]$task.source } else { 'wos-task' }
            project = $project
            priority = ConvertTo-Priority -Task $task
            status = if ($task.status) { [string]$task.status } else { 'new' }
            owner = if ($task.owner) { [string]$task.owner } else { 'me' }
            type = 'Task'
            link = ConvertTo-Link -Links $links
            evidence = ($evidenceParts -join ' | ')
            due = ConvertTo-DueDate -Due $task.due
            score = ConvertTo-Score -Task $task
            lane = ConvertTo-Lane -Status ([string]$task.status)
            progressPct = ''
        })
    }
}

$resolvedAgendaSlug = 'all'
if (-not [string]::IsNullOrWhiteSpace($AgendaSlug)) {
    $resolvedAgendaSlug = [string]$AgendaSlug
}

$seed = [pscustomobject]@{
    generatedAt = [datetimeoffset]::Now.ToString('o')
    timezone = [System.TimeZoneInfo]::Local.Id
    sources = [pscustomobject]@{
        wosTaskReceiptsScanned = $agendaReceipts.Count
        taskCount = $dashboardTasks.Count
        agendaSlug = $resolvedAgendaSlug
        generatedBy = 'wos-task Export-WosTaskDashboard.ps1'
    }
    tasks = @($dashboardTasks.ToArray())
}

if (-not $SkipTemplateCopy) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    Get-ChildItem -LiteralPath $TemplateDir -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $OutputDir -Recurse -Force
    }
} else {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$dataDir = Join-Path $OutputDir 'data'
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
$seedJson = $seed | ConvertTo-Json -Depth 100
$dataPath = Join-Path $dataDir 'tasks.json'
Set-Content -LiteralPath $dataPath -Value $seedJson -Encoding UTF8

$indexPath = Join-Path $OutputDir 'index.html'
if (-not $SkipIndexSeedInject -and (Test-Path $indexPath)) {
    $html = Get-Content -Raw -LiteralPath $indexPath
    $replacement = '<script id="seed" type="application/json">' + $seedJson + '</script>'
    $html = [regex]::Replace($html, '(?s)<script id="seed" type="application/json">.*?</script>', $replacement, 1)
    Set-Content -LiteralPath $indexPath -Value $html -Encoding UTF8
}

[pscustomobject]@{
    outputDir = (Resolve-Path $OutputDir).Path
    dataPath = (Resolve-Path $dataPath).Path
    indexPath = if (Test-Path $indexPath) { (Resolve-Path $indexPath).Path } else { $null }
    taskCount = $dashboardTasks.Count
    receiptsScanned = $agendaReceipts.Count
} | ConvertTo-Json -Depth 5
