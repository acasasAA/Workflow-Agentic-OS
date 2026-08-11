---
name: jira-create
description: Create a Jira work item (epic, task, subtask, or ticket) outside of a project flow. Use this when the user wants to manually create a Jira item without starting a project. Requires explicit confirmation before the write executes. Applies the mandatory Workflow OS emoji-formatted description.
---

# `$jira-create` — Manual Jira Work-Item Creation

You are creating a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/setup-gate.md` first. If Jira setup is not complete, stop and send the user to `$jira-setup` before doing anything else.
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

2. **Apply project-specific safeguards** from `jira-standard.md`:

   - **For project boards such as `TPM`, `AJD`, `GPT`, `HMB`, or infrastructure boards**: if the project supports Epics and Tasks, prioritize Epic / Task / Subtask creation. Before drafting a create payload, search/list relevant existing Epics in that project using the user's context. Show likely matching Epics and ask whether this work belongs under one of them. Prefer creating a Task under an existing Epic. Do not create a new Epic unless the user explicitly confirms there is no existing project/Epic and they are authorized to create a new project container. Do not use ASD-style AI issue/request types for these project boards unless the user explicitly says the target project is configured that way.
   - **For `ASD`**: ask the ASD ticket-type question the first time a team member asks Workflow OS to create an ASD ticket in the current setup/context. Clarify whether the ticket should be an `AI Gen Issue` or an `AI Gen Request`. Use `AI Gen Issue` for problems/symptoms/incidents/investigation. Use `AI Gen Request` for planned work, setup, configuration, fulfillment, follow-up, or non-incident action. Ask when ambiguous. Resolve available issue/request types when tooling exposes them; if names differ, choose the matching AI-related type that contains `AI`. Before drafting the final payload, verify and show both the Jira issue type and the service/request type that the selected tool path will send. If the selected Rovo or `acli` create path cannot verify or set the required AI-related ASD issue/request type, stop before writing instead of creating the ticket with a guessed or wrong type.

3. **Run the creation quality checklist** from `jira-standard.md`. If the project, issue type, title, objective, or acceptance/desired outcome is unclear, ask before drafting.

4. **Draft the description** using the §2 skeleton from `emoji-format.md`. Show the user the draft.

5. **Confirm before writing.** Display the proposed payload:
   ```
   Type: <type>
   Project: <key>
   Jira issue type: <exact issue type to send>
   Service/request type: <exact AI-related request type, or n/a>
   Parent: <key or none>
   Title: <title>
   Description:
   <full body>
   ```
   Ask: "Create this in Jira? (yes/no)"

6. **On yes**: use the Jira tooling order from `jira-tooling.md`. Prefer `mcp__codex_apps__atlassian_rovo._createjiraissue`; if Rovo is unavailable, use the matching `acli jira workitem create` flow after confirming required fields. Capture the returned key.

7. **On success**, tell the user the key + URL. If Workflow OS memory-engine is available, optionally write a `reference` note linking the new Jira key; if memory is unavailable, do not fail the Jira workflow.

8. **On no**, ask what to change. Loop on step 4.

## Hard rules

- **No deletes/archive ever** — do not use Jira delete or archive operations through Rovo, `acli`, or any other path.
- **No secrets** in titles, descriptions, or comments.
- **Authorization is per-action**: each create gets its own confirmation. Don't batch.
- **If the project is wrong**, abort and ask. Don't guess.
- **Project-board safeguard**: for project boards such as `TPM`, `AJD`, `GPT`, `HMB`, or infrastructure boards, do not create a new Epic/project container without first checking relevant existing Epics and getting explicit user confirmation. Prefer Epic / Task / Subtask shapes over ASD-style AI issue/request types.
- **ASD safeguard**: do not create an ASD ticket until `AI Gen Issue` vs `AI Gen Request` is clarified and the actual AI-related issue type/request type payload is verified. If the tool cannot verify or set the correct ASD issue/request type, stop.
- **Standalone behavior**: this skill must work with only `wos-jira` installed. Do not require memory-engine, project, or task plugins.
