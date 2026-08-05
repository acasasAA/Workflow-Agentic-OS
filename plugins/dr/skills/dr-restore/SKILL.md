---
name: dr-restore
description: Restore Workflow OS-owned state from a selected Disaster Recovery snapshot. Use only with explicit user confirmation.
---

# Workflow OS DR Restore

Restore is a high-impact local operation and must be explicit.

## Required confirmation

Before restoring, show the selected snapshot path and say what will be overwritten:

- `~/.codex/workflow-os.json`
- `<data_root>/.agent/local.json`
- `<data_root>/.index/memory.db` plus WAL/SHM companions when present

Do not restore until the user confirms in the current turn.

## Procedure

1. List available snapshots:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Get-WosDrStatus.ps1" -ListSnapshots
```

2. Ask the user to choose a snapshot.
3. After explicit confirmation, run:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Restore-WosSnapshot.ps1" -SnapshotPath "<snapshot-path>"
```

4. Tell the user to fully close and reopen Codex after restore.

Do not attempt to restore native Codex chat/sidebar sessions.
