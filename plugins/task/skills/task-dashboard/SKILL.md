---
name: task-dashboard
description: Create or refresh the optional WOS Task static dashboard from existing WOS task-state agenda receipts. Use when a user wants their dashboard to include their current WOS Task items instead of sample tasks, or wants a GitHub Pages-ready task dashboard export.
---

# `$task-dashboard` - Optional Task Dashboard Export

You are creating or refreshing the optional static dashboard companion for `wos-task`.

Use the script:

```powershell
${plugin_root}/scripts/Export-WosTaskDashboard.ps1
```

Default behavior:

- Read existing `task-state` receipts from `wos-memory-engine`.
- Pull agenda rows from `frontmatter_extras.tasks`.
- Copy the dashboard template into an output folder.
- Write `data/tasks.json`.
- Inject the same generated task seed into `index.html` so local file preview works.

Recommended command:

```powershell
${plugin_root}/scripts/Export-WosTaskDashboard.ps1 -OutputDir <dashboard-repo-or-folder>
```

For a single agenda:

```powershell
${plugin_root}/scripts/Export-WosTaskDashboard.ps1 -AgendaSlug personal-agenda -OutputDir <dashboard-repo-or-folder>
```

Hard rules:

- Do not publish personal task data to a public repository by default.
- Remind the user to use a private dashboard repository when the generated data includes internal names, tickets, meetings, or email subjects.
- This dashboard remains optional. The canonical WOS Task state stays in memory receipts unless the user explicitly exports it.
- Do not write to Jira from this skill.

