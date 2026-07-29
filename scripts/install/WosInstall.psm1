# Workflow OS install helpers.
# Shared by preflight, setup, and launch scripts. Keep ASCII-safe for Windows PowerShell parsing.

$script:WosRepoRelativeFiles = @(
    'bootstrap.ps1',
    'AGENTS.md',
    '.agent/system.md',
    '.agent/boundaries.md',
    '.agents/plugins/marketplace.json',
    'plugins/onboarding/.codex-plugin/plugin.json',
    'plugins/memory-engine/.codex-plugin/plugin.json',
    'plugins/jira/.codex-plugin/plugin.json',
    'plugins/project/.codex-plugin/plugin.json',
    'plugins/task/.codex-plugin/plugin.json'
)

function ConvertTo-WosPlainPath {
    param([string]$Path)
    if (-not $Path) { return $null }
    if ($Path.StartsWith('\\?\')) { return $Path.Substring(4) }
    return $Path
}

function Test-WosCommand {
    param(
        [string]$Name,
        [string[]]$CommandNames = @(),
        [string[]]$KnownPaths = @()
    )

    foreach ($cmd in $CommandNames) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($found) {
            return [ordered]@{
                name = $Name
                status = 'installed'
                path = $found.Source
                note = 'Available on PATH'
            }
        }
    }

    foreach ($path in $KnownPaths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return [ordered]@{
                name = $Name
                status = 'installed_not_on_path'
                path = $path
                note = 'Installed but not available on PATH'
            }
        }
    }

    [ordered]@{
        name = $Name
        status = 'missing'
        path = $null
        note = 'Not detected'
    }
}

function Get-WosToolStatus {
    $localAppData = $env:LOCALAPPDATA
    $programFiles = $env:ProgramFiles
    $programFilesX86 = ${env:ProgramFiles(x86)}

    $tools = @()
    $tools += Test-WosCommand -Name 'PowerShell 7' -CommandNames @('pwsh') -KnownPaths @("$programFiles\PowerShell\7\pwsh.exe")
    $tools += Test-WosCommand -Name 'Codex CLI' -CommandNames @('codex') -KnownPaths @("$localAppData\OpenAI\Codex\bin\codex.exe")
    $tools += Test-WosCommand -Name 'Git' -CommandNames @('git') -KnownPaths @("$programFiles\Git\cmd\git.exe", "$programFiles\Git\bin\git.exe", "$programFilesX86\Git\cmd\git.exe")
    $tools += Test-WosCommand -Name 'Node.js' -CommandNames @('node') -KnownPaths @("$programFiles\nodejs\node.exe")
    $tools += Test-WosCommand -Name 'GitHub Desktop' -CommandNames @('github') -KnownPaths @("$localAppData\GitHubDesktop\GitHubDesktop.exe")
    $tools += Test-WosCommand -Name 'Visual C++ Redistributable' -KnownPaths @(
        "$env:WINDIR\System32\vcruntime140.dll",
        "$env:WINDIR\System32\vcruntime140_1.dll"
    )

    $packageManagers = @()
    foreach ($pm in @('winget', 'choco')) {
        $cmd = Get-Command $pm -ErrorAction SilentlyContinue
        if ($cmd) {
            $packageManagers += [ordered]@{
                name = $pm
                path = $cmd.Source
            }
        }
    }

    [ordered]@{
        tools = $tools
        package_managers = $packageManagers
    }
}

