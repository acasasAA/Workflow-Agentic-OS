# Workflow OS — Core Engine Manual

This is the system layer. It defines *how* Workflow OS operates. Per-user preferences and per-project state override anything here.

## 1. Architecture in one paragraph

Workflow OS is a plugin host that runs inside Codex. Plugins bundle prompts, hooks, scripts, and MCP servers to deliver coherent capabilities. Memory is a local Obsidian vault indexed by SQLite FTS5, accessed exclusively through the `memory-engine` MCP server. Backup/export can use OneDrive on demand plus GitHub Desktop versioned snapshots. Jira is the primary external work surface, accessed through the `jira` plugin's MCP wrapper with write confirmation and no-delete allow-lists.

## 2. The two repositories

- **`workflow-os`** (framework) — plugins, skills, schemas, scripts. Cloned from GitHub. Shared across users. Contains no PII.
- **`workflow-os-data`** (user data) — vault, index, preferences, project state, local config. Created by the `onboarding` plugin on first run. Never committed to the framework repo.

Framework path is recorded as `framework_root` in `local.json`. Data path is `data_root` and defaults to `C:\Users\<user>\workflow-os-data` for deployability. OneDrive backup is recorded separately as `onedrive_backup`.

## 3. Memory model

### 3.1 Substrate

- **Vault**: `<data_root>/vault/` — markdown files with YAML frontmatter. Human-editable in Obsidian.
- **Index**: `<data_root>/.index/memory.db` — SQLite with FTS5. Regenerable from the vault by `memory-engine/scripts/reindex.ps1`. Not backed up.
- **MCP server**: `memory-engine` plugin exposes `memory.search`, `memory.write`, `memory.recall`. All plugins use these; none read or write vault files directly.

### 3.2 Frontmatter contract

Every memory note carries:

```yaml
---
source: <plugin-name or "user">
created: <ISO-8601 UTC>
type: <one of the enum below>
project: <slug or null>
---
```

