---
name: dr-snapshot
description: Create an immediate Workflow OS Disaster Recovery snapshot.
---

# Workflow OS DR Snapshot

Use this to create a manual WOS DR v1 snapshot.

Run:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/New-WosSnapshot.ps1"
```

Report:

- snapshot path
- included WOS state files
- memory database status
- project marker count
- any warnings

Do not delete old snapshots unless the user explicitly asks.
