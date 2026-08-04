---
name: task-agenda
description: Build or update a Workflow OS task agenda table from manual entries, active task memory, email, tickets, calendar, or Zoom when the relevant connectors are available. Use for to-do lists, meeting action capture, and optional Jira personal task-board sync.
---

# `$task-agenda` — Task Keeper And Agenda

You are maintaining a practical to-do list and agenda. The simple setup is managed strictly inside Codex with Workflow OS memory. The advanced setup can optionally sync selected tasks to a user-configured Jira personal task board. Keep those boundaries separate.

Load `${plugin_root}/references/task-agenda-standard.md` and follow it.

## Memory access rule

Use the exposed memory-engine MCP tools when available. If `mcp__memory-engine__memory_search` or `mcp__memory-engine__memory_write` is not exposed in the active conversation, use the supported helper instead:

```powershell
$argsJson = '<json arguments>'
node "${memory_plugin_root}/scripts/memory-call.mjs" <memory_search|memory_write|memory_recall> $argsJson
```

Resolve `memory_plugin_root` from `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`. If the helper fails, continue with an in-chat table only and clearly say the agenda was not saved.

## Step 1 — Determine agenda mode

Use simple Codex-only mode by default.

Simple setup never asks for Jira board details and never writes externally.

Advanced setup starts only if the user asks to populate a Jira board. Then switch to advanced Jira board mode from the agenda standard. Do not assume a Jira project key. Ask for or discover the user's configured personal task-board project key, then get explicit confirmation before writes.

## Step 2 — Resolve agenda

Default agenda slug: `personal-agenda`.

If the user names a meeting, project, day, or list, derive a stable slug from that context and confirm only when changing an existing active agenda would be surprising.

Read the latest memory entry:

```json
{ "type": "task-state", "project": "<agenda-slug>", "query": "scope agenda", "limit": 1 }
```

If there is no prior agenda, start a new table.

## Step 3 — Pull sources when requested

Use only sources the user requested or that are clearly in the current context.

- Manual/chat: parse actionable entries directly from the conversation.
- Tickets/Jira: load `${plugin_root}/../jira/references/jira-tooling.md`; prefer Atlassian Rovo reads, then `acli`.
- Email: use Outlook Email connector when exposed; otherwise say email pull is unavailable.
- Calendar: use Outlook Calendar connector when exposed; otherwise say calendar pull is unavailable.
- Zoom: use Zoom connector when exposed; otherwise accept pasted transcript/summary/notes.

Do not write to any external system while pulling sources.

For meeting notes, Zoom, calendar summaries, transcripts, or live chat notes, apply the meeting action filtering rules from `task-agenda-standard.md`: default to action items assigned to the current user, not every action item mentioned in the meeting.

## Step 4 — Normalize tasks

Convert source material into action items using the agenda standard table columns:

| ID | Task | Source | Owner | Status | Due | Next Action | Links |
| --- | --- | --- | --- | --- | --- | --- | --- |

Use absolute dates/times for deadlines. If a deadline is impossible to resolve from the current date and context, ask one concise clarification.

## Step 5 — Save Codex agenda

Write a `task-state` memory receipt for the agenda using the schema in `task-agenda-standard.md`.

If the user wants the agenda active, call:

```powershell
${plugin_root}/scripts/active-task.ps1 -Set <agenda-slug>
```

## Step 6 — Optional Jira board sync

Only if the user asks for Jira board sync:

1. Confirm Jira project key, issue type, and target fields.
2. Show the exact table rows to create or update.
3. Ask for explicit current-turn confirmation.
4. Use Atlassian Rovo write tools when exposed, otherwise `acli` fallback, following Jira tooling and emoji format.
5. Write the resulting Jira keys back to task memory.

## Step 7 — Output

Return the agenda table first. Then add a short note covering:

- saved or not saved
- active agenda slug
- source pulls that were unavailable
- Jira sync status, if requested

## Hard rules

- Default to Codex-only task keeping.
- Keep simple setup and advanced setup separate.
- Always show the agenda as a table.
- No Jira project-key assumptions.
- No external writes without explicit confirmation in the current turn.
- No Jira deletes or archive operations.
- Do not create `WOS.md` for agendas.
