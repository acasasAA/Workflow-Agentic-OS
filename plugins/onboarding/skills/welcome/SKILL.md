---
name: welcome
description: Run the Workflow OS first-time setup. Use this when the user has just installed Workflow OS and needs role-tailored onboarding, foundation tool validation, local workflow-os-data scaffolding, mandatory Jira, Documentation, and DR setup, optional plugin selection, Jira defaults, OneDrive backup setup, and installation guidance. Should normally run once per machine.
---

# Workflow OS — First-Run Setup

You are running the `welcome` skill from the `wos-onboarding` plugin. Your job is to complete a deployable, one-and-done Workflow OS setup for an Athens IT user. Do not skip steps. Ask concise questions, explain why each path/tool matters in plain language, and never run install commands or external writes without explicit confirmation. Do not mark onboarding complete until mandatory Jira setup, mandatory Documentation setup, and mandatory DR setup are complete.

## References

Load these before asking role/tool questions:

- `${plugin_root}/references/role-manifests.json`
- `${plugin_root}/references/tool-catalog.json`

## Preconditions

1. Run `${plugin_root}/scripts/detect-state.ps1`. Parse the JSON output.
2. If `state == "installed"`, stop and tell the user Workflow OS is already installed. Suggest `$project-new`, `$project-import`, or `$project-resume` depending on what they want next. Do not offer destructive reset as a normal user flow.
3. If `state == "partial"` and `setup_missing` is non-empty, tell the user Workflow OS setup is not complete. List the missing mandatory setup markers and route them through `$jira-setup`, `$documentation-setup`, and/or `$dr-setup` as needed. Do not continue to normal project/task/documentation/Jira work until mandatory setup is complete.
4. If `state == "partial"` for missing files only, list present vs missing files. Ask whether to repair the install. Wipe/restart is a developer-test recovery path only and requires explicit confirmation.
5. Otherwise (`state == "missing"`), proceed with fresh install.

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
4. **Team**, using polished labels from `role-manifests.json` `team_options`:
   - Help Desk
   - Infrastructure / Operations
   - System Administration
   - Project Management
   - Development / DBA
   - IT Leadership
   - Other
   Treat the team answer as the source for team-gated plugin availability. If the answer maps to Development / DBA, set `is_development_team: true` and make `wos-azure-boards` available later in the optional plugin picker. For every other team, keep `wos-azure-boards` hidden unless the user explicitly says they are setting up a development-team profile.
5. If role is **IT Leadership**, ask for subrole:
   - Supervisor
   - Manager
   - Director
   - VP
   - Exec VP
6. If the leadership subrole is **Director**, ask the director focus from the manifest:
   - Dev / DBA Director
   - Project Management Director
   - IT Director
   Merge the selected focus's `recommended_tools` and `extra_questions` with the Director defaults. A Dev / DBA Director also inherits the Development / DBA expectation that both Azure Boards and Jira may be active tracking systems, but `wos-azure-boards` still only appears in the plugin picker when the Team answer maps to Development / DBA.
7. Ask the Codex **Work mode** preference:
   - **For coding**: more technical responses and control.
   - **For everyday work**: same power, less technical detail.
   Recommend the role's `codex_work_mode_guidance` when present, but let the user choose either mode. This setting is a Workflow OS preference; it mirrors the Codex Settings > General > Work mode UI and should guide tone/detail, not reduce safety checks or tool access.
8. Ask the role's 3-5 tailoring questions from the manifest. For IT Leadership, use the selected subrole's questions plus any selected Director focus questions.

Use the answers to build:

- `role_id`
- `role_label`
- optional `leadership_subrole`
- optional `director_focus`
- `team_id`
- `team_label`
- `is_development_team`
- `codex_work_mode_preference`
- optional `tracking_systems`
- optional `additional_platforms`
- optional `additional_tool_recommendations`
- `available_plugins` after applying team gates
- `role_tailoring` object with question/answer pairs
- `work_style` default from the role manifest, adjusted for the selected Work mode and only with details the user provided
- `recommended_tools` from the role manifest, merged with Director focus tools when applicable

## Step 2 — Foundation tool validation

Run `${plugin_root}/scripts/detect-tools.ps1`. Summarize in three groups:

