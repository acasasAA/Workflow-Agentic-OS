# Workflow OS First-Time Install Instructions

Use this when a user has never installed Workflow OS on their Codex environment.

Repository:

```text
https://github.com/acasasAA/Workflow-Agentic-OS.git
```

## Goal

Install Workflow OS from the Git-backed marketplace, install `wos-onboarding` first, then let onboarding guide mandatory Jira and Documentation setup.

Mandatory after onboarding starts:

- `wos-jira`
- `wos-documentation`
- `wos-dr`

Optional:

- `wos-memory-engine`
- `wos-project`
- `wos-task`

## Latest Expected Versions

- `wos-onboarding` v0.1.9
- `wos-jira` v0.2.5
- `wos-documentation` v0.1.8
- `wos-dr` v0.1.0
- `wos-memory-engine` v0.1.3
- `wos-project` v0.1.6
- `wos-task` v0.1.6

## Prompt To Give Their Codex

```text
Please install Workflow OS for the first time on this machine.

Repository:
https://github.com/acasasAA/Workflow-Agentic-OS.git

Safety:
- Do not delete, move, or rename user folders.
- Do not overwrite tracked local changes.
- Do not bypass Jira delete/archive protections, email/send guardrails, or no-auto-commit policy.
- Use $env:USERPROFILE for user-specific paths. Do not hardcode another user's username.
- Stop at the first real failure and show the exact error plus the next recommended action.

Steps:
1. Confirm the user can open this repo in a browser while signed into GitHub:
   https://github.com/acasasAA/Workflow-Agentic-OS
   If they cannot open it, stop. They need repo access first.
2. Check required tools:
   codex --version
   git --version
   node --version
   pwsh --version
   If any are missing, stop and tell the user exactly what is missing.
3. Find or clone the Workflow OS repo under:
   C:\Users\<current-user>\workflow-os\Workflow-Agentic-OS
   If no valid checkout exists, create C:\Users\<current-user>\workflow-os if needed and clone:
   git clone https://github.com/acasasAA/Workflow-Agentic-OS.git C:\Users\<current-user>\workflow-os\Workflow-Agentic-OS
4. From the selected checkout, run:
   pwsh -NoProfile -File .\scripts\install\preflight.ps1
5. If preflight reports missing required prerequisites or tracked local changes, stop and show only the blocker and fix.
6. If preflight is ready, run:
   pwsh -NoProfile -File .\scripts\install\setup-codex.ps1
   When asked, type SETUP.
7. Fully close and reopen Codex.
8. Open /plugins.
9. Install only `wos-onboarding` from the `workflow-os` marketplace first.
10. Start a fresh Codex session and run:
    $welcome
11. When onboarding asks, install mandatory plugins:
    - wos-jira
    - wos-documentation
    - wos-dr
12. Finish mandatory setup flows before continuing:
    - $jira-setup
    - $documentation-setup
    - $dr-setup
13. Create a first disaster recovery snapshot:
    $dr-snapshot
14. Ask the user which optional plugins they want before installing any of:
    - wos-memory-engine
    - wos-project
    - wos-task

Use normal defaults unless the user says otherwise:
- Data path: C:\Users\<current-user>\workflow-os-data
- OneDrive backup: detected organization OneDrive if available
- Jira tenant: https://athensadmin.atlassian.net
- Jira project keys: ask the user; ASD and TPM are common examples, but do not assume they are the only keys.

Verify at the end:
- /plugins shows Workflow OS.
- wos-onboarding is installed.
- wos-jira, wos-documentation, and wos-dr are installed and setup-complete.
- WOS DR has a OneDrive-backed backup root, a schedule, and a latest snapshot.
- Any optional plugins were installed only if selected by the user.
- Expected versions:
  - wos-onboarding v0.1.9
  - wos-jira v0.2.5
  - wos-documentation v0.1.8
  - wos-dr v0.1.0
  - wos-memory-engine v0.1.3
  - wos-project v0.1.6
  - wos-task v0.1.6
```

## Quick Human Checklist

1. Confirm GitHub repo access.
2. Let their Codex run the prompt above.
3. Restart Codex after `setup-codex.ps1`.
4. Install `wos-onboarding` first.
5. Run `$welcome`.
6. Complete `$jira-setup`, `$documentation-setup`, and `$dr-setup`.
7. Create a first snapshot with `$dr-snapshot`.
8. Install optional plugins only after the user chooses them.