**`type` enum** (memory-engine validates against this list; extending it means editing memory-engine's schema):

| Type | Written by | Carries |
|---|---|---|
| `project-state` | `project` | name, Jira key, phase, status, next milestone |
| `task-state` | `task` | Jira key, status, priority, owner, next action |
| `checkpoint` | `project` | phase, blockers, next_actions, narrative |
| `decision` | `project`, user | choice + rationale + alternatives |
| `worklog` | `project` | what got done, time spent, Jira worklog link |
| `session-summary` | `project` Stop hook | 3-5 bullets, regenerable |
| `reference` | any | URL, Jira key, doc path |
| `preference` | `onboarding`, user | per-user how-they-work notes |

Plugin-defined extra frontmatter (e.g. `phase`, `blockers`, `jira_key`, `task_slug`) is pass-through — memory-engine stores it and exposes it for filtered search but doesn't validate values.

### 3.3 What memory remembers

The picture, not the transcript. Sessions write summaries on end (not full logs). Projects write decisions, blockers, and next actions (not running narrative). If a fact is regenerable from external sources (Jira, git log, the vault itself), it does not belong in memory.

## 4. Cascading load order

Already documented in `~/.codex/AGENTS.md` §1. Reproduced here for completeness:

```
global AGENTS.md → system.md → boundaries.md → user preferences →
  project AGENTS.md → project state.md
```

Later layers override earlier ones. Conflicts resolve in favor of the more specific layer. Plugins never override safety rails in `boundaries.md`.

## 5. Plugin lifecycle

Plugins follow Codex's native contract (see https://developers.openai.com/codex/plugins/build):

- **Manifest**: `<plugin>/.codex-plugin/plugin.json` (Codex shape — `name`, `version`, `description`, `skills`, `mcpServers`, `hooks`, `interface`).
- **Skills**: `<plugin>/skills/<skill-name>/SKILL.md` with `name` + `description` frontmatter. Invoked as `$<skill-name>`.
- **Hooks**: `<plugin>/hooks/hooks.json` referenced by the manifest's `hooks` field; uses Codex's native event names (`SessionStart`, `PreToolUse`, `PostToolUse`, `PermissionRequest`, `UserPromptSubmit`, `Stop`).
- **MCP servers**: `<plugin>/.mcp.json` referenced by `mcpServers`. Servers are merged into Codex's runtime MCP config on install.

**Install**: framework ships `.agents/plugins/marketplace.json` listing all plugins. User runs `codex plugin marketplace add <framework_root>` (the `bootstrap.ps1` does this). Individual plugins are then installed via Codex's `/plugins` UI or CLI. Onboarding guides installing the rest of the plugin set when headless install is unavailable.

**Role-tailored onboarding**: `$welcome` uses role manifests for Help Desk, IT Operations, System Administration, Project Management, Development / DBA, and IT Leadership subroles. Roles tailor defaults and preferences but do not restrict core capabilities.

**Existing workspace import**: `$project-import` imports one selected workspace at a time. It writes `WOS.md` only to the chosen folder, creates a project-state note, and optionally sets `active_project`. Bulk importing parent folders is out of scope.

**One-off ticket tasks**: `$task-new`, `$task-update`, `$task-checkpoint`, `$task-resume`, and `$task-complete` handle ticket-sized work without creating a project or workspace marker. Tasks write `task-state` notes and can set `active_task` for short-lived context. The task SessionStart hook surfaces `active_task` only when no project `WOS.md` marker is present.

**Onboarding's first-run flag**: the `onboarding` plugin marks itself complete via `local.json.plugin_state.onboarding = { "disabled": true, "completed_at": ... }`. Subsequent SessionStart hooks see the flag and stay silent.

**Uninstall**: handled by Codex's `/plugins` UI. The plugin's memory namespace under `<data_root>/memory/plugins/<name>/` is preserved (renamed to `_archived/<name>-<date>/`) unless the user explicitly clears it.

### 5.1 Codex hook events used

- `SessionStart` — session begin/resume. Matcher filters on source (`startup|resume|clear`).
- `UserPromptSubmit` — user sends a prompt. No matcher.
- `PreToolUse` — before a tool runs. Matcher filters on tool name (e.g. `Bash`, `apply_patch`, `mcp__memory-engine__.*`).
- `PostToolUse` — after a tool runs. Same matcher semantics as PreToolUse.
- `PermissionRequest` — approval needed. Matcher filters on tool name.
- `Stop` — turn completion. No matcher. A `Stop` hook returning `{"decision":"block"}` triggers auto-continuation — use sparingly.

Hook scripts receive a JSON object on stdin (session_id, cwd, hook_event_name, etc., plus event-specific fields). Exit 0 = success, exit 2 = block with reason on stderr. JSON stdout is parsed for structured decisions on most events; plain stdout is added as developer context for `SessionStart`/`UserPromptSubmit`/`Stop`.

## 6. Disaster recovery

| Tier | Mechanism | Recovery |
|---|---|---|
| 1 | Local disk | n/a — primary |
| 2 | OneDrive manual/on-demand backup/export | restore from OneDrive recycle bin or version history |
| 3 | GitHub Desktop versioned snapshots of `workflow-os-data` | `git clone` private data repo |
| 4 | SQLite index | `reindex.ps1` regenerates from vault |

A full recovery from tier 3 on a clean machine: clone framework, clone data repo, run `bootstrap.ps1`, run `reindex`. Target: under 10 minutes.

## 7. Conventions

- **Paths in scripts**: always absolute, read from `local.json`. No hardcoded paths.
- **Runtimes**:
  - **PowerShell** for system ops and hook scripts (state detection, file operations, install/uninstall).
  - **Node.js (LTS)** for all MCP servers. One runtime for the MCP plane keeps the contract clean and matches Codex's own stack.
  - **Python** allowed only when it's clearly the better tool (data wrangling, scientific work). Never for MCP servers.
- **Logging**: plugins log to `<data_root>/.logs/<plugin>/<date>.log`. Rotated weekly.
- **No network calls without an MCP**: every external service goes through a plugin's MCP, never raw HTTP from scripts.