function Test-WosRepoRoot {
    param([string]$Path)

    $plain = ConvertTo-WosPlainPath $Path
    $score = 0
    $missing = @()
    $exists = $false
    $hasGit = $false
    $branch = $null
    $head = $null
    $ahead = $null
    $behind = $null
    $statusShort = @()
    $trackedDirty = $false
    $valid = $false

    if ($plain -and (Test-Path -LiteralPath $plain -PathType Container)) {
        $exists = $true
        foreach ($rel in $script:WosRepoRelativeFiles) {
            $candidate = Join-Path $plain $rel
            if (Test-Path -LiteralPath $candidate) {
                if ($rel -eq 'bootstrap.ps1') { $score += 20 }
                elseif ($rel -eq '.agents/plugins/marketplace.json') { $score += 20 }
                elseif ($rel -like 'plugins/*/.codex-plugin/plugin.json') { $score += 8 }
                else { $score += 4 }
            } else {
                $missing += $rel
            }
        }

        if (Test-Path -LiteralPath (Join-Path $plain '.git')) {
            $hasGit = $true
            $score += 10
        }

        $git = Get-Command git -ErrorAction SilentlyContinue
        if ($git -and $hasGit) {
            try {
                $branch = (& git -C $plain branch --show-current 2>$null).Trim()
                if ($branch -eq 'main') { $score += 5 }
            } catch { }
            try {
                $head = (& git -C $plain rev-parse --short HEAD 2>$null).Trim()
            } catch { }
            try {
                $upstream = (& git -C $plain rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>$null).Trim()
                if ($upstream) {
                    $counts = (& git -C $plain rev-list --left-right --count 'HEAD...@{upstream}' 2>$null).Trim()
                    if ($counts) {
                        $parts = $counts -split '\s+'
                        if ($parts.Count -ge 2) {
                            $ahead = [int]$parts[0]
                            $behind = [int]$parts[1]
                            if ($behind -eq 0) { $score += 5 }
                            else { $score -= (10 + $behind) }
                        }
                    }
                }
            } catch { }
            try {
                $statusShort = @(& git -C $plain status --porcelain 2>$null)
                foreach ($line in $statusShort) {
                    if ($line -and -not $line.StartsWith('?? ')) {
                        $trackedDirty = $true
                    }
                }
                if (-not $trackedDirty) { $score += 5 }
            } catch { }
        }

        if ($missing.Count -eq 0) {
            $valid = $true
        }
    }

    [pscustomobject]@{
        path = $plain
        exists = $exists
        valid = $valid
        score = $score
        missing = $missing
        has_git = $hasGit
        branch = $branch
        head = $head
        ahead = $ahead
        behind = $behind
        tracked_dirty = $trackedDirty
        status_short = $statusShort
    }
}

function Get-WosRepoCandidates {
    param([string]$PreferredRoot)

    $paths = New-Object System.Collections.Generic.List[string]

    if ($PreferredRoot) { $paths.Add($PreferredRoot) }
    $paths.Add((Get-Location).Path)
    if ($PSScriptRoot) {
        $paths.Add((Resolve-Path (Join-Path $PSScriptRoot '../..') -ErrorAction SilentlyContinue).Path)
    }
    $paths.Add((Join-Path $env:USERPROFILE 'workflow-os/Workflow-Agentic-OS'))
    $paths.Add((Join-Path $env:USERPROFILE 'workflow-os/Workflow-Agentic-OS/Workflow-Agentic-OS'))
    $paths.Add((Join-Path $env:USERPROFILE 'Workflow-Agentic-OS'))

    $workflowRoot = Join-Path $env:USERPROFILE 'workflow-os'
    if (Test-Path -LiteralPath $workflowRoot) {
        Get-ChildItem -LiteralPath $workflowRoot -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq 'Workflow-Agentic-OS' } |
            ForEach-Object { $paths.Add($_.FullName) }
    }

    $unique = @()
    foreach ($path in $paths) {
        if (-not $path) { continue }
        $plain = ConvertTo-WosPlainPath $path
        if (-not $plain) { continue }
        if ($unique -notcontains $plain) { $unique += $plain }
    }

    foreach ($path in $unique) {
        Test-WosRepoRoot -Path $path
    }
}

