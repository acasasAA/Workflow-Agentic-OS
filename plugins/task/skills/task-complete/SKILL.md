---
name: task-complete
description: Complete or close a Workflow OS task or agenda item. Writes final task-state, optionally drafts/posts a Jira completion comment with confirmation, and clears active_task when appropriate.
---

# `$task-complete` — Complete One-Off Task

You are completing a task, not a project.

## Memory access rule

Use the exposed memory-engine MCP tools when available. If `mcp__memory-engine__memory_search` or `mcp__memory-engine__memory_write` is not exposed in the active conversation, use the supported helper instead:

```powershell
$argsJson = '<json arguments>'
node "${memory_plugin_root}/scripts/memory-call.mjs" <memory_search|memory_write|memory_recall> $argsJson
```

Resolve `memory_plugin_root` from `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`. If the helper fails, stop and report that task memory is unavailable. Do not create repo-local markdown files or other substitutes unless the user explicitly asks for a file export.

## Step 1 — Resolve active task

Call `${plugin_root}/scripts/active-task.ps1`. If `active_task` is null, ask for the task slug or Jira key and resolve via memory search.

Show the task slug, Jira key if any, due date if any, and current status. Ask for confirmation to complete.

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

If yes, load `${plugin_root}/../jira/references/emoji-format.md` and `${plugin_root}/../jira/references/jira-tooling.md`, draft a concise ✅ comment, show it, and get explicit confirmation. Then use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

Do not transition the Jira ticket unless the user explicitly asks for a transition as a separate confirmed action. If the task belongs to a Jira-synced personal task board, update only the approved issue fields from the current-turn write manifest.

## Step 5 — Clear active_task

Call `${plugin_root}/scripts/active-task.ps1 -Set ""` if the completed task is the active task. For an agenda containing multiple open items, keep the agenda active unless the user asks to clear it.

## Hard rules

- No Jira write without explicit confirmation.
- No Jira transition unless explicitly requested.
- No deletes.
- Do not clear `active_project`.
