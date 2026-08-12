# Optional WOS Task Dashboard Setup

This dashboard is an optional companion for the `wos-task` plugin. It gives you a visual task board with Board, Matrix, Command, and List views, while keeping the normal WOS Task agenda workflow intact.

The template does not include anyone's private task data. It ships with sample tasks, then each teammate runs the exporter to populate it with their own WOS Task items.

## What You Get

- Static HTML dashboard
- GitHub Pages deployment workflow
- Local browser memory for edits, archives, notes, and view preference
- WOS Task exporter that pulls your existing agenda rows from local WOS memory
- Sample task data as a fallback
- No backend required

## Source Template

Template folder:

https://github.com/acasasAA/Workflow-Agentic-OS/tree/main/plugins/task/templates/task-dashboard

## Step 1: Update Workflow OS

If Workflow OS is already installed from the Git marketplace, open Codex `/plugins` and upgrade Workflow OS.

If Workflow OS is not installed yet, register the marketplace:

```powershell
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

Then install or upgrade `wos-task`.

## Step 2: Create Your Dashboard Folder

Clone the Workflow OS repo:

```powershell
git clone https://github.com/acasasAA/Workflow-Agentic-OS.git
cd Workflow-Agentic-OS
```

Create or clone a standalone dashboard repository, then run the exporter into that folder:

```powershell
plugins/task/scripts/Export-WosTaskDashboard.ps1 -OutputDir C:\Path\To\Your\DashboardRepo
```

For only one agenda, such as `personal-agenda`:

```powershell
plugins/task/scripts/Export-WosTaskDashboard.ps1 -AgendaSlug personal-agenda -OutputDir C:\Path\To\Your\DashboardRepo
```

The exporter copies the template, writes `data/tasks.json`, and injects the same generated tasks into `index.html` so the dashboard works locally and from GitHub Pages.

## Step 3: Deploy With GitHub Pages

In the new dashboard repository:

```powershell
git add .
git commit -m "Deploy WOS task dashboard"
git push origin main
```

Then in GitHub:

1. Open the dashboard repository.
2. Go to `Settings` > `Pages`.
3. Set `Source` to `GitHub Actions`.
4. Save.

The included workflow deploys the dashboard after each push to `main`.

## Step 4: Refresh Your Tasks Later

Rerun the exporter any time your WOS Task agenda changes:

```powershell
plugins/task/scripts/Export-WosTaskDashboard.ps1 -OutputDir C:\Path\To\Your\DashboardRepo
```

Then commit and push the updated dashboard repo.

## Task Data Shape

The exporter writes tasks in this shape:

Each task should follow this shape:

```json
{
  "id": "sample-task",
  "displayId": "T-001",
  "title": "Do the thing",
  "source": "Manual",
  "project": "Operations",
  "priority": "High",
  "status": "Open",
  "owner": "Team Owner",
  "type": "Task",
  "link": "",
  "evidence": "Source note",
  "due": "",
  "score": 80,
  "lane": "now",
  "progressPct": ""
}
```

Valid lanes:

- `now`
- `next`
- `waiting`
- `archive`

## Important Privacy Note

Use a private dashboard repository if your task data includes internal tickets, meeting notes, names, email subjects, or project details.

The WOS public/shared template should stay generic. Your personal or team task data should live only in your own private dashboard repo unless it is intentionally public.

## How This Relates To WOS Task

`wos-task` remains the task capture and agenda workflow.

The dashboard is only a visual layer. It does not replace WOS memory, Jira, Outlook, Zoom, or Fathom workflows. It is meant to make the output easier to scan, archive, and share when you want a web dashboard.
