# Workflow OS Pilot Install

Use this flow for supervised coworker installs.

## Target Experience

1. Install or verify prerequisites.
2. Run Workflow OS preflight/setup.
3. Open Codex.
4. Install `wos-onboarding`.
5. Run `$welcome`.
6. During onboarding, install and finish setup for mandatory `wos-jira`, `wos-documentation`, and `wos-dr`.
7. Choose any optional plugins.
8. Verify plugin versions.

## Prerequisites

Smooth path requires:

- PowerShell 7
- Codex CLI
- Git
- Node.js LTS
- GitHub Desktop

Optional later tools include Atlassian CLI, Azure CLI, Azure DevOps extension, AWS CLI, Power BI, Power Automate, and Microsoft Learn tooling.

## Guided Script Flow

From the Workflow OS repo, run:

```powershell
pwsh -NoProfile -File .\scripts\install\preflight.ps1
```

If required tools are missing, review the output. To install missing packaged prerequisites with confirmation:

```powershell
pwsh -NoProfile -File .\scripts\install\install-prereqs.ps1 -Install
```

When preflight is ready, run:

```powershell
pwsh -NoProfile -File .\scripts\install\setup-codex.ps1
```

For a single guided entrypoint:

```powershell
pwsh -NoProfile -File .\scripts\install\launch-wos-setup.ps1
```

## Codex Steps

After setup:

1. Fully close and reopen Codex.
2. Open `/plugins`.
3. Install `wos-onboarding` from the `workflow-os` marketplace.
4. Run `$welcome`.
5. Install the mandatory WOS plugins when onboarding asks:
   - `wos-jira`
   - `wos-documentation`
   - `wos-dr`
6. Finish the mandatory setup flows when onboarding asks:
   - `$jira-setup`
   - `$documentation-setup`
   - `$dr-setup`
7. Create the first DR snapshot:
   - `$dr-snapshot`
8. Install optional WOS plugins only if selected:
   - `wos-memory-engine`
   - `wos-project`
   - `wos-task`

## Onboarding Defaults

- Framework path: detected Workflow OS repo.
- Data path: `C:\Users\<user>\workflow-os-data`.
- OneDrive backup: detected organization OneDrive if available.
- Jira tenant: `https://athensadmin.atlassian.net`.
- Jira keys: `ASD, TPM`.
- Mandatory plugins: `wos-jira`, `wos-documentation`, `wos-dr`.
- Optional plugins: `wos-memory-engine`, `wos-project`, `wos-task`.

## Troubleshooting

### Nested Repo

If a user accidentally creates:

```text
C:\Users\<user>\workflow-os\Workflow-Agentic-OS\Workflow-Agentic-OS
```

do not move or delete folders during the pilot. The preflight scripts will auto-select the best valid checkout and continue.

### Tracked Local Changes

If preflight reports tracked local changes, stop and review `git status`. This may be real user work.

### Old PowerShell

If Windows PowerShell 5.1 causes parse or encoding issues, install PowerShell 7 and rerun scripts with `pwsh`.

### Plugins Show Old Versions

Close Codex, rerun `setup-codex.ps1`, reopen Codex, and reinstall/update WOS plugins in `/plugins`.

## Safety Notes

- Install access does not bypass Jira delete protections.
- Email/calendar sends remain user-confirmed or draft-only.
- Workflow OS does not auto-commit or auto-push.
- Preflight does not delete, move, or rename folders.
