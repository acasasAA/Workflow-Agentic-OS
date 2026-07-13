---
name: jira-create
description: Create a Jira work item (epic, task, subtask, or ticket) outside of a project flow. Use this when the user wants to manually create a Jira item without starting a project. Requires explicit confirmation before the write executes. Applies the mandatory Workflow OS emoji-formatted description.
---

# `$jira-create` — Manual Jira Work-Item Creation

You are creating a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/jira-standard.md` before asking for fields. Use it to choose the smallest correct issue type and project default.
Load `${plugin_root}/../references/emoji-format.md` before drafting any text. The description **must** follow that format (Objective / Scope / Acceptance / Links / Notes).
Load `${plugin_root}/../references/jira-tooling.md` before choosing Jira tooling.

## Steps

1. **Ask the user for:**
   - **Type**: epic, task, subtask, or helpdesk/support ticket. Use `jira-standard.md` if the user is unsure.
   - **Project key** (e.g. `ASD`, `TPM`). If unknown, use the Athens defaults in `jira-standard.md` and ask the user to confirm.
   - **Parent key**, if applicable (task under an epic, subtask under a task).
   - **Title**: one-line summary following §3 conventions in `emoji-format.md`; use exactly one lead emoji.
   - **Objective**: one to three sentences.
   - **Scope**: in-scope / out-of-scope bullets if available.
   - **Acceptance criteria**: bullet list or Given/When/Then.

2. **Run the creation quality checklist** from `jira-standard.md`. If the project, issue type, title, objective, or acceptance/desired outcome is unclear, ask before drafting.

3. **Draft the description** using the §2 skeleton from `emoji-format.md`. Show the user the draft.

4. **Confirm before writing.** Display the proposed payload:
   ```
   Type: <type>
   Project: <key>
   Parent: <key or none>
   Title: <title>
   Description:
   <full body>
   ```
   Ask: "Create this in Jira? (yes/no)"

5. **On yes**: use the Jira tooling order from `jira-tooling.md`. Prefer `mcp__codex_apps__atlassian_rovo._createjiraissue`; if Rovo is unavailable, use the matching `acli jira workitem create` flow after confirming required fields. Capture the returned key.

6. **On success**, tell the user the key + URL. If Workflow OS memory-engine is available, optionally write a `reference` note linking the new Jira key; if memory is unavailable, do not fail the Jira workflow.

7. **On no**, ask what to change. Loop on step 3.

## Hard rules

- **No deletes/archive ever** — do not use Jira delete or archive operations through Rovo, `acli`, or any other path.
- **No secrets** in titles, descriptions, or comments.
- **Authorization is per-action**: each create gets its own confirmation. Don't batch.
- **If the project is wrong**, abort and ask. Don't guess.
- **Standalone behavior**: this skill must work with only `wos-jira` installed. Do not require memory-engine, project, or task plugins.
