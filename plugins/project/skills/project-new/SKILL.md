---
name: project-new
description: Start a new Workflow OS project. Asks for name, description, and Jira linkage (existing key OR creates one). Writes the initial project-state memory note, sets active_project in local.json, drops a WOS.md marker in cwd, then hands off to Codex plan mode for phase scoping. Use whenever the user is starting a new piece of scoped work — whether a long project or a one-off ticket (a ticket is just a tiny project here).
---

# `$project-new` — Start a Workflow OS Project

You are creating a new Workflow OS project. This is the entry point for all scoped work.

If the user already has an existing workspace folder they want to bring into Workflow OS, direct them to `$project-import` instead. `$project-new` is for brand-new work; `$project-import` is for one selected existing folder.

## Step 1 — Name & description

Ask:
1. **Project name** (short, human-readable).
2. **Description** (one to three sentences — what is this and why now).

Derive a **slug** from the name (lowercase, hyphenated, ≤30 chars). Confirm the slug with the user before proceeding.

## Step 2 — Jira linkage

Ask the user: "Do you have an existing Jira epic or ticket for this work?"

- **If yes**: ask for the Jira key (e.g. `PHX-100`). Call `mcp__atlassian-rovo__get_issue` to fetch metadata. Confirm the title/type match what the user means.
- **If no**: ask whether this should be a Jira **epic** (multi-phase project) or a **ticket** (one-off task / support work). Offer to create it. Creation is a write op — load `${plugin_root}/../../jira/references/emoji-format.md` and draft the description in the §2 skeleton. Show the user, get explicit confirmation, then call `mcp__atlassian-rovo__create_issue`.

Record the resulting `jira_key` (whether existing or just-created).

## Step 3 — Write `project-state`

Call `mcp__memory-engine__memory_write`:

```json
{
  "type": "project-state",
  "source": "wos-project",
  "project": "<slug>",
  "title": "<slug>-state",
  "body": "<markdown body with description, scope, links>",
  "frontmatter_extras": {
    "name": "<name>",
    "jira_key": "<key>",
    "jira_type": "epic|ticket",
    "phase": null,
    "status": "active",
    "next_milestone": null
  }
}
```

## Step 4 — Mark cwd as the project's working directory

Drop a `WOS.md` file in cwd with frontmatter:

```markdown
---
project_slug: <slug>
jira_key: <key>
created: <ISO timestamp>
---

# <Name>

<Description>

This file marks the working directory for the `<slug>` Workflow OS project.
```

`WOS.md` is registered as a `project_doc_fallback_filename` in `~/.codex/config.toml`, so Codex will cascade-load it like an AGENTS.md. The `wos-project` plugin's SessionStart hook reads `project_slug` from it for auto-resume.

## Step 5 — Update `local.json`

Set `active_project = "<slug>"` in `<data_root>/.agent/local.json`. (Use the memory-engine MCP if a `local_state.write` verb exists; otherwise, this is the documented exception where a plugin script touches local.json directly via `${plugin_root}/scripts/active-project.ps1 -Set <slug>` — see scripts/ for the helper.)

## Step 6 — Hand off to plan mode

Tell the user:

> Project scaffolded. Enter Codex plan mode with `/plan` to define the phases of this project. When you exit plan mode, I'll offer to push the phases to Jira under `<jira_key>` as **tasks or subtasks** (you'll pick).

Wait for the user to run `/plan` and complete planning. (You're the LLM — the user drives plan mode; you observe.)

## Step 7 — Push phases to Jira (after plan exits)

When the user exits plan mode and the plan is visible, do this:

1. Extract phases from the plan as a numbered list.
2. Decide parent/child shape:
   - If `jira_type == "epic"`, phases become **tasks** under the epic.
   - If `jira_type == "ticket"`, phases become **subtasks** under the ticket.
   - Ask the user to confirm the shape if it's ambiguous.
3. Show the user:
   ```
   Push these N items to Jira under <jira_key> as <tasks|subtasks>?
   1. <phase 1 title>
   2. <phase 2 title>
   ...
   ```
4. On confirmation, loop calling `mcp__atlassian-rovo__create_issue` once per phase. Use the emoji-format description skeleton, filling in just the **Objective** for each. Acceptance criteria can be added later.
5. Record each created key in the `project-state` note (call `memory_write` again to update, or surface the keys for the user to track).

## Hard rules

- **No automatic Jira writes.** Every create gets explicit confirmation.
- **No deletes.** If a wrong subtask gets created, the user removes it manually in Jira (per `.agent/boundaries.md` §1).
- **No secrets in `WOS.md`, project-state, or Jira descriptions.**
- **The slug is permanent** — once written, don't rename it. Slug collisions: ask the user to pick a new one.
