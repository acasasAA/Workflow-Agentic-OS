---
name: jira-setup
description: Configure standalone Workflow OS Jira defaults for a teammate. Use when the user installs only WOS Jira or wants Jira project defaults without the full Workflow OS onboarding flow.
---

# `$jira-setup` — Jira-First Setup

You are configuring the user's standalone Workflow OS Jira profile. This setup is intentionally lightweight and does not require Workflow OS Memory Engine, Project, Task, or Onboarding plugins.

## Required References

Load these before asking questions:

- `${plugin_root}/../references/jira-standard.md`
- `${plugin_root}/../references/emoji-format.md`
- `${plugin_root}/../references/jira-tooling.md`

## Step 1 — Explain Scope

Briefly tell the user:

- This setup configures Jira defaults only.
- Full Workflow OS project/task/memory modules are optional.
- Jira reads are allowed; Jira writes still require explicit confirmation.
- Jira deletes/archive remain blocked.

## Step 2 — Jira Tenant

Ask for the Jira tenant. For Athens, default to:

```text
https://athensadmin.atlassian.net
```

Accept a site URL or site host. Normalize to a full `https://...` URL in the final profile.

## Step 3 — Jira Projects

Ask:

```text
Which Jira spaces/projects are you part of? Select all that apply:
- ASD — IT Team Ticketing System
- TPM — Project management board run by Tim Akramy
- Additional Jira spaces/projects — optional
```

If the user selects additional projects, ask for comma-separated Jira project keys and optional plain-language notes.

Examples:

```text
AJD — Jira administration/configuration
HR — HR technology work
```

Do not hardcode Anthony-specific projects such as `AJD` or `GPT` as product defaults. Only record them when the user provides them.

## Step 4 — Primary Jira Usage

Ask:

```text
What is your primary Jira use? Select all that apply:
- Helpdesk tickets
- Project/task tracking
- Jira administration/configuration
- Development work
- Leadership/status review
```

Use the answer to tailor default recommendations, not to restrict capabilities.

## Step 5 — Defaults By Work Type

Always propose:

```text
Support/tickets -> ASD
IT project work -> TPM
```

If the user did not select ASD or TPM in Step 3, ask whether those defaults should be omitted or added.

If the user provided additional Jira projects, ask how those projects should be used.

Example:

```text
AJD -> Jira administration/configuration
GPT -> AI/dev project work
```

## Step 6 — Tooling Check

Check available Jira tooling when possible:

- Atlassian Rovo app connector availability, if exposed in the current session.
- `acli --version`
- `acli jira auth status`

Do not require `acli` for setup, but recommend it for deterministic fallback, especially comments.

If `acli` is installed but not authenticated, suggest:

```powershell
acli jira auth login --web
```

Do not handle or request tokens in chat.

## Step 7 — Output Profile

Show the final profile in concise JSON-like form:

```json
{
  "jira_tenant": "https://athensadmin.atlassian.net",
  "jira_projects": ["ASD", "TPM"],
  "additional_jira_projects": [],
  "default_project_by_work_type": {
    "support": "ASD",
    "project_tracking": "TPM"
  },
  "primary_jira_usage": ["helpdesk tickets", "project/task tracking"]
}
```

If Workflow OS Memory Engine is available, ask whether to save this as a user preference note. If memory is unavailable, provide the profile for the user to keep and continue without failing.

## Step 8 — Finish

Tell the user they can now use:

- `$jira-create`
- `$jira-review`
- `$jira-update`
- `$jira-mod`

For the full Workflow OS suite, tell them they can optionally install:

- `wos-onboarding`
- `wos-memory-engine`
- `wos-project`
- `wos-task`

## Hard Rules

- Do not require full Workflow OS onboarding.
- Do not write Jira during setup.
- Do not store secrets.
- Do not assume optional Jira projects.
- Do not modify files directly unless the user explicitly asks for a file export.