- Required for Workflow OS core: Codex CLI, Git, Node.js.
- Recommended for Athens users: GitHub Desktop, local Workflow OS memory engine, Atlassian Rovo app connector, Atlassian CLI (`acli`), Outlook Email connector, Outlook Calendar connector, Zoom connector.
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
- Azure Boards is the Azure DevOps work-tracking destination used by the development team. Jira remains the overall team-space platform across Athens IT; for Development / DBA users, Jira and Azure Boards may both be active day-to-day tracking systems and neither should be described as replacing or outranking the other for the dev team.
- Only suggest Azure Boards tooling when `is_development_team` is true, when a Dev / DBA Director explicitly sets up a development-team profile, or when the user explicitly asks about Azure Boards. For Development / DBA team users, ask whether Azure Boards, Jira, or both are used for day-to-day work, then keep both systems in the user's profile when they use both.
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

## Step 6 — Mandatory and optional plugins

`wos-onboarding` is already installed because the user is running `$welcome`.

Mandatory plugin set for every role:

- `wos-jira`
- `wos-documentation`
- `wos-dr`

Try to install mandatory plugins only if a real headless install verb exists in this CLI. If not available, instruct the user:

> Type `/plugins` in Codex, then install: `wos-jira`, `wos-documentation`, and `wos-dr`. Press Enter here when all three are installed.

After mandatory plugins are installed, run their first-use setup flows before continuing:

1. Run the `$jira-setup` flow and capture the final Jira profile. Use the Jira tenant and project keys already collected in Step 5 as defaults, but still ask the Jira setup questions. If the user abandons or declines to finish Jira setup, stop onboarding and tell them Workflow OS cannot continue until `$jira-setup` is complete.
2. Run the `$documentation-setup` flow and capture the final Documentation route profile. If the user does not know every route yet, allow specific routes to be marked unconfigured, but the setup flow itself must finish and record the profile shape. If the user abandons or declines to finish Documentation setup, stop onboarding and tell them Workflow OS cannot continue until `$documentation-setup` is complete.
3. Run the `$dr-setup` flow and configure OneDrive-backed WOS DR v1 snapshots. Use weekly snapshots by default unless the user chooses every-other-day snapshots. If the user has a designated OneDrive folder for Codex project folders, provide that path during DR setup. Then run `$dr-snapshot` once. If the user abandons or declines to finish DR setup, stop onboarding and tell them Workflow OS cannot continue until `$dr-setup` is complete.

Optional plugin set:

- `wos-memory-engine`
- `wos-project`
- `wos-task`
- `wos-azure-boards` **only when `is_development_team` is true**

Ask which optional plugins the user wants to install, using a numbered picker:

```text
Optional Workflow OS plugins:
1. wos-memory-engine - local SQLite receipt/log memory.
2. wos-project - project lifecycle and destination-backed orchestration.
3. wos-task - Codex task agenda, meeting action capture, and optional task-board sync.
4. wos-azure-boards - Azure Boards destination tooling for the development team. [Show only for Development / DBA team profiles.]
5. None for now.
```

When `is_development_team` is false, omit `wos-azure-boards` from the visible picker and renumber "None for now" naturally.

Resolve dependencies before saving:

- Selecting `wos-project` automatically selects `wos-memory-engine`.
- Selecting `wos-task` automatically selects `wos-memory-engine`.
- Selecting `wos-azure-boards` does not automatically select `wos-project` or `wos-task`.
- `wos-jira`, `wos-documentation`, and `wos-dr` remain mandatory regardless of optional selections.
- For development-team profiles, explain that Jira is the shared Athens IT team-space platform while Azure Boards is the development team's delivery-tracking destination; the user may install either destination tooling they actually use, and may use both.

Install selected optional plugins only when a real headless install verb exists in this CLI. If not available, instruct the user to install the resolved optional list through `/plugins`, then press Enter here when done. Do not pressure-install optional plugins the user did not select.

## Step 7 — Write data files

