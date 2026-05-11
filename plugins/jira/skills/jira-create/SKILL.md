---
name: jira-create
description: Create a Jira work item (epic, task, subtask, or ticket) outside of a project flow. Use this when the user wants to manually create a Jira item without starting a project. Requires explicit confirmation before the write executes. Applies the mandatory Workflow OS emoji-formatted description.
---

# `$jira-create` — Manual Jira Work-Item Creation

You are creating a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/emoji-format.md` before drafting any text. The description **must** follow that format (Objective / Scope / Acceptance / Links / Notes).

## Steps

1. **Ask the user for:**
   - **Type**: epic, task, subtask, or ticket (incident/support).
   - **Project key** (e.g. `PHX`). If unknown, call `mcp__atlassian-rovo__get_project` to list projects.
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

4. **On yes**: call `mcp__atlassian-rovo__create_issue` with the validated payload. Capture the returned key.

5. **On success**, write a `reference` note via the memory-engine MCP linking the new Jira key. Tell the user the key + URL.

6. **On no**, ask what to change. Loop on step 2.

## Hard rules

- **No deletes ever** — Workflow OS's `enabled_tools` allow-list blocks them at the MCP layer; do not attempt.
- **No secrets** in titles, descriptions, or comments.
- **Authorization is per-action**: each create gets its own confirmation. Don't batch.
- **If the project is wrong**, abort and ask. Don't guess.
