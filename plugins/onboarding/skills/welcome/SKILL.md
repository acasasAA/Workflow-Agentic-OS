---
name: welcome
description: Run the Workflow OS first-time setup. Use this when the user has just installed Workflow OS and needs role-tailored onboarding, foundation tool validation, local workflow-os-data scaffolding, local memory defaults, Jira defaults, OneDrive backup setup, and installation guidance for the remaining core plugins. Should normally run once per machine.
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
5. If the leadership subrole is **Director**, ask the director focus from the manifest:
   - Dev / DBA Director
   - Project Management Director
   - IT Director
   Merge the selected focus's `recommended_tools` and `extra_questions` with the Director defaults. A Dev / DBA Director also inherits the Development / DBA expectation that both Azure Boards and Jira may be active tracking systems.
6. Ask the Codex **Work mode** preference:
   - **For coding**: more technical responses and control.
   - **For everyday work**: same power, less technical detail.
   Recommend the role's `codex_work_mode_guidance` when present, but let the user choose either mode. This setting is a Workflow OS preference; it mirrors the Codex Settings > General > Work mode UI and should guide tone/detail, not reduce safety checks or tool access.
7. Ask the role's 3-5 tailoring questions from the manifest. For IT Leadership, use the selected subrole's questions plus any selected Director focus questions.

Use the answers to build:

- `role_id`
- `role_label`
- optional `leadership_subrole`
- optional `director_focus`
- `codex_work_mode_preference`
- optional `tracking_systems`
- optional `additional_platforms`
- optional `additional_tool_recommendations`
- `role_tailoring` object with question/answer pairs
- `work_style` default from the role manifest, adjusted for the selected Work mode and only with details the user provided
- `recommended_tools` from the role manifest, merged with Director focus tools when applicable

## Step 2 — Foundation tool validation

Run `${plugin_root}/scripts/detect-tools.ps1`. Summarize in three groups:

- Required for Workflow OS core: Codex CLI, Git, Node.js.
- Recommended for Athens users: GitHub Desktop, local Workflow OS memory engine, Atlassian Rovo app connector, Atlassian CLI (`acli`), Outlook Email connector, Outlook Calendar connector.
- Optional / role-based: SharePoint MCP, Azure CLI, Azure DevOps CLI Extension, Azure Boards, AWS CLI or AWS MCP/connector, Power BI CLI/MCP, Power Automate CLI/MCP, Microsoft Learn MCP/CLI, Superpowers Plugin.

For each item, report:

- installed and usable
- installed but not on PATH/configured
- missing

Rules:

- Required missing tools pause onboarding. Offer confirmed install/fix commands using available package managers, preferring `winget` then Chocolatey. If no package manager is available, provide manual install guidance.
- Recommended missing tools should be explained and offered, but the user may continue.
- Optional/role-based tools should only be suggested when the selected role makes them useful or the user asks for advanced tooling.
- If optional role-based tools are missing on a maintainer or non-target machine, report them as "not needed for your selected role unless you want them." Keep them in team rollout guidance for teammates whose role needs them.
- MCPs/connectors may require Codex plugin/connector UI setup rather than shell install. Do not pretend a CLI package exists if the detector cannot verify one.
- Azure Boards is the Azure DevOps work-tracking equivalent to Jira. For Development / DBA and Dev / DBA Director users, ask whether Azure Boards, Jira, or both are used for day-to-day work, then keep both systems in the user's profile when they use both.
- AWS app connector/MCP availability depends on the current Codex install set. If unavailable, recommend AWS CLI now and note the connector/MCP as a future/additional setup item.
- No install command runs without explicit confirmation in the current turn.

## Step 3 — Additional workflow platforms

After required tools are installed or confirmed usable, ask:

> Are there any other platforms, SaaS tools, cloud systems, ticketing systems, databases, dashboards, or internal apps you access in your normal workflow?

If the user says no, record `additional_platforms: []` and continue.

If they name platforms, process each one:

1. Ask how they use it if the workflow is unclear.
2. Search Codex tool discovery for matching MCP servers, app connectors, and plugins when tool discovery is available.
3. Search local/package-manager CLI availability when appropriate, using package-manager search commands such as `winget search <platform>` or `choco search <platform>` if those package managers are present.
4. Prefer official vendor tools/connectors for enterprise systems. Clearly mark community, adjacent, or unofficial options.
5. Add relevant results to `additional_tool_recommendations`; do not install or connect anything without explicit confirmation in the current turn.

Record each platform with:

- `platform_name`
- `workflow_use`
- `available_connectors_or_mcps`
- `available_clis`
- `recommended_setup`
- `status`
- `notes`

These additions are personal to the teammate and augment the packaged role recommendations; they do not become global required tools.

## Step 4 — Paths

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

## Step 5 — Jira defaults

Ask for Jira tenant URL. Suggest `https://athensadmin.atlassian.net` only when appropriate for Athens users.

