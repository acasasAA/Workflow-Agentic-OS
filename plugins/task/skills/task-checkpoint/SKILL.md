---
name: task-checkpoint
description: Write a deliberate checkpoint for the currently active one-off Workflow OS task. Use when the user wants a high-signal save point for ticket-sized work, capturing status, blockers, next action, and narrative.
---

# `$task-checkpoint` — Task Checkpoint

You are writing a deliberate checkpoint for a task. This is the task equivalent of `$project-checkpoint`, but lighter and focused on ticket-sized work.

## Step 1 — Resolve active task

Call `${plugin_root}/scripts/active-task.ps1`.

If `active_task` is null, ask for a task slug or Jira key and search memory:

```json
{ "type": "task-state", "query": "<slug-or-jira-key>", "limit": 5 }
```

Let the user choose one, then call `${plugin_root}/scripts/active-task.ps1 -Set <task-slug>` if they want it active.

## Step 2 — Read current state

Call `mcp__memory-engine__memory_search`:

```json
{ "type": "task-state", "project": "<task-slug>", "limit": 1 }
```

Show the current status, Jira key, blocker, and next action. Confirm whether they are still accurate.

## Step 3 — Gather checkpoint content

Ask for:

1. **Status**: active, waiting, blocked, resolved, cancelled.
2. **Blockers/dependencies**: empty if none.
3. **Next action**: one concrete next step.
4. **Narrative**: 2-4 sentences about what changed, what is known, and what needs attention.

## Step 4 — Write checkpoint

Call `mcp__memory-engine__memory_write`:

```json
{
  "type": "checkpoint",
  "source": "wos-task",
  "project": "<task-slug>",
  "title": "<task-slug>-checkpoint-<short-date>",
  "body": "<narrative plus optional sections for blockers and next action>",
  "frontmatter_extras": {
    "task_slug": "<task-slug>",
    "scope": "task",
    "status": "<status>",
    "blockers": ["..."],
    "next_action": "<next action>"
  }
}
```

## Step 5 — Update task-state

Call `memory_write` again with `type: "task-state"`, `source: "wos-task"`, and `project: "<task-slug>"` to refresh the canonical task state with the latest status, blockers, and next action.

## Step 6 — Optional Jira sync

If the task has a Jira key, ask whether to post a checkpoint comment.

If yes, load `${plugin_root}/../jira/references/emoji-format.md`, draft the comment, show it, get explicit confirmation, then call `mcp__atlassian-rovo__add_comment`.

## Hard rules

- One task checkpoint per invocation.
- No Jira write without explicit confirmation.
- No Jira transition from this skill.
- No deletes.
- Use `$task-update` for quick lightweight status refreshes; use `$task-checkpoint` for deliberate save points.
