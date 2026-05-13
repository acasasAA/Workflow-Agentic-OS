---
name: welcome
description: Run the Workflow OS first-time setup. Use this when the user has just installed Workflow OS and needs role-tailored onboarding, foundation tool validation, local workflow-os-data scaffolding, Jira defaults, OneDrive backup setup, and installation guidance for the remaining core plugins. Should normally run once per machine.
---

# Workflow OS — First-Run Setup

You are running the `welcome` skill from the `wos-onboarding` plugin. Your job is to complete a deployable, one-and-done Workflow OS setup for an Athens IT user. Do not skip steps. Ask concise questions, explain why each path/tool matters in plain language, and never run install commands or external writes without explicit confirmation.

## References

Load these before asking role/tool questions:

- `${plugin_root}/references/role-manifests.json`
- `${plugin_root}/references/tool-catalog.json`

## Preconditions

1. Run `${plugin_root}/scripts/detect-state.ps1`. Parse the JSON output.
2. If `state == "installed"`, stop and tell the user Workflow OS is already installed. Suggest `$project-new`, `$project-import`, or `$project-resume` depending on what they want next. Do not offer destructive reset as a normal user flow.
3. If `state == "partial"`, list present vs missing files. Ask whether to repair the install. Wipe/restart is a developer-test recovery path only and requires explicit confirmation.
4. Otherwise (`state == "missing"`), proceed with fresh install.

## Step 1 — Identity and role profile

Ask one question at a time:

1. **Username** used for `memory/users/<username>/`. Suggest `$env:USERNAME`.
2. **Display name**.
3. **Role**, using polished labels from `role-manifests.json`:
   - Help Desk
   - IT Operations
   - System Administration
   - Project Management
   - Development / DBA
   - IT Leadership
4. If role is **IT Leadership**, ask for subrole:
   - Supervisor
   - Manager
   - Director
   - VP
   - Exec VP
5. Ask the role's 3-5 tailoring questions from the manifest. For IT Leadership, use the selected subrole's questions.

Use the answers to build:

- `role_id`
- `role_label`
- optional `leadership_subrole`
- `role_tailoring` object with question/answer pairs
- `work_style` default from the role manifest, adjusted only with details the user provided
- `recommended_tools` from the role manifest

## Step 2 — Foundation tool validation

Run `${plugin_root}/scripts/detect-tools.ps1`. Summarize in three groups:

- Required for Workflow OS core: Codex CLI, Git, Node.js.
- Recommended for Athens users: GitHub Desktop, Obsidian, Atlassian Rovo app connector, Atlassian CLI (`acli`), Outlook Email connector, Outlook Calendar connector.
- Optional / role-based: SharePoint MCP, Azure CLI, AWS CLI or AWS MCP, Power BI CLI/MCP, Power Automate CLI/MCP, Microsoft Learn CLI, Superpowers Plugin.

For each item, report:

- installed and usable
- installed but not on PATH/configured
- missing

Rules:

- Required missing tools pause onboarding. Offer confirmed install/fix commands using available package managers, preferring `winget` then Chocolatey. If no package manager is available, provide manual install guidance.
- Recommended missing tools should be explained and offered, but the user may continue.
- Optional/role-based tools should only be suggested when the selected role makes them useful or the user asks for advanced tooling.
- MCPs/connectors may require Codex plugin/connector UI setup rather than shell install. Do not pretend a CLI package exists if the detector cannot verify one.
- No install command runs without explicit confirmation in the current turn.

## Step 3 — Paths

Explain each path before asking:

- **Framework path**: the Workflow OS engine/repo that makes the OS work. Default comes from `~/.codex/workflow-os.json` → `framework_root`, set by `bootstrap.ps1`.
- **Data path**: local user/project memory and config. Default is `C:\Users\<user>\workflow-os-data`. This is the primary data root for deployability.
- **OneDrive backup folder**: optional org-backed backup/export location. It is not the primary data root. In v2, backups are manual/on-demand; do not promise automatic per-session backup.

Ask:

1. Framework path. Default to sentinel `framework_root`.
2. Data path. Default to `C:\Users\<user>\workflow-os-data`. If the user is explicitly testing, they may choose a sandbox path.
3. Detect OneDrive before asking for backup path:
   - Prefer `C:\Users\<user>\OneDrive - Athens`.
   - Then other `$env:OneDriveCommercial` or `$env:OneDrive` roots.
   - If found, suggest a backup folder under that root.
   - If not found, allow skip or a manual absolute path.