Direct file writes are allowed during onboarding only because onboarding must set `data_root` and persist mandatory setup state before the other Workflow OS plugins can rely on it. After `~/.codex/workflow-os.json` points at the selected `data_root`, verify `memory-engine` only if `wos-memory-engine` is in the resolved optional plugin list.

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
  "team_id": "<team id>",
  "team_label": "<team label>",
  "is_development_team": false,
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
  "available_plugins": ["wos-onboarding", "wos-jira", "wos-documentation", "wos-dr", "<team-gated optional plugins>"],
  "installed_plugins": ["wos-onboarding", "wos-jira", "wos-documentation", "wos-dr", "<selected optional plugins>"],
  "optional_plugins_selected": ["<resolved optional plugin list>"],
  "plugin_state": {
    "wos-onboarding": { "disabled": true, "completed_at": "<ISO timestamp>" },
    "wos-jira": { "mandatory": true, "setup_completed_at": "<ISO timestamp>" },
    "wos-documentation": { "mandatory": true, "setup_completed_at": "<ISO timestamp>" },
    "wos-dr": { "mandatory": true, "setup_completed_at": "<ISO timestamp>", "backup_root": "<onedrive-backup-path>", "frequency": "Weekly|EveryOtherDay", "latest_snapshot": "<snapshot-path>" }
  }
}
```

The preferences note must include frontmatter `type: preference`, then readable sections for:

- identity and role
- team profile and team-gated plugin availability
- role-tailoring answers
- Codex Work mode preference
- work style
- tracking systems, especially Jira and Azure Boards for Development / DBA team profiles
- additional workflow platforms and matched CLI/MCP/app connector recommendations
- Jira defaults
- tool recommendations
- backup choice
- mandatory plugin setup status for `wos-jira`, `wos-documentation`, and `wos-dr`
- optional plugin selections

Update `~/.codex/workflow-os.json` with `data_root` and `installed: true`.

If `wos-memory-engine` is selected, verify the SQLite memory store:

```powershell
${plugin_root}/scripts/verify-memory.ps1 -FrameworkRoot "<framework_path>" -Username "<username>"
```

The verifier must create `<data_path>/.index/memory.db`, write a small `preference` receipt through `wos-memory-engine`, and search it back. If verification fails and `wos-memory-engine` was selected, report that onboarding created the local config but memory-engine is not ready; do not claim Workflow OS is fully installed until memory verification succeeds.

If `wos-memory-engine` is not selected, do not run memory verification and do not require `<data_path>/.index/memory.db`. Still create `<data_path>/.index/` so the user can add memory-engine later.

## Step 8 — Finish

Confirm:

- `local.json` exists.
- preferences note exists.
- memory index folder exists.
- if `wos-memory-engine` was selected, `<data_path>/.index/memory.db` exists and the memory verifier wrote/found an onboarding `preference` receipt.
- `plugin_state.wos-jira.setup_completed_at` exists.
- `plugin_state.wos-documentation.setup_completed_at` exists.
- `plugin_state.wos-dr.setup_completed_at` exists.
- WOS DR has created a first snapshot in the configured OneDrive backup root.
- sentinel points to the selected data root.
- detector reports installed.

Summarize in 5 bullets max. Tell the user:

- Use Jira as the shared Athens IT team-space platform for active work visibility.
- For Development / DBA team profiles that selected Azure Boards, use Azure Boards and Jira according to the profile's day-to-day tracking answer; neither is greater than the other for dev delivery work.
- If `wos-memory-engine` was selected, use local Workflow OS memory as the receipt/log layer for conversation outcomes and decisions.
- If `wos-memory-engine` was not selected, tell the user they can add it later from `/plugins` when they want local receipt memory.
- Start project-mode work with `$project-new`.
- After a project plan is uploaded into Jira as phases, use `$project-orchestrate` when parallel orchestration may help.
- Import an existing workspace with `$project-import`.
- Manage to-do lists and meeting actions with `$task-agenda`.
- Start one-off task or ticket work with `$task-new`.
- Use `$task-orchestrate` only for one-off tasks or tickets with clearly independent streams.

## Failure modes

- **Unwritable path**: stop and report. Do not partially write if the root cannot be created.
- **User aborts mid-flow**: write partial plugin state only if a data root was already created.
- **Memory-engine unreachable after sentinel update**: report a partial install. Local config may exist, but Workflow OS is not fully ready until `verify-memory.ps1` succeeds.
- **Secrets**: never store credentials, tokens, or API keys. Strip tokenized URLs and ask for a clean value.
