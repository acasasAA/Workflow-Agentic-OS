---
name: task-complete
description: Complete or close a one-off Workflow OS task. Writes final task-state, optionally drafts/posts a Jira completion comment with confirmation, and clears active_task.
---

# `$task-complete` — Complete One-Off Task

You are completing a task, not a project.

## Step 1 — Resolve active task

Call `${plugin_root}/scripts/active-task.ps1`. If `active_task` is null, ask for the task slug or Jira key and resolve via memory search.

Show the task slug, Jira key, and current status. Ask for confirmation to complete.

## Step 2 — Capture outcome

Ask:

1. What was done?
2. Any validation or evidence?
3. Any follow-up needed?

## Step 3 — Write final task-state

Call `mcp__memory-engine__memory_write`:

```json
{
  "type": "task-state",
  "source": "wos-task",
  "project": "<task-slug>",
  "title": "<task-slug>-state",
  "body": "<final outcome, validation, follow-up>",
  "frontmatter_extras": {
    "task_slug": "<task-slug>",
    "jira_key": "<key-or-null>",
    "status": "complete",
    "completed_at": "<ISO timestamp>",
    "follow_up": "<follow-up-or-null>"
  }
}
```

## Step 4 — Optional Jira completion comment

If a Jira key exists, ask whether to post a completion comment.

If yes, load `${plugin_root}/../../jira/references/emoji-format.md`, draft a concise ✅ comment, show it, get explicit confirmation, then call `mcp__atlassian-rovo__add_comment`.

Do not transition the Jira ticket unless the user explicitly asks for a transition as a separate confirmed action.

## Step 5 — Clear active_task

Call `${plugin_root}/scripts/active-task.ps1 -Set ""`.

## Hard rules

- No Jira write without explicit confirmation.
- No Jira transition unless explicitly requested.
- No deletes.
- Do not clear `active_project`.
