# Workflow OS Existing Install Update Instructions

Use this when a user already has Workflow OS in Codex and needs the latest marketplace/plugin updates.

Repository:

```text
https://github.com/acasasAA/Workflow-Agentic-OS.git
```

## Goal

Refresh the existing Workflow OS marketplace, update the WOS plugins the user already has installed, preserve local Workflow OS data, require the mandatory Jira, Documentation, and Disaster Recovery plugins, configure DR v1, and offer any other missing plugins as choices.

Do not rerun first-time onboarding unless the existing install is incomplete or broken. `wos-jira`, `wos-documentation`, and `wos-dr` are mandatory and must be installed if missing. Do not install any other missing plugin unless the user explicitly chooses it.

## Latest Expected Versions

- `wos-onboarding` v0.1.9
- `wos-jira` v0.2.5
- `wos-documentation` v0.1.9
- `wos-dr` v0.1.0
- `wos-memory-engine` v0.1.3
- `wos-project` v0.1.6
- `wos-task` v0.1.6

## Documentation Update Notes

`wos-documentation` v0.1.8 adds conservative long-document handling for KB Refresh and documentation drafting.

`wos-documentation` v0.1.9 adds stricter intake behavior, Help Desk emoji section enforcement, and the confirmed public-facing and team Confluence space defaults.

When `KB Refresh` or `$documentation-draft` receives long, unstructured, OneNote-derived, or PDF-like source material, the plugin treats the source as raw material instead of copying its length or page shape.

Expected behavior:

- Prefer one continuous Confluence article whenever practical.
- Keep public-facing documentation simple, concise, and employee-safe.
- Keep internal documentation practical and complete without unnecessary sprawl.
- Split into multiple Confluence pages only when separate reader workflows genuinely justify it.
- Do not exceed five pages when a split is truly required, and prefer fewer pages.
- Preserve verified facts, exact errors, commands, paths, and required operational details.
- Use `[TBD]` or `<PLACEHOLDER>` for missing information instead of inventing content.
- Ask direct questions before drafting when required source details are missing.
- Do not output a completed draft after a "Gaps To Confirm" list.
- Preserve required emoji section headings for all built-in templates, including Help Desk how-to and troubleshooting templates.
- Use confirmed WOS Documentation spaces by default: `HelpDesk Public` / `AEHT`, `HelpDesk Troubleshooting` / `AHI`, `HelpDesk System Processes` / `AIH`, `Internal Infrastructure KB` / `IIK`, and `Dev Team KB` / `DTK`.
- Keep `JSM Optimization Advisory` out of WOS Documentation route defaults.

## Prompt To Give Their Codex

