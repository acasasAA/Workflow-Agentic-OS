# Workflow OS Task Agenda Standard

This standard makes `wos-task` a practical task keeper, not only a Jira ticket wrapper. The simple setup is Codex-only and writes to Workflow OS memory. The advanced setup can optionally sync selected tasks to Jira after the user configures a personal board project key and approves each write.

## Setup Boundary

Keep simple and advanced setup separate.

Simple setup:

- Captures manual to-do items, meeting notes, and user-provided action items inside Codex.
- May read from available connectors when the user asks, but stores the agenda only in Workflow OS memory.
- Outputs a table every time.
- Requires no Jira project key, board id, issue type, workflow field, or assignee mapping.
- Performs no external writes.

Advanced setup:

- Includes everything in simple setup.
- Adds optional Jira personal task-board sync.
- Requires the user's Jira task-board project key and any project-specific issue type or field mapping.
- Stays user-agnostic and project-key-agnostic until the user provides setup values.
- Performs Jira writes only after a current-turn write manifest and explicit confirmation.

Do not drift simple setup into advanced behavior. If the user only wants a Codex-managed agenda, do not ask for Jira board details.

## Task Sources

Supported sources:

- `manual` - typed by the user during chat or a meeting.
- `email` - Outlook Email connector, when installed and exposed.
- `ticket` - Jira via Atlassian Rovo first, then `acli` fallback.
- `calendar` - Outlook Calendar connector, when installed and exposed.
- `zoom` - Zoom connector or meeting transcript/summary, when installed and exposed.

If a connector is missing, continue in simple Codex-only mode and say which source could not be pulled live. Do not invent unseen email, calendar, ticket, or Zoom content.

## Meeting Action Filtering

When collecting meeting data, identify action items directed to the current Workflow OS user first. Use the active user's configured display name, username, email identity, or clear first-person phrasing such as "I will" or "I need to" when available.

Default behavior:

- Include action items assigned to the current user.
- Include unassigned action items only when they are phrased as the user's own commitment or the user asks to track unassigned actions.
- Exclude tasks clearly assigned to someone else unless the user asks for a team agenda, follow-up tracker, or delegation list.
- Preserve the original assignee in `Owner` when the user explicitly asks for team-wide actions.

If assignment is ambiguous, set `Owner` to `me?` or `unassigned?` and ask a concise clarification only when the task would be written to memory or Jira.

## Agenda Table

Always present the working agenda as a table with these columns:

| ID | Task | Source | Owner | Status | Due | Next Action | Links |
| --- | --- | --- | --- | --- | --- | --- | --- |

Rules:

- `ID` is a stable short id such as `T-001`.
- `Task` is an action someone can do, starting with a verb when possible.
- `Source` is one of the supported source labels.
- `Owner` defaults to `me` unless the source clearly says otherwise.
- `Status` is `new`, `active`, `waiting`, `blocked`, `done`, or `cancelled`.
- `Due` should be an absolute date/time when the user gives relative wording.
- `Next Action` is the next concrete move, not a vague goal.
- `Links` contains Jira keys, email subjects, calendar event names, Zoom meeting names, or `none`.

## Manual Capture

When the user says something like "I need to do this on Friday and have it done by 3 PM", extract:

- task text
- due date and time
- owner
- status
- source context

If the date is ambiguous, ask only the minimum clarification. If it is clear from the current date/time, convert it to an absolute date in the table and memory receipt.

## Memory Records

Simple mode writes `task-state` receipts through memory-engine. Use `project` as the task list slug, normally `personal-agenda` unless the user names a different agenda.

Use this shape:

```json
{
  "type": "task-state",
  "source": "wos-task",
  "project": "<agenda-slug>",
  "title": "<agenda-slug>-agenda",
  "body": "<agenda table plus brief notes>",
  "frontmatter_extras": {
    "task_slug": "<agenda-slug>",
    "scope": "agenda",
    "mode": "codex-only",
    "status": "active",
    "tasks": [
      {
        "id": "T-001",
        "task": "<action>",
        "source": "manual|email|ticket|calendar|zoom",
        "owner": "me",
        "status": "new|active|waiting|blocked|done|cancelled",
        "due": "<ISO-or-null>",
        "next_action": "<next action>",
        "links": ["..."]
      }
    ]
  }
}
```

Memory is the continuity ledger. Do not create repo-local agenda files unless the user explicitly asks for an export.

## Advanced Jira Board Mode

Advanced mode is optional and user-agnostic. Never hardcode a Jira project key, board id, issue type, user, assignee, component, or label.

Before any Jira task creation or update:

1. Ask which Jira project key backs the user's personal task board.
2. Read or confirm acceptable issue type and fields for that project.
3. Show a write manifest listing exactly which tasks will be created or updated.
4. Get explicit confirmation in the current turn.

Jira reads are allowed. Jira writes require current-turn confirmation. Jira deletes and archive operations remain blocked.

Jira-synced tasks should still be written to memory with `mode: "jira-board"` and a `jira_key` or `jira_project_key` when known.

## Source Pull Behavior

Use available connectors in this order when the user asks for an agenda from multiple places:

1. Meeting context supplied in chat.
2. Active task memory.
3. Tickets/Jira.
4. Calendar.
5. Email.
6. Zoom.

For each source, summarize only actionable items and ignore FYIs unless the user asks to track them.
