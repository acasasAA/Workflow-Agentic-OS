---
name: project-new
description: Start a new Workflow OS project. Use strictly for scoped project work with phases, a workspace, or ongoing continuity. Writes the initial project-state memory note, sets active_project in local.json, drops a WOS.md marker in cwd, then hands off to Codex plan mode for phase scoping.
---

# `$project-new` — Start a Workflow OS Project

You are creating a new Workflow OS project. This skill is strictly for project-mode work: scoped initiatives with phases, a working directory, durable continuity, or a larger delivery outcome.

If the user asks for a one-off Jira ticket, support task, quick operational item, or work that does not need a workspace marker and phase plan, stop and route them to `$task-new`. Do not continue inside `$project-new`.

If the user already has an existing workspace folder they want to bring into Workflow OS, stop and route them to `$project-import`.

## Step 1 — Name & description

Ask:
1. **Project name** (short, human-readable).
2. **Description** (one to three sentences — what is this and why now).

Derive a **slug** from the name (lowercase, hyphenated, ≤30 chars). Confirm the slug with the user before proceeding.

## Step 2 — Jira linkage

Load `${plugin_root}/../jira/references/jira-tooling.md` before choosing Jira tooling.

Ask the user: "Do you have an existing Jira epic or project-level ticket for this project?"

- **If yes**: ask for the Jira key (e.g. `PHX-100`). Prefer `mcp__codex_apps__atlassian_rovo._search` and `mcp__codex_apps__atlassian_rovo._fetch`; if Rovo is unavailable, use `acli jira workitem view "<key>" --json`. Confirm the title/type match what the user means.
- **If no**: ask whether this should be represented in Jira as an **epic** or a **project-level ticket**. Do not offer one-off task creation here. Creation is a write op — load `${plugin_root}/../jira/references/emoji-format.md` and draft the description in the §2 skeleton. Show the user, get explicit confirmation, then use the Jira tooling order from `jira-tooling.md`: prefer `mcp__codex_apps__atlassian_rovo._createjiraissue`; if Rovo is unavailable, use the matching `acli jira workitem create` flow.

Record the resulting `jira_key` (whether existing or just-created).

## Step 3 — Write `project-state`

Call the exposed memory-engine MCP `memory_write` tool when available:

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
    "jira_type": "epic|project-ticket",
    "phase": null,
    "status": "active",
    "next_milestone": null
  }
}
```

If the memory-engine MCP is installed but not exposed as a callable tool in the active conversation, use the supported local helper instead of hand-rolling stdio:

```powershell
$argsJson = '<json arguments for memory_write>'
node "${memory_plugin_root}/scripts/memory-call.mjs" memory_write $argsJson
```

Resolve `memory_plugin_root` from the installed Workflow OS memory-engine plugin path when needed, usually under `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`.

If memory-engine is not installed or the helper fails, stop and report that the project cannot be started yet. Do not create `WOS.md` or update `active_project` without a project-state note unless the user explicitly asks for a marker-only recovery.

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

> Project scaffolded. Enter Codex plan mode with `/plan` to define the phases of this project. When planning is done, I'll upload or update the finalized phases in Jira under `<jira_key>` as **tasks or subtasks** (you'll pick). After Jira reflects the phase structure, `$project-orchestrate` can analyze Jira and offer a dependency-aware execution graph before implementation starts.

Wait for the user to run `/plan` and complete planning. (You're the LLM — the user drives plan mode; you observe.)

## Step 7 — Push phases to Jira (after plan exits)

When the user exits plan mode and the plan is visible, do this:

1. Extract phases from the plan as a numbered list.
2. Decide parent/child shape:
   - If `jira_type == "epic"`, phases become **tasks** under the epic.
   - If `jira_type == "project-ticket"`, phases become **subtasks** under the project-level ticket.
   - Ask the user to confirm the shape if it's ambiguous.
3. Show the user a Jira write manifest:
   ```
   Jira write plan for <jira_key>

   Create/update these N phase items as <tasks|subtasks>:
   1. <phase 1 title>
   2. <phase 2 title>
   ...

   Link dependencies:
   - <phase A> blocks <phase B>   # only for real dependencies
   ```
4. On explicit confirmation in the current turn, execute only the listed Jira writes using the Jira tooling order from `jira-tooling.md`. Use the emoji-format description skeleton for every description. For real dependencies, create Jira issue links when available and also record the dependency in the description. If linking fails, continue with the dependency text and report the warning.
5. Record each created/updated key in the `project-state` note (call `memory_write` again to update, or surface the keys for the user to track).
6. Offer `$project-orchestrate` only after Jira contains the finalized phase structure. `$project-orchestrate` analyzes Jira before implementation; it does not replace planning or phase upload.

## Hard rules

- **No automatic Jira writes.** A batch write manifest may be approved once in the current turn; unlisted writes require fresh confirmation.
- **No deletes.** If a wrong subtask gets created, the user removes it manually in Jira (per `.agent/boundaries.md` §1).
- **No secrets in `WOS.md`, project-state, or Jira descriptions.**
- **The slug is permanent** — once written, don't rename it. Slug collisions: ask the user to pick a new one.
