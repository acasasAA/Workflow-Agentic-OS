# Workflow OS — foundation tool detector
# Reports required/recommended/optional tool availability for onboarding.
#
# Output: JSON with package managers, tool statuses, and notes.

$ErrorActionPreference = 'Continue'

function Test-Command {
    param(
        [string]$Name,
        [string[]]$CommandNames = @(),
        [string[]]$KnownPaths = @()
    )

    $found = $null
    foreach ($cmd in $CommandNames) {
        $candidate = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($candidate) {
            $found = [ordered]@{
                status = 'installed'
                path = $candidate.Source
                note = 'Available on PATH'
            }
            break
        }
    }

    if (-not $found) {
        foreach ($path in $KnownPaths) {
            if (Test-Path -LiteralPath $path) {
                $found = [ordered]@{
                    status = 'installed_not_on_path'
                    path = $path
                    note = 'Installed but not available on PATH'
                }
                break
            }
        }
    }

    if (-not $found) {
        $found = [ordered]@{
            status = 'missing'
            path = $null
            note = 'Not detected'
        }
    }

    [ordered]@{
        name = $Name
        status = $found.status
        path = $found.path
        note = $found.note
    }
}

$localAppData = $env:LOCALAPPDATA
$programFiles = $env:ProgramFiles
$programFilesX86 = ${env:ProgramFiles(x86)}

$tools = @()
$tools += Test-Command -Name 'Codex CLI' -CommandNames @('codex') -KnownPaths @("$localAppData\OpenAI\Codex\bin\codex.exe")
$tools += Test-Command -Name 'Git' -CommandNames @('git') -KnownPaths @("$programFiles\Git\cmd\git.exe", "$programFiles\Git\bin\git.exe", "$programFilesX86\Git\cmd\git.exe")
$tools += Test-Command -Name 'Node.js' -CommandNames @('node') -KnownPaths @("$programFiles\nodejs\node.exe")
$tools += Test-Command -Name 'GitHub Desktop' -CommandNames @('github') -KnownPaths @("$localAppData\GitHubDesktop\GitHubDesktop.exe")
$tools += Test-Command -Name 'Obsidian' -CommandNames @('obsidian') -KnownPaths @("$localAppData\Programs\Obsidian\Obsidian.exe", "$programFiles\Obsidian\Obsidian.exe")
$tools += Test-Command -Name 'Atlassian CLI' -CommandNames @('acli') -KnownPaths @("$localAppData\Programs\Atlassian\ACLI\acli.exe")
$tools += Test-Command -Name 'Azure CLI' -CommandNames @('az') -KnownPaths @("$programFiles\Microsoft SDKs\Azure\CLI2\wbin\az.cmd")
$tools += Test-Command -Name 'AWS CLI' -CommandNames @('aws') -KnownPaths @("$programFiles\Amazon\AWSCLIV2\aws.exe")
$tools += Test-Command -Name 'Power Automate CLI/MCP' -CommandNames @('pac')
$tools += Test-Command -Name 'Power BI CLI/MCP' -CommandNames @('pbi', 'powerbi')
$tools += Test-Command -Name 'Microsoft Learn CLI' -CommandNames @('mslearn', 'learn')

$packageManagers = @()
foreach ($pm in @('winget', 'choco', 'scoop')) {
    $cmd = Get-Command $pm -ErrorAction SilentlyContinue
    if ($cmd) {
        $packageManagers += [ordered]@{
            name = $pm
            path = $cmd.Source
        }
    }
}

$mcpList = $null
try {
    $mcpList = (& codex mcp list 2>&1) -join "`n"
} catch {
    $mcpList = $null
}

[ordered]@{
    package_managers = $packageManagers
    tools = $tools
    mcp_list_output = $mcpList
    mcp_note = 'Connector-backed apps such as Atlassian Rovo, Outlook, Calendar, and SharePoint may require Codex plugin/connector UI install. Atlassian CLI (`acli`) is a local companion for deterministic Jira fallback operations.'
} | ConvertTo-Json -Depth 6
