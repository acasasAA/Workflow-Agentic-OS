---
name: project-resume
description: Explicitly switch the active project context mid-session. Use when the user is already inside a Codex session and wants to change which project Workflow OS treats as active. NOT needed for the normal "start a new chat in a project directory" case — that's handled automatically by the SessionStart hook. This is the escape hatch.
---

# `$project-resume` — Switch Active Project (Manual)

You are switching the active project context inside an already-running Codex session.

> **Note:** the common case — opening Codex in a project's directory and picking up where you left off — happens **automatically** via the `wos-project` SessionStart hook. The user shouldn't need this skill for that. They invoke `$project-resume` only when they want to switch from one project to another mid-session, or when auto-resume failed and they want to force it.

## Step 1 — Pick the project

Ask the user which project to resume. To help, offer to list candidates:

Call `mcp__memory-engine__memory_search`:

```json
{ "type": "project-state", "limit": 10 }
```

Show the user the slugs + names + statuses. Let them pick. If they already named one, skip the picker.

## Step 2 — Load context (in parallel where possible)

Call these three searches:

```json
{ "type": "project-state",   "project": "<slug>", "limit": 1 }
{ "type": "checkpoint",      "project": "<slug>", "limit": 1 }
{ "type": "session-summary", "project": "<slug>", "limit": 3 }
```

## Step 3 — Update active_project

Set `<data_root>/.agent/local.json` → `active_project = "<slug>"`. (Use the documented project-script helper if memory-engine doesn't expose a `local_state.write` verb.)

## Step 4 — Summarize the picture

In 3-5 bullets, tell the user:

- **Project**: name, Jira key, current phase.
- **Last checkpoint** (date): one-line summary.
- **Recent activity** (last 3 session-summaries): collapsed bullet.
- **Open blockers** (if any).
- **Suggested next action** based on the checkpoint's `next_actions` field.

## Step 5 — Stand by

Don't take further action. Wait for the user to direct what they want to do in this project.

## Hard rules

- **Don't write any memory notes in this skill** — it's pure context-switch.
- **Don't touch Jira.** Read-only context loading.
- **If the user's cwd doesn't match the resumed project's directory**, mention it and ask whether they want to `cd` (don't auto-cd — that's a side effect outside Codex's normal flow).
