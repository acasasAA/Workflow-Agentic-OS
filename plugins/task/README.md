# WOS Task

`wos-task` manages Codex-native task agendas, meeting action capture, one-off task lifecycle, checkpoints, completion, and optional Jira personal task-board sync.

## Optional Dashboard Template

The static dashboard template lives at:

```text
plugins/task/templates/task-dashboard
```

Use it when a user wants a deployable visual task board alongside `$task-agenda`. It is optional: the normal WOS Task agenda still works without a dashboard, GitHub Pages, or a backend.

To create a dashboard that includes the user's existing WOS Task agenda rows, run:

```powershell
plugins/task/scripts/Export-WosTaskDashboard.ps1 -OutputDir <dashboard-folder>
```

The exporter reads local `task-state` receipts from `wos-memory-engine`, writes `data/tasks.json`, and injects the same data into `index.html` for local preview.

To publish the dashboard, push the generated dashboard folder to a private standalone GitHub repository and enable GitHub Pages with GitHub Actions.