Default primary Jira project keys for deployable Athens installs:

- `ASD` — main IT ticketing system.
- `TPM` — IT project management board.

Do not include user-specific project keys such as `GPT` or `AJD` in product defaults. Users may add extra keys if they name them.

Ask whether there are other Jira project keys the user wants Workflow OS to factor into their setup. Be ready to guide them:

- Explain that a Jira project key is the short prefix before the issue number, such as `ASD` in `ASD-123`.
- Include a key when they regularly create, update, review, report on, or search work in that Jira project.
- Skip a key when they only see it occasionally, only receive links to it, or do not want Workflow OS to treat it as part of their normal work context.
- If they are unsure, ask for one or two example tickets or board names and infer the likely key from the prefix, then ask them to confirm.
- If they ask whether adding a key gives Workflow OS write access, clarify that it only records a preference/default. Jira reads are allowed, but every Jira write still requires explicit confirmation in the current turn.
- If they ask whether private, sensitive, or admin-only projects should be included, recommend including only the key and plain-language usage note; never store secrets, tokens, confidential field values, or sensitive ticket content in setup preferences.
- If they mention a project by name instead of key, offer to help identify the key through Jira/Rovo lookup when available, or ask them to open one ticket and read the prefix.

Record additional keys with plain-language notes, for example:

```text
HR — HR technology support
FIN — Finance systems support
```

Tell the user:

- Jira reads are allowed.
- Jira writes require explicit per-action confirmation.
- Jira deletes/archive are blocked for agents across Rovo and `acli`; they remain manual.

## Step 6 — Core plugins

Core plugin set for every role:

- `wos-onboarding`
- `wos-memory-engine`
- `wos-jira`
- `wos-project`
- `wos-task`

Try to install remaining core plugins only if a real headless install verb exists in this CLI. If not available, instruct the user:

> Type `/plugins` in Codex, then install: `wos-memory-engine`, `wos-jira`, `wos-project`, `wos-task`. Press Enter here when done.

Do not make plugins optional by role.

## Step 7 — Write data files

Direct file writes are allowed during onboarding only because onboarding must set `data_root` before `memory-engine` can start. After `~/.codex/workflow-os.json` points at the selected `data_root`, verify `memory-engine` using the script below before treating setup as complete.

Create:

- `<data_path>/.agent/local.json`
- `<data_path>/memory/users/<username>/preferences.md`
- `<data_path>/memory/projects/`
- `<data_path>/memory/daily/`
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
  "director_focus": "<director-focus-or-null>",
  "codex_work_mode_preference": "for_coding|for_everyday_work",
  "role_tailoring": {},
  "work_style": "<role-tailored default>",
  "tracking_systems": ["Jira"],
  "additional_platforms": [],
  "additional_tool_recommendations": [],
  "data_root": "<data_path>",
  "framework_root": "<framework_path>",
  "memory_store": "<data_path>/.index/memory.db",
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
- Codex Work mode preference
- work style
- tracking systems, especially Jira and Azure Boards for developer/DBA roles
- additional workflow platforms and matched CLI/MCP/app connector recommendations
- Jira defaults
- tool recommendations
- backup choice

Update `~/.codex/workflow-os.json` with `data_root` and `installed: true`.

Then verify the SQLite memory store:

```powershell
${plugin_root}/scripts/verify-memory.ps1 -FrameworkRoot "<framework_path>" -Username "<username>"
```

The verifier must create `<data_path>/.index/memory.db`, write a small `preference` receipt through `wos-memory-engine`, and search it back. If verification fails, report that onboarding created the local config but memory-engine is not ready; do not claim Workflow OS is fully installed until memory verification succeeds.

## Step 8 — Finish

Confirm:

- `local.json` exists.
- preferences note exists.
- memory index folder exists and `<data_path>/.index/memory.db` exists.
- memory verifier wrote and found an onboarding `preference` receipt.
- sentinel points to the selected data root.
- detector reports installed.

Summarize in 5 bullets max. Tell the user:

- Use Jira as the source of truth for active project, task, and action state.
- Use local Workflow OS memory as the receipt/log layer for conversation outcomes and decisions.
- Start project-mode work with `$project-new`.
- After a project plan is uploaded into Jira as phases, use `$project-orchestrate` when parallel orchestration may help.
- Import an existing workspace with `$project-import`.
- Start one-off ticket work with `$task-new`.
- Use `$task-orchestrate` only for one-off tickets with clearly independent streams.

## Failure modes

- **Unwritable path**: stop and report. Do not partially write if the root cannot be created.
- **User aborts mid-flow**: write partial plugin state only if a data root was already created.
- **Memory-engine unreachable after sentinel update**: report a partial install. Local config may exist, but Workflow OS is not fully ready until `verify-memory.ps1` succeeds.
- **Secrets**: never store credentials, tokens, or API keys. Strip tokenized URLs and ask for a clean value.
