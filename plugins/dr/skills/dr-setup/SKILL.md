---
name: dr-setup
description: Configure Workflow OS Disaster Recovery v1. Use when a user installs or updates WOS and needs OneDrive-backed snapshots scheduled every other day or weekly.
---

# Workflow OS DR Setup

You are configuring Workflow OS Disaster Recovery v1.

## Scope

DR v1 backs up WOS-owned continuity, not private Codex app internals.

Guaranteed snapshot scope:

- `~/.codex/workflow-os.json`
- `<data_root>/.agent/local.json`
- `<data_root>/.index/memory.db` plus WAL/SHM companions when present
- `<data_root>/memory/`
- WOS task/project receipts stored in memory-engine
- Active project/task pointers stored in local state
- Installed WOS plugin versions from the local cache
- Project marker inventory from configured OneDrive project roots

Best-effort project continuity:

- `WOS.md` markers
- Project folder paths under configured OneDrive project roots
- Optional shallow copies of project marker/planning files when configured by the script

Out of scope:

- Exact Codex sidebar thread/task resurrection
- Direct modification of Codex private app databases
- Jira, Confluence, email, or Teams writes

## Procedure

1. Explain that DR v1 restores WOS continuity, tasks, projects, settings, and memory, but not native Codex UI threads.
2. Resolve the plugin root from this skill path.
3. Run:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Install-WosDrSchedule.ps1"
```

4. If the user wants every-other-day snapshots, use:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Install-WosDrSchedule.ps1" -Frequency EveryOtherDay
```

5. If the user has a designated OneDrive Codex projects folder, pass it explicitly:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Install-WosDrSchedule.ps1" -ProjectsRoot "<path>"
```

6. After setup, run:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Get-WosDrStatus.ps1"
```

7. Report the backup folder, schedule, and latest snapshot path.
