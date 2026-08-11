# Task Schema

Each task is a JSON object inside the `tasks` array.

## Required Fields

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

## Field Reference

| Field | Purpose |
| --- | --- |
| `id` | Stable unique ID used for local edits and archiving. Do not reuse it. |
| `displayId` | Human-friendly task number shown in the UI, such as `T-001`. |
| `title` | Task name or subject. |
| `source` | Where the task came from, such as `Manual`, `Jira`, `Email`, `Meeting`, or `Project`. |
| `project` | Project, team, queue, or category. |
| `priority` | Usually `High`, `Medium`, or `Low`. |
| `status` | Current state, such as `Open`, `Planning`, `Waiting`, `Blocked`, or `Done`. |
| `owner` | Person accountable for the task. |
| `type` | Work type, such as `Task`, `Project`, `Follow-up`, `Incident`, or `Process`. |
| `link` | Optional URL. If present, the task title and task number become clickable. |
| `evidence` | Short source note, meeting name, ticket key, or completion metric. |
| `due` | Optional due date. ISO format `YYYY-MM-DD` works best. |
| `score` | Optional sort weight. Higher values appear first inside views. |
| `lane` | View lane. Use `now`, `next`, `waiting`, or `archive`. |
| `progressPct` | Optional project completion percentage, from `0` to `100`. |

## Lane Guidance

Use `now` for work that should be visible immediately.

Use `next` for active backlog and near-future work.

Use `waiting` for blocked, delegated, paused, or dependency-driven work.

Use `archive` for completed work that should remain visible in historical records.