```text
Please update the existing Workflow OS install on this machine.

Repository:
https://github.com/acasasAA/Workflow-Agentic-OS.git

Safety:
- Preserve the user's existing Workflow OS data and settings.
- Do not delete, move, or rename user folders.
- Do not overwrite tracked local changes.
- Do not bypass Jira delete/archive protections, email/send guardrails, or no-auto-commit policy.
- Use $env:USERPROFILE for user-specific paths. Do not hardcode another user's username.
- Stop at the first real failure and show the exact error plus the next recommended action.

Steps:
1. Confirm Codex CLI is available:
   codex --version
2. Confirm the user can open this repo in a browser while signed into GitHub:
   https://github.com/acasasAA/Workflow-Agentic-OS
   If they cannot open it, stop. They need repo access before updating from the Git-backed marketplace.
3. Inspect the current Codex config:
   $config = "$env:USERPROFILE\.codex\config.toml"
   if (Test-Path $config) { Select-String -Path $config -Pattern '\[marketplaces\.workflow-os\]' -Context 0,4 }
4. If `workflow-os` is already configured as a Git marketplace, run:
   codex plugin marketplace upgrade workflow-os
5. If `workflow-os` is missing, add it:
   codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
6. If `workflow-os` is configured as a local marketplace or upgrade says it is not Git-backed, ask the user before changing it. If they confirm they want the standard Git-backed team marketplace, run:
   codex plugin marketplace remove workflow-os
   codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
7. Fully close and reopen Codex.
8. Open /plugins.
9. Inventory which Workflow OS plugins are currently installed and enabled. Use /plugins as the source of truth. If you inspect files, also check:
   - $env:USERPROFILE\.codex\config.toml
   - $env:USERPROFILE\.codex\plugins\cache\workflow-os
10. Update or reinstall only the Workflow OS plugins the user already has installed so those installed plugins match the latest expected versions:
    - wos-onboarding v0.1.9
    - wos-jira v0.2.5
    - wos-documentation v0.1.9
    - wos-dr v0.1.0
    - wos-memory-engine v0.1.3
    - wos-project v0.1.6
    - wos-task v0.1.6
11. If any mandatory plugin is missing, install it. Do not ask the user to choose whether to install these; they are required for the current Workflow OS baseline:
    - wos-jira
    - wos-documentation
    - wos-dr
12. If any optional Workflow OS plugins are missing, do not install them automatically. Show the user a short optional missing-plugin list and ask which, if any, they want to add:
    - wos-memory-engine
    - wos-project
    - wos-task
13. If `wos-onboarding` is missing, explain that it is mainly for first-time setup and ask before installing it on an existing environment.
14. Configure WOS DR v1 if it is not already configured:
    $dr-setup
    Use weekly snapshots by default. If the user wants faster coverage, use every-other-day snapshots. Use the user's OneDrive backup folder when available. If the user has a designated OneDrive folder for Codex project folders, provide that path during DR setup.
15. Create an immediate first snapshot:
    $dr-snapshot
16. Verify DR status:
    $dr-status
17. Verify mandatory setup. If `wos-jira` setup is incomplete, run:
    $jira-setup
    If `wos-documentation` setup is incomplete, run:
    $documentation-setup
18. If the user declines a missing optional plugin, move on and finish the update.

Verification:
- /plugins shows the latest expected versions for installed WOS plugins.
- wos-jira, wos-documentation, and wos-dr are installed at the latest expected versions.
- WOS DR status shows a OneDrive-backed backup root, schedule, and latest snapshot.
- Missing optional WOS plugins were offered to the user instead of installed automatically.
- Jira and Documentation setup are complete.
- Existing Workflow OS data path is preserved.
- If the user previously had optional plugins installed, they still work after restart.
```

## Quick Human Checklist

1. Confirm GitHub repo access.
2. Upgrade or re-add the `workflow-os` marketplace.
3. Restart Codex.
4. Update only currently installed WOS plugins in `/plugins`.
5. Install `wos-jira`, `wos-documentation`, and `wos-dr` if any are missing; they are mandatory.
6. Run `$dr-setup`, then `$dr-snapshot`.
7. Run `$dr-status`.
8. Offer missing optional plugins as choices; do not install optional plugins automatically.
9. Confirm Jira and Documentation setup is complete.
10. Leave optional plugins alone unless the user wants them.

## Common Outcomes

### Marketplace Upgrade Works

If this succeeds:

```powershell
codex plugin marketplace upgrade workflow-os
```

restart Codex, update installed plugins from `/plugins`, install missing `wos-jira`, `wos-documentation`, and `wos-dr`, configure DR, create a first snapshot, and offer other missing plugins as choices.

### Marketplace Is Not Git-Backed

If upgrade reports that `workflow-os` is not Git-backed, the machine is likely pointed at a local checkout. For a normal teammate install, switch it back to the Git-backed marketplace only with user confirmation:

```powershell
codex plugin marketplace remove workflow-os
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

### Setup Is Incomplete

Run the missing mandatory setup flow:

```text
$jira-setup
$documentation-setup
```

Do not rerun `$welcome` unless onboarding itself is incomplete or the user wants to redo first-time setup.
