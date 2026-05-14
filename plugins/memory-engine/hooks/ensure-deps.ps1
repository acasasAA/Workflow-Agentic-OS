# Workflow OS — memory-engine SessionStart hook
# Ensures Node dependencies for the MCP server are installed.
# Idempotent: skips after the first successful npm install (uses a marker file).
#
# Output: silent on success. On failure, writes a one-line warning to stdout
# (Codex adds it as developer context) so the user sees what went wrong.
# Always exits 0 — hook failure must not block the session.

$ErrorActionPreference = 'Continue'

$pluginRoot = Split-Path -Parent $PSScriptRoot
$mcpDir = Join-Path $pluginRoot 'mcp'
$marker = Join-Path $mcpDir '.deps-installed'
$nodeModules = Join-Path $mcpDir 'node_modules'
$packageJson = Join-Path $mcpDir 'package.json'
$packageLock = Join-Path $mcpDir 'package-lock.json'

function Get-DependencyHash {
    $parts = @()
    foreach ($file in @($packageJson, $packageLock)) {
        if (Test-Path $file) {
            $parts += (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash
        }
    }
    return ($parts -join ':')
}

$dependencyHash = Get-DependencyHash
$installedHash = $null
if (Test-Path $marker) {
    $markerContent = Get-Content -LiteralPath $marker -Raw -ErrorAction SilentlyContinue
    if ($null -ne $markerContent) {
        $installedHash = $markerContent.Trim()
    }
}

if ((Test-Path $marker) -and (Test-Path $nodeModules) -and $dependencyHash -and ($installedHash -eq $dependencyHash)) {
    exit 0
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Output "[memory-engine] npm not found on PATH; cannot install MCP dependencies. Memory features unavailable until Node LTS is installed."
    exit 0
}

Push-Location $mcpDir
try {
    $npmOut = & npm install --omit=dev --silent 2>&1
    if ($LASTEXITCODE -eq 0) {
        Set-Content -LiteralPath $marker -Value $dependencyHash -Encoding UTF8
    } else {
        $tail = ($npmOut | Select-Object -Last 6) -join ' '
        Write-Output "[memory-engine] npm install failed (exit $LASTEXITCODE). Run 'npm install --omit=dev' in $mcpDir manually. $tail"
    }
} catch {
    Write-Output "[memory-engine] dependency install error: $_"
} finally {
    Pop-Location
}

exit 0
