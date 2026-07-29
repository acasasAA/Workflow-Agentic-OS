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

function Test-AzExtension {
    param(
        [string]$Name,
        [string]$ExtensionName
    )

    $az = Get-Command az -ErrorAction SilentlyContinue
    if (-not $az) {
        return [ordered]@{
            name = $Name
            status = 'missing'
            path = $null
            note = 'Azure CLI is not available on PATH'
        }
    }

    try {
        $raw = (& az extension list --output json 2>$null) -join "`n"
        $extensions = $raw | ConvertFrom-Json
        $match = $extensions | Where-Object { $_.name -eq $ExtensionName } | Select-Object -First 1
        if ($match) {
            return [ordered]@{
                name = $Name
                status = 'installed'
                path = $az.Source
                note = "Azure CLI extension '$ExtensionName' is installed"
            }
        }
    } catch {
        return [ordered]@{
            name = $Name
            status = 'installed_not_on_path'
            path = $az.Source
            note = "Azure CLI is available, but extension status could not be verified"
        }
    }

    [ordered]@{
        name = $Name
        status = 'missing'
        path = $az.Source
        note = "Install with: az extension add --name $ExtensionName"
    }
}

function Test-WorkflowMemoryEngine {
    $onboardingRoot = Resolve-Path (Join-Path $PSScriptRoot '..') -ErrorAction SilentlyContinue
    if (-not $onboardingRoot) {
        return [ordered]@{
            name = 'Local Workflow OS memory engine'
            status = 'missing'
            path = $null
            note = 'Onboarding plugin root could not be resolved'
        }
    }

    $memoryRoot = Resolve-Path (Join-Path $onboardingRoot.Path '../memory-engine') -ErrorAction SilentlyContinue
    if (-not $memoryRoot) {
        return [ordered]@{
            name = 'Local Workflow OS memory engine'
            status = 'missing'
            path = $null
            note = 'wos-memory-engine plugin folder was not found next to onboarding'
        }
    }

    $memoryPlugin = Join-Path $memoryRoot.Path '.codex-plugin/plugin.json'
    $memoryServer = Join-Path $memoryRoot.Path 'mcp/server.js'
    if ((Test-Path -LiteralPath $memoryPlugin) -and (Test-Path -LiteralPath $memoryServer)) {
        return [ordered]@{
            name = 'Local Workflow OS memory engine'
            status = 'installed'
            path = $memoryRoot.Path
            note = 'Memory-engine plugin files are present; onboarding verifies SQLite after data_root is set'
        }
    }

    [ordered]@{
        name = 'Local Workflow OS memory engine'
        status = 'missing'
        path = $null
        note = 'wos-memory-engine plugin files were not found'
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
$tools += Test-WorkflowMemoryEngine
$tools += Test-Command -Name 'Atlassian CLI' -CommandNames @('acli') -KnownPaths @("$localAppData\Programs\Atlassian\ACLI\acli.exe")
$tools += Test-Command -Name 'Azure CLI' -CommandNames @('az') -KnownPaths @("$programFiles\Microsoft SDKs\Azure\CLI2\wbin\az.cmd")
$tools += Test-AzExtension -Name 'Azure DevOps CLI Extension' -ExtensionName 'azure-devops'
$tools += Test-Command -Name 'AWS CLI' -CommandNames @('aws') -KnownPaths @("$programFiles\Amazon\AWSCLIV2\aws.exe")
$tools += Test-Command -Name 'Power Automate CLI/MCP' -CommandNames @('pac')
$tools += Test-Command -Name 'Power BI CLI/MCP' -CommandNames @('pbi', 'powerbi')
$tools += Test-Command -Name 'Microsoft Learn MCP/CLI' -CommandNames @('mslearn', 'learn')

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
    mcp_note = 'Connector-backed apps such as Atlassian Rovo, Outlook, Calendar, SharePoint, Microsoft Learn, AWS, and Azure DevOps/Azure Boards may require Codex plugin/connector UI install when available. Atlassian CLI (`acli`) is a local companion for deterministic Jira fallback operations. Azure Boards generally uses Azure DevOps tooling, including the Azure CLI azure-devops extension.'
} | ConvertTo-Json -Depth 6
