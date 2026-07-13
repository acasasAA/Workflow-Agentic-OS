# Workflow OS Install Instructions for Codex

Follow these instructions to install Workflow OS from the Git-backed marketplace.

Repository:
[acasasAA/Workflow-Agentic-OS](https://github.com/acasasAA/Workflow-Agentic-OS)

Repo URL:

```text
https://github.com/acasasAA/Workflow-Agentic-OS.git
```

## Goal

Install Workflow OS plugins into Codex using the Git-backed marketplace.

For general Athens IT users, start with **WOS Jira** only. The full Workflow OS suite is optional.

Do not redesign Workflow OS. Do not delete, move, or rename user folders. If a command fails, stop and show the exact error.

## Prerequisites

Confirm these are installed or available:

- Codex app / Codex CLI
- Git
- Node.js LTS
- PowerShell 7 preferred
- Access to the private GitHub repo: `acasasAA/Workflow-Agentic-OS`

First, confirm the user can open this link in a browser while signed into GitHub:

```text
https://github.com/acasasAA/Workflow-Agentic-OS
```

If the browser cannot open the repo, stop. The user needs GitHub repo access before continuing.

## Step 1: Check Codex CLI

Run:

```powershell
codex --version
```

If Codex is not found, stop and tell the user Codex CLI is not available from this shell.

## Step 2: Fix Known Codex Config Issue If Present

Check:

```powershell
$config = "$env:USERPROFILE\.codex\config.toml"
if (Test-Path $config) {
  Select-String -Path $config -Pattern 'service_tier = "default"'
}
```

If it returns a match, back up the config and remove only that line:

```powershell
$config = "$env:USERPROFILE\.codex\config.toml"
$backup = "$config.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $config $backup -Force
(Get-Content $config) | Where-Object { $_ -ne 'service_tier = "default"' } | Set-Content $config
Write-Host "Backed up config to $backup"
```

This is needed because newer Codex versions may reject `service_tier = "default"`.

## Step 3: Add Workflow OS Marketplace

Run:

```powershell
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

If it says the marketplace already exists, refresh it:

```powershell
codex plugin marketplace upgrade workflow-os
```

If upgrade fails because the marketplace is not Git-backed, remove and re-add it:

```powershell
codex plugin marketplace remove workflow-os
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

## Step 4: Restart Codex

Fully close and reopen Codex.

## Step 5: Install WOS Jira

In Codex, open:

```text
/plugins
```

Find **Workflow OS** and install:

- `wos-jira`

If the user only needs Jira standardization, install only:

- `wos-jira`

Expected visible Jira version:

- `wos-jira` v0.2.1

## Step 6: Run Jira Setup

Start a fresh Codex session and run:

```text
$jira-setup
```

Follow the prompts. Recommended Athens defaults:

- Jira tenant:
  ```text
  https://athensadmin.atlassian.net
  ```
- Default Jira project keys:
  ```text
  ASD, TPM
  ```
- Data root:
  Jira-only setup does not require a Workflow OS data root.

Use the current Windows username. Do not hardcode another user's path.

## Optional: Full Workflow OS Suite

If the user wants project/task/memory/orchestration workflows, also install:

- `wos-onboarding`
- `wos-memory-engine`
- `wos-project`
- `wos-task`

Then run:

```text
$welcome
```

## If Something Fails

Stop at the first failure and show the exact error.

Useful checks:

```powershell
codex --version
git --version
node --version
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

Do not delete or move folders unless the user explicitly confirms.
