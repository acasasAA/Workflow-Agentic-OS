# Workflow OS Jira Standard

Workflow OS Jira is the lightweight, standalone module for consistent Jira work across Athens IT.

It can be installed by itself. Users do not need Workflow OS Memory Engine, Project, Task, or Onboarding to use the Jira standard.

## Purpose

Use WOS Jira when the team needs consistent Jira issue creation, updates, description cleanup, and closure notes.

It standardizes:

- issue type selection
- Jira titles
- descriptions
- progress comments
- blocker updates
- closure comments
- worklogs
- no-delete / no-archive guardrails
- Rovo-first / Atlassian CLI fallback tooling

## Skills

- `$jira-setup`: configure Jira tenant, project membership, and work-type defaults without installing the full Workflow OS suite.
- `$jira-create`: create a new Jira Epic, Task, Subtask, or helpdesk/support ticket using the WOS description structure.
- `$jira-update`: add a structured Jira comment using WOS status markers.
- `$jira-review`: review an existing Jira item against the Athens IT Jira standard before changing it.
- `$jira-mod`: update or reformat a Jira description while preserving useful content.

## Recommended Team Workflow

1. Run `$jira-setup` once to record Jira tenant, project membership, and default project choices.
2. Use `$jira-create` for new work after confirming the correct project, issue type, and parent.
3. Use `$jira-update` for progress, blockers, handoffs, and completion notes.
4. Use `$jira-review` on existing messy or unclear Jira items.
5. Use `$jira-mod` when the description is stale, incomplete, or missing structure.

## Default Athens Projects

- `ASD`: main IT ticketing / service desk work.
- `TPM`: IT project management work.

Other Jira projects should be used only when the user knows the work belongs there.

## Project-Specific Creation Guardrails

For `TPM`, most users should create Tasks or Subtasks under existing Epics. Before creating new TPM work, WOS Jira should search/list relevant existing TPM Epics from the available context, show likely matches, and ask whether the new work belongs under one of them. New Epics should be created only when the user explicitly confirms this is a new project container and they are authorized to create it.

For `ASD`, WOS Jira must clarify whether the user needs `AI/Gen Issue` or `AI/Gen Task` before creating the ticket. Use `AI/Gen Issue` for problems, symptoms, incidents, access issues, or investigation/resolution. Use `AI/Gen Task` for planned work, setup, configuration, follow-up, or other non-incident actions.

## Safety

- Jira reads are allowed.
- Jira writes require explicit confirmation in the current turn.
- Jira deletes and archives are blocked for agents.
- If cleanup requires deletion, the user must do it manually in Jira.
- Do not place secrets, tokens, passwords, or API keys in Jira text.

## Install Only WOS Jira

First add the Workflow OS marketplace:

```powershell
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

Then open Codex:

```text
/plugins
```

Install only:

```text
wos-jira
```

Then run:

```text
$jira-setup
```

Full Workflow OS is optional. Users who want project/task/memory/orchestration workflows can also install:

```text
wos-onboarding
wos-memory-engine
wos-project
wos-task
```

Optional but recommended for Jira comment fallback:

```powershell
acli jira auth login --web
```

## Release Readiness Checklist

Before broad rollout, verify:

- `$jira-setup` captures ASD/TPM/additional-project defaults without requiring full WOS onboarding.
- `$jira-create` creates a correctly formatted test item after confirmation, including TPM Epic checks and ASD `AI/Gen Issue` vs `AI/Gen Task` clarification.
- `$jira-update` posts an emoji-structured comment after confirmation.
- `$jira-review` identifies missing title/description/next-action details.
- `$jira-mod` shows before/after diff and updates the description after confirmation.
- Rovo exact-key reads work.
- ACLI fallback is authenticated and can read/comment.
- Delete/archive paths are not used.
