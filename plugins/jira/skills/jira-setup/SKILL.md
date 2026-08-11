---
name: jira-setup
description: Configure standalone Workflow OS Jira defaults for a teammate. Use when the user installs only WOS Jira or wants Jira project defaults without the full Workflow OS onboarding flow.
---

# `$jira-setup` — Jira-First Setup

You are configuring the user's standalone Workflow OS Jira profile. This setup is intentionally lightweight and does not require Workflow OS Memory Engine, Project, Task, or Onboarding plugins. In a full Workflow OS install, this setup is mandatory before any other `wos-jira` skill may continue.

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
- TPM — IT project management board
- Additional Jira spaces/projects — optional
```

If the user selects additional projects, ask for comma-separated Jira project keys and optional plain-language notes. Be ready to guide them through questions:

- Explain that a Jira project key is the short prefix before the issue number, such as `ASD` in `ASD-123`.
- Include a key when they regularly create, update, review, report on, or search work in that Jira project.
- Skip a key when they only see it occasionally, only receive links to it, or do not want Workflow OS to treat it as part of their normal work context.
- If they are unsure, ask for one or two example tickets or board names and infer the likely key from the prefix, then ask them to confirm.
- If they ask whether adding a key gives Workflow OS write access, clarify that it only records a preference/default. Jira reads are allowed, but every Jira write still requires explicit confirmation in the current turn.
- If they ask whether private, sensitive, or admin-only projects should be included, recommend including only the key and plain-language usage note; never store secrets, tokens, confidential field values, or sensitive ticket content in setup preferences.
- If they mention a project by name instead of key, offer to help identify the key through Jira/Rovo lookup when available, or ask them to open one ticket and read the prefix.

Examples:

```text
HR — HR technology work
FIN — Finance systems work
```

Do not hardcode person-specific or team-specific side projects as product defaults. Only record additional projects when the user provides them.

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
HR -> HR technology support
FIN -> Finance systems support
```

If the user names project-board keys such as `AJD`, `GPT`, `HMB`, an infrastructure board, or another board with Epics and Tasks, record them as project-tracking boards. Explain that Workflow OS will prioritize Epic / Task / Subtask shapes for those boards instead of ASD-style AI issue/request types.

If the user names `ASD`, record it as the service-desk path. Explain that ASD creation will ask whether the ticket is an `AI Gen Issue` or an `AI Gen Request`, then verify the exact AI-related issue/request type before writing.

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

Show the final profile in concise JSON-like form. Include a setup completion timestamp:

```json
{
  "jira_tenant": "https://athensadmin.atlassian.net",
  "jira_projects": ["ASD", "TPM"],
  "additional_jira_projects": [],
  "default_project_by_work_type": {
    "support": "ASD",
    "project_tracking": "TPM"
  },
  "primary_jira_usage": ["helpdesk tickets", "project/task tracking"],
  "setup_completed_at": "<ISO timestamp>"
}
```

## Step 8 — Save Setup Marker

If Workflow OS local state is available, save the profile fields into `<data_root>/.agent/local.json` and set:

```json
"plugin_state": {
  "wos-jira": {
    "mandatory": true,
    "setup_completed_at": "<ISO timestamp>"
  }
}
```

Preserve existing `plugin_state` entries and existing user preferences. Do not remove optional plugin selections.

If Workflow OS Memory Engine is available, also ask whether to save this as a user preference note. If memory is unavailable, the local setup marker is still enough for the setup gate.

If neither Workflow OS local state nor Memory Engine is available, provide the profile for the user to keep and clearly state that setup is only complete for the current conversation; future Jira skills may ask for `$jira-setup` again until a persistent WOS profile exists.

## Step 9 — Finish

Tell the user they can now use:

- `$jira-create`
- `$jira-update`
- `$jira-review`
- `$jira-mod`

For the standard Workflow OS onboarding baseline, tell them `wos-documentation` is mandatory alongside `wos-jira`. For deeper Workflow OS workflows, they can optionally install:

- `wos-memory-engine`
- `wos-project`
- `wos-task`

## Hard Rules

- Do not require full Workflow OS onboarding.
- Do not write Jira during setup.
- Do not store secrets.
- Do not assume optional Jira projects.
- Only modify Workflow OS local setup state when saving this Jira setup profile; do not modify unrelated files.