4. GitHub Desktop path. Use detector output or `$env:LOCALAPPDATA\GitHubDesktop`; null if not found and user skips.

Confirm before creating any missing folders.

## Step 4 — Jira defaults

Ask for Jira tenant URL. Suggest `https://athensadmin.atlassian.net` only when appropriate for Athens users.

Default primary Jira project keys for deployable Athens installs:

- `ASD` — main IT ticketing system.
- `TPM` — IT project management board.

Do not include Anthony-specific `GPT` or `AJD` in product defaults. Users may add extra keys if they name them.

Tell the user:

- Jira reads are allowed.
- Jira writes require explicit per-action confirmation.
- Jira deletes/archive are blocked for agents across Rovo and `acli`; they remain manual.

## Step 5 — Core plugins

Core plugin set for every role:

- `wos-onboarding`
- `wos-memory-engine`
- `wos-jira`
- `wos-project`
- `wos-task`

Try to install remaining core plugins only if a real headless install verb exists in this CLI. If not available, instruct the user:

> Type `/plugins` in Codex, then install: `wos-memory-engine`, `wos-jira`, `wos-project`, `wos-task`. Press Enter here when done.

Do not make plugins optional by role.

## Step 6 — Write data files

Use the `memory-engine` MCP if installed and reachable. Otherwise, direct file writes are allowed during onboarding only.

Create:

- `<data_path>/.agent/local.json`
- `<data_path>/memory/users/<username>/preferences.md`
- `<data_path>/memory/projects/`
- `<data_path>/memory/daily/`
- `<data_path>/vault/`
- `<data_path>/vault/.obsidian/`
- `<data_path>/.index/`
- `<data_path>/.logs/`

`local.json` must include at least:

```json
{
  "version": "0.1.0",
  "user": "<username>",
  "display_name": "<display name>",
  "role_id": "<role id>",
  "role_label": "<role label>",
  "leadership_subrole": "<subrole-or-null>",
  "role_tailoring": {},
  "work_style": "<role-tailored default>",
  "data_root": "<data_path>",
  "framework_root": "<framework_path>",
  "vault_path": "<data_path>/vault",
  "onedrive_backup": "<onedrive_path-or-null>",
  "backup_mode": "manual",
  "jira_tenant": "<url>",
  "jira_project_keys": ["ASD", "TPM"],
  "jira_project_notes": {
    "ASD": "Main IT ticketing system; default for Athens IT users.",
    "TPM": "IT project management board; default for Athens IT project work."
  },
  "github_desktop": "<path-or-null>",
  "tool_status": {},
  "active_project": null,
  "active_task": null,
  "installed_plugins": ["wos-onboarding", "wos-memory-engine", "wos-jira", "wos-project", "wos-task"],
  "plugin_state": {
    "wos-onboarding": { "disabled": true, "completed_at": "<ISO timestamp>" }
  }
}
```

The preferences note must include frontmatter `type: preference`, then readable sections for:

- identity and role
- role-tailoring answers
- work style
- Jira defaults
- tool recommendations
- backup choice

Update `~/.codex/workflow-os.json` with `data_root` and `installed: true`.

## Step 7 — Finish

Confirm:

- `local.json` exists.
- preferences note exists.
- vault folder exists.
- sentinel points to the selected data root.
- detector reports installed.

Summarize in 5 bullets max. Tell the user:

- Open Obsidian on `<data_path>/vault/`.
- Start project-mode work with `$project-new`.
- After a project plan is uploaded into Jira as phases, use `$project-orchestrate` when parallel orchestration may help.
- Import an existing workspace with `$project-import`.
- Start one-off ticket work with `$task-new`.
- Use `$task-orchestrate` only for one-off tickets with clearly independent streams.

## Failure modes

- **Unwritable path**: stop and report. Do not partially write if the root cannot be created.
- **User aborts mid-flow**: write partial plugin state only if a data root was already created.
- **Memory-engine unreachable**: fall back to direct onboarding writes and mention the documented exception.
- **Secrets**: never store credentials, tokens, or API keys. Strip tokenized URLs and ask for a clean value.
