---
name: task-new
description: Start a Workflow OS task or agenda item from a manual entry, meeting action, existing Jira ticket, or small support item. Use for to-do items and ticket-sized work that do not need a project workspace, WOS.md marker, phase plan, or long project lifecycle.
---

# `$task-new` — Start Task Or Agenda Item

You are starting a task, not a project. Tasks are for manual to-do items, meeting actions, one-off Jira tickets, support items, small operational asks, or short work that needs memory continuity but not a workspace marker or project plan.

For multi-item agenda capture or source pull from email, tickets, calendar, or Zoom, route to `$task-agenda`.

Load `${plugin_root}/references/task-agenda-standard.md` when the task comes from a manual to-do item or meeting action.

## Memory access rule

Use the exposed memory-engine MCP tools when available. If `mcp__memory-engine__memory_search` or `mcp__memory-engine__memory_write` is not exposed in the active conversation, use the supported helper instead:

```powershell
$argsJson = '<json arguments>'
node "${memory_plugin_root}/scripts/memory-call.mjs" <memory_search|memory_write|memory_recall> $argsJson
```

Resolve `memory_plugin_root` from `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`. If the helper fails, stop and report that task memory is unavailable. Do not create repo-local markdown files or other substitutes unless the user explicitly asks for a file export.

## Step 1 — Task source

Ask what kind of task source this is only if it is not already clear:

- Manual to-do or meeting action: capture task text, owner, due date/time, next action, and source context.
- Existing Jira ticket: ask for the Jira key. Load `${plugin_root}/../jira/references/jira-tooling.md`, then prefer `mcp__codex_apps__atlassian_rovo._search` plus `mcp__codex_apps__atlassian_rovo._fetch`; if Rovo is unavailable, use `acli jira workitem view "<key>" --json` to verify title, status, priority, and assignee. Jira reads are allowed.
- Email, calendar, or Zoom source pull: route to `$task-agenda` unless the user has already provided the action item in chat.

Do not create Jira tickets from this skill. If the user needs a new Jira issue, route to `$jira-create` or `$task-agenda` advanced Jira board mode with explicit write confirmation.

## Step 2 — Task identity

Derive a task slug from the Jira key when present, otherwise from the task title:

- lowercase
- hyphenated
- stable
- examples: `asd-1234`, `prepare-budget-notes`, `follow-up-with-vendor`

Confirm the slug before writing.

## Step 3 — Capture task state

Ask for only what is needed and already missing:

1. Current status or starting point.
2. Priority/urgency if not known from Jira.
3. Next action.
4. Any blocker or dependency.
5. Due date/time, if the task is date-driven.

## Step 4 — Write `task-state`

Call `mcp__memory-engine__memory_write`:

```json
{
  "type": "task-state",
  "source": "wos-task",
  "project": "<task-slug>",
  "title": "<task-slug>-state",
  "body": "<markdown body with title, source, Jira key if any, current state, due date, next action, blockers>",
  "frontmatter_extras": {
    "task_slug": "<task-slug>",
    "name": "<task title>",
    "jira_key": "<key-or-null>",
    "source_type": "manual|meeting|ticket",
    "jira_type": "<ticket-or-null>",
    "status": "active",
    "priority": "<priority-or-null>",
    "due": "<ISO-or-null>",
    "next_action": "<next action>",
    "blockers": ["..."]
  }
}
```

If memory-engine is unavailable, stop and report that task memory is not available yet.

## Step 5 — Make active

Ask:

> Make `<task-slug>` the active Workflow OS task now?

If yes, call `${plugin_root}/scripts/active-task.ps1 -Set <task-slug>`.

Do not set `active_project`. Tasks and projects are separate.

## Step 6 — Finish

Summarize:

- task slug
- Jira key or "none"
- current status
- due date/time, if any
- next action
- whether `active_task` was set

## Hard rules

- No `WOS.md` marker for tasks.
- No phase planning handoff.
- No Jira writes without explicit current-turn confirmation.
- No deletes.
- Route ongoing scoped work to `$project-new` or `$project-import`.
