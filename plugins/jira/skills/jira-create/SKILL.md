---
name: jira-create
description: Create a Jira work item (epic, task, subtask, or ticket) outside of a project flow. Use this when the user wants to manually create a Jira item without starting a project. Requires explicit confirmation before the write executes. Applies the mandatory Workflow OS emoji-formatted description.
---

# `$jira-create` — Manual Jira Work-Item Creation

You are creating a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/emoji-format.md` before drafting any text. The description **must** follow that format (Objective / Scope / Acceptance / Links / Notes).
Load `${plugin_root}/../references/jira-tooling.md` before choosing Jira tooling.

## Steps

1. **Ask the user for:**
   - **Type**: epic, task, subtask, or ticket (incident/support).
   - **Project key** (e.g. `PHX`). If unknown, use `mcp__codex_apps__atlassian_rovo._search` to find an existing issue in the target project and read its `cloudId`.
   - **Parent key**, if applicable (task under an epic, subtask under a task).
   - **Title**: one-line summary (no emoji, follows §3 conventions in `emoji-format.md`).
   - **Objective**: one to three sentences.
   - **Scope**: in-scope / out-of-scope bullets if available.
   - **Acceptance criteria**: bullet list or Given/When/Then.

2. **Draft the description** using the §2 skeleton from `emoji-format.md`. Show the user the draft.

3. **Confirm before writing.** Display the proposed payload:
   ```
   Type: <type>
   Project: <key>
   Parent: <key or none>
   Title: <title>
   Description:
   <full body>
   ```
   Ask: "Create this in Jira? (yes/no)"

4. **On yes**: use the Jira tooling order from `jira-tooling.md`. Prefer `mcp__codex_apps__atlassian_rovo._createjiraissue`; if Rovo is unavailable, use the matching `acli jira workitem create` flow after confirming required fields. Capture the returned key.

5. **On success**, write a `reference` note via the memory-engine MCP linking the new Jira key. Tell the user the key + URL.

6. **On no**, ask what to change. Loop on step 2.

## Hard rules

- **No deletes/archive ever** — do not use Jira delete or archive operations through Rovo, `acli`, or any other path.
- **No secrets** in titles, descriptions, or comments.
- **Authorization is per-action**: each create gets its own confirmation. Don't batch.
- **If the project is wrong**, abort and ask. Don't guess.
