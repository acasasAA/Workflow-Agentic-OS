# Workflow OS Codex Setup Prompt

Paste this into Codex after the prerequisite installer has run, or when helping a teammate over Zoom.

```text
Please finish setting up Workflow OS on this machine.

Assumptions:
- Prerequisites should already be installed or available: PowerShell 7, Codex CLI, Git, Node.js LTS, GitHub Desktop, Obsidian.
- Workflow OS may be cloned under C:\Users\<current-user>\workflow-os\, but do not hardcode the username.
- Use $env:USERPROFILE for user-specific paths.

Safety:
- Do not delete, move, or rename folders.
- If there is a nested Workflow-Agentic-OS folder, auto-select the valid checkout and continue from that path.
- If there are tracked local changes in a valid repo, stop and show me the exact git status.
- Do not bypass Jira delete protections, email/send guardrails, or no-auto-commit policy.

Steps:
1. Confirm Codex is signed in and can run shell commands.
2. Confirm the current sandbox/install access is sufficient for setup. If not, tell me exactly what to enable in plain language.
3. Find the best valid Workflow OS checkout under:
   C:\Users\<current-user>\workflow-os\
   C:\Users\<current-user>\workflow-os\Workflow-Agentic-OS\
   C:\Users\<current-user>\workflow-os\Workflow-Agentic-OS\Workflow-Agentic-OS\
4. From the selected checkout, run:
   .\scripts\install\preflight.ps1
5. If preflight reports missing required prerequisites, stop and show me only the missing items and the recommended fix.
6. If preflight is ready, run:
   .\scripts\install\setup-codex.ps1
7. Fully close and reopen Codex when setup tells me to.
8. In /plugins, install wos-onboarding from workflow-os.
9. Run:
   $welcome

Use normal install defaults unless I say otherwise:
- Data path: C:\Users\<current-user>\workflow-os-data
- OneDrive backup: detected organization OneDrive if available
- Jira tenant: https://athensadmin.atlassian.net
- Jira keys: ASD, TPM

Stop at the first real failure and show the exact error plus the next recommended action.
```

## Expected Plugin Versions

- `wos-onboarding` v0.1.2
- `wos-jira` v0.1.1
- `wos-memory-engine` v0.1.0
- `wos-project` v0.1.2
- `wos-task` v0.1.1
