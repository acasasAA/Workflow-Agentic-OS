---
name: dr-status
description: Show Workflow OS Disaster Recovery configuration, schedule, latest snapshot, and warnings.
---

# Workflow OS DR Status

Run:

```powershell
pwsh -NoProfile -File "<plugin_root>/scripts/Get-WosDrStatus.ps1"
```

Summarize:

- whether DR is configured
- backup root
- schedule
- latest snapshot
- project roots
- warnings
