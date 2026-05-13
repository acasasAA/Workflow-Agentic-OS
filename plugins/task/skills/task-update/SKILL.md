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

If yes, load `${plugin_root}/../jira/references/emoji-format.md` and `${plugin_root}/../jira/references/jira-tooling.md`, draft the comment, show it, and get explicit confirmation. Then use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

## Hard rules

- No Jira write without explicit confirmation.
- No deletes.
- Keep task updates short.
- Use `$task-checkpoint` for deliberate task save points.
- Use `$project-checkpoint` for project-level checkpoints.
