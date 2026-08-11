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

## 3. Install WOS Onboarding First

Open Codex and go to:

```text
/plugins
```

Install or upgrade:

```text
wos-onboarding
```

Then run `$welcome`. When onboarding asks, install mandatory:

```text
wos-jira
wos-documentation
```

Expected Jira version:

```text
v0.2.5
```

Expected Documentation version:

```text
v0.1.7
```

Memory, project, and task plugins are optional unless the current rollout owner explicitly asks them to install more.

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
wos-jira v0.2.5
```

That is the version with:

- Mandatory first-use setup gate.
- Project-board Epic safeguards for `TPM`, `AJD`, `GPT`, `HMB`, infrastructure boards, and similar project spaces.
- ASD `AI Gen Issue` vs `AI Gen Request` clarification.
- ASD AI-related issue type and request type verification before creation.
- Jira setup first.
- Jira create second.
- Jira update third.
- Review and mod last.

## 7. Project-Board Safeguard

For project boards such as `TPM`, `AJD`, `GPT`, `HMB`, infrastructure boards, and similar project spaces, prioritize Epic / Task / Subtask shapes when those issue types are available. Do not create a new Epic by default.

Before creating project-board work:

- Check/list relevant existing Epics in the target project when context is available.
- Ask whether the new work belongs under an existing Epic.
- Prefer creating Tasks or Subtasks under existing Epics.
- Create a new Epic only when the user explicitly confirms it is a new project container and they are authorized to create it.
- Do not use ASD-style AI issue/request types for project boards unless the user explicitly says the target project is configured that way.

## 8. ASD Safeguard

For `ASD`, clarify the ticket type before creating the ticket, especially the first time a team member asks Workflow OS to create an ASD ticket:

- `AI Gen Issue`: use for problems, symptoms, incidents, broken behavior, access issues, investigation, or resolution.
- `AI Gen Request`: use for planned work, setup, configuration, fulfillment, follow-up, or non-incident action.

If ambiguous, ask before creating anything.

If the exact ASD request type names differ, inspect the available issue/request types when tooling exposes them and choose the matching value that contains `AI`. If multiple AI-related candidates exist, show them and ask the user to choose.

Before confirming the Jira write, show both:

```text
Jira issue type: <exact issue type to send>
Service/request type: <exact AI-related request type to send, or n/a>
```

If the tool cannot set the correct request type, stop instead of creating a ticket with the wrong type.

## 9. Safety Rules

- Jira reads are allowed.
- Jira writes require explicit confirmation in the current turn.
- Jira deletes and archives are blocked for agents.
- Do not store or post secrets.
- Stop at the first real failure and show the exact error plus the next recommended action.
