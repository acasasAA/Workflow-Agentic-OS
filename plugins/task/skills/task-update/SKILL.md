---
name: task-update
description: Lightly update the currently active Workflow OS task or agenda item. Use for quick status, due date, blocker, or next-action refreshes. Use $task-agenda for table updates across multiple items and $task-checkpoint for deliberate high-signal save points.
---

# `$task-update` — Lightweight Task Update

You are making a lightweight task-state update for a task or agenda item. Keep this short and operational. If the user wants to rebuild a full to-do table, route them to `$task-agenda`. If the user wants a deliberate save point with narrative, blockers, and next-action capture, route them to `$task-checkpoint`.

## Memory access rule

Use the exposed memory-engine MCP tools when available. If `mcp__memory-engine__memory_search` or `mcp__memory-engine__memory_write` is not exposed in the active conversation, use the supported helper instead:

```powershell
$argsJson = '<json arguments>'
node "${memory_plugin_root}/scripts/memory-call.mjs" <memory_search|memory_write|memory_recall> $argsJson
```

Resolve `memory_plugin_root` from `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`. If the helper fails, stop and report that task memory is unavailable. Do not create repo-local markdown files or other substitutes unless the user explicitly asks for a file export.

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

Show current status, due date if present, and next action briefly.

## Step 3 — Gather lightweight update

Ask:

1. What changed?
2. Current status: active, waiting, blocked, resolved, cancelled.
3. Next action.
4. Due date/time, if changed.
5. Blockers, if any. Keep this brief.

## Step 4 — Write updated task-state

Call `memory_write` with `type: "task-state"`, `source: "wos-task"`, and `project: "<task-slug>"`. Include the new status, due date if any, next action, blockers, and a concise update note in the body.

## Step 5 — Optional Jira comment

Ask whether to post a Jira comment only if a Jira key exists.

If yes, load `${plugin_root}/../jira/references/emoji-format.md` and `${plugin_root}/../jira/references/jira-tooling.md`, draft the comment, show it, and get explicit confirmation. Then use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

## Hard rules

- No Jira write without explicit confirmation.
- No deletes.
- Keep task updates short.
- Use `$task-checkpoint` for deliberate task save points.
- Use `$project-checkpoint` for project-level checkpoints.
