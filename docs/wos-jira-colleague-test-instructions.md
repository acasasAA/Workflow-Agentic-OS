# WOS Jira Colleague Test Instructions

Follow these instructions to install or update WOS Jira and test the latest Jira standard changes.

## 1. Confirm GitHub Repo Access

Confirm the user can open this repo in a browser while signed into GitHub:

[https://github.com/acasasAA/Workflow-Agentic-OS](https://github.com/acasasAA/Workflow-Agentic-OS)

If the user cannot open the repo, stop. They need repo access before continuing.

## 2. Use This Marketplace Source

Use this Git-backed Workflow OS marketplace source:

```text
https://github.com/acasasAA/Workflow-Agentic-OS.git
```

If the marketplace is not already registered, add it:

```powershell
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

If the marketplace already exists, upgrade it:

```powershell
codex plugin marketplace upgrade workflow-os
```

If upgrade fails because the marketplace is not Git-backed, remove and re-add it:

```powershell
codex plugin marketplace remove workflow-os
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

## 3. Install Only WOS Jira First

Open Codex and go to:

```text
/plugins
```

Install or upgrade:

```text
wos-jira
```

Expected version:

```text
v0.2.3
```

Do not require the full Workflow OS suite for this test. The user only needs WOS Jira unless the current rollout owner explicitly asks them to install more.

## 4. First Command To Run

Start a fresh Codex session and run:

```text
$jira-setup
```

During Jira setup, ask the user which Jira spaces/projects they use:

- `ASD` if they use IT tickets.
- `TPM` if they work project/task items.
- Any other Jira spaces only if they actually use them.

## 5. Test Commands

Test the Jira workflow in this order:

```text
$jira-setup
$jira-create
$jira-update
$jira-review
$jira-mod
```

## 6. Important Behavior To Verify

Make sure the installed plugin is:

```text
wos-jira v0.2.3
```

That is the version with:

- TPM Epic safeguards.
- ASD `AI/Gen Issue` vs `AI/Gen Task` clarification.
- ASD/helpdesk issue type and request type verification before creation.
- Jira setup first.
- Jira create second.
- Jira update third.
- Review and mod last.

## 7. TPM Safeguard

For `TPM`, do not create a new Epic by default.

Before creating TPM work:

- Check/list relevant existing TPM Epics when context is available.
- Ask whether the new work belongs under an existing Epic.
- Prefer creating Tasks or Subtasks under existing Epics.
- Create a new Epic only when the user explicitly confirms it is a new project container and they are authorized to create it.

## 8. ASD Safeguard

For `ASD`, clarify the request type before creating the ticket:

- `AI/Gen Issue`: use for problems, symptoms, incidents, broken behavior, access issues, investigation, or resolution.
- `AI/Gen Task`: use for planned work, setup, configuration, follow-up, or non-incident action.

If ambiguous, ask before creating anything.

Before confirming the Jira write, show both:

```text
Jira issue type: <exact issue type to send>
Service/request type: AI/Gen Issue or AI/Gen Task
```

If the tool cannot set the correct request type, stop instead of creating a ticket with the wrong type.

## 9. Safety Rules

- Jira reads are allowed.
- Jira writes require explicit confirmation in the current turn.
- Jira deletes and archives are blocked for agents.
- Do not store or post secrets.
- Stop at the first real failure and show the exact error plus the next recommended action.
