---
name: task-update
description: Lightly update the currently active one-off Workflow OS task. Use for quick status, blocker, or next-action refreshes. Use $task-checkpoint instead when the user wants a deliberate high-signal save point.
---

# `$task-update` — Lightweight Task Update

You are making a lightweight task-state update for a ticket-sized task. Keep this short and operational. If the user wants a deliberate save point with narrative, blockers, and next-action capture, route them to `$task-checkpoint`.

## Step 1 — Resolve task

Call `${plugin_root}/scripts/active-task.ps1`.

If `active_task` is null, ask for the task slug or Jira key, then search memory:

```json
{ "type": "task-state", "query": "<slug-or-jira-key>", "limit": 5 }
```

Let the user choose one.

## Step 2 — Read current state

Call `mcp__memory-engine__memory_search`:

```json
{ "type": "task-state", "project": "<task-slug>", "limit": 1 }
```

Show current status and next action briefly.

## Step 3 — Gather lightweight update

Ask:

1. What changed?
2. Current status: active, waiting, blocked, resolved, cancelled.
3. Next action.
4. Blockers, if any. Keep this brief.

## Step 4 — Write updated task-state

Call `memory_write` with `type: "task-state"`, `source: "wos-task"`, and `project: "<task-slug>"`. Include the new status, next action, blockers, and a concise update note in the body.

## Step 5 — Optional Jira comment

Ask whether to post a Jira comment only if a Jira key exists.

If yes, load `${plugin_root}/../../jira/references/emoji-format.md`, draft the comment, show it, get explicit confirmation, then call `mcp__atlassian-rovo__add_comment`.

## Hard rules

- No Jira write without explicit confirmation.
- No deletes.
- Keep task updates short.
- Use `$task-checkpoint` for deliberate task save points.
- Use `$project-checkpoint` for project-level checkpoints.