function Find-WosRepoRoot {
    param([string]$PreferredRoot)

    $candidates = @(Get-WosRepoCandidates -PreferredRoot $PreferredRoot)
    $valid = @($candidates | Where-Object { $_.valid -and -not $_.tracked_dirty } | Sort-Object score -Descending)
    if ($valid.Count -eq 0) {
        $valid = @($candidates | Where-Object { $_.valid } | Sort-Object score -Descending)
    }

    $selected = $null
    if ($valid.Count -gt 0) { $selected = $valid[0] }

    [pscustomobject]@{
        selected = $selected
        candidates = $candidates
    }
}

function Get-WosMarketplaceSource {
    param([string]$FrameworkRoot)

    $source = 'https://github.com/acasasAA/Workflow-Agentic-OS.git'
    $ref = 'main'
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git -and $FrameworkRoot -and (Test-Path -LiteralPath (Join-Path $FrameworkRoot '.git'))) {
        try {
            $origin = (& git -C $FrameworkRoot remote get-url origin 2>$null).Trim()
            if ($origin) { $source = $origin }
        } catch { }
        try {
            $branch = (& git -C $FrameworkRoot branch --show-current 2>$null).Trim()
            if ($branch) { $ref = $branch }
        } catch { }
    }

    [pscustomobject]@{
        source = $source
        ref = $ref
    }
}

function Remove-WosManagedConfig {
    param([string]$Content)

    $marker = '# === Workflow OS managed block (do not edit between markers) ==='
    $endMarker = '# === end Workflow OS managed block ==='

    if (-not $Content) { return '' }

    $pattern = '(?ms)^\s*' + [regex]::Escape($marker) + '.*?' + [regex]::Escape($endMarker) + '\s*'
    $clean = [regex]::Replace($Content, $pattern, '')
    $clean = [regex]::Replace($clean, '(?ms)^\[marketplaces\.workflow-os\]\s*\r?\n.*?(?=^\[|\z)', '')
    return $clean.TrimEnd()
}

function Merge-WosCodexConfig {
    param(
        [string]$ConfigPath = (Join-Path $env:USERPROFILE '.codex/config.toml'),
        [string]$TemplatePath,
        [string]$MarketplaceSource = 'https://github.com/acasasAA/Workflow-Agentic-OS.git',
        [string]$MarketplaceRef = 'main'
    )

    if (-not $TemplatePath) { throw 'TemplatePath is required' }
    if (-not (Test-Path -LiteralPath $TemplatePath)) { throw "Template not found: $TemplatePath" }

    $codexHome = Split-Path -Parent $ConfigPath
    if (-not (Test-Path -LiteralPath $codexHome)) {
        New-Item -ItemType Directory -Path $codexHome -Force | Out-Null
    }

    $backup = $null
    $existing = ''
    if (Test-Path -LiteralPath $ConfigPath) {
        $backup = "$ConfigPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $ConfigPath -Destination $backup -Force
        $existing = Get-Content -LiteralPath $ConfigPath -Raw
    }

    $template = Get-Content -LiteralPath $TemplatePath -Raw
    $block = $template.Replace('{{MARKETPLACE_SOURCE}}', $MarketplaceSource).Replace('{{MARKETPLACE_REF}}', $MarketplaceRef)
    $clean = Remove-WosManagedConfig -Content $existing

    if ($clean) {
        $newContent = $clean.TrimEnd() + "`r`n`r`n" + $block.Trim() + "`r`n"
    } else {
        $newContent = $block.Trim() + "`r`n"
    }

    Set-Content -LiteralPath $ConfigPath -Value $newContent -Encoding UTF8

    [pscustomobject]@{
        config_path = $ConfigPath
        backup_path = $backup
        marketplace_source = $MarketplaceSource
        marketplace_ref = $MarketplaceRef
    }
}

function Write-WosSummary {
    param([string]$Message, [string]$Level = 'INFO')
    $color = 'Cyan'
    if ($Level -eq 'OK') { $color = 'Green' }
    elseif ($Level -eq 'WARN') { $color = 'Yellow' }
    elseif ($Level -eq 'ERROR') { $color = 'Red' }
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

Export-ModuleMember -Function *
