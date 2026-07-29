# Transfer to a New Computer

Mechanical checklist for moving the v2 framework to a new machine.

## On the old machine (one time)

1. Verify the v2 draft is self-contained:
   ```powershell
   cd "C:\Users\acasas\OneDrive - Athens\Documents\MS DEV\workflow-os\v2"
   Get-ChildItem -Recurse -File | Measure-Object
   ```
2. Push the v2 contents to a private GitHub repo named `workflow-os` via GitHub Desktop.
   - Repo root = the **contents of `v2/`**, not the `v2/` folder itself. `AGENTS.md`, `.agents/plugins/marketplace.json`, `.agent/`, `plugins/`, etc. should be under the repo root.

## On the new machine (clean install)

### Prerequisites

The smooth path expects these:

- **PowerShell 7** — use `pwsh` for Workflow OS install scripts.
- **Codex CLI** — `npm install -g @openai/codex` or the approved internal install path.
- **Node.js LTS** — current LTS, on PATH.
- **git** — for cloning the framework and the data repo's snapshots.
- **GitHub Desktop** — for managing the data repo.

### Steps

Preferred pilot flow:

```powershell
# 1. From the Workflow OS repo, run preflight
pwsh -NoProfile -File .\scripts\install\preflight.ps1

# 2. Prepare Codex config and marketplace
pwsh -NoProfile -File .\scripts\install\setup-codex.ps1
```

If prerequisites are missing, use:

```powershell
pwsh -NoProfile -File .\scripts\install\install-prereqs.ps1 -Install
```

For a single guided entrypoint:

```powershell
pwsh -NoProfile -File .\scripts\install\launch-wos-setup.ps1
```

The setup scripts will, in order:
1. Validate Codex CLI, Node, git on PATH.
2. Detect the best valid Workflow OS checkout without moving or deleting nested folders.
3. Write `~/.codex/workflow-os.json` (sentinel pointing at the framework path).
4. Install `~/.codex/AGENTS.md` (global agent manual) and `~/.codex/AGENTS.override.md` (safety rails — always wins cascades).
5. Merge the WOS-managed block into `~/.codex/config.toml` without replacing user settings.
6. Register the Git-backed `workflow-os` Codex plugin marketplace so `/plugins` upgrades work after changes are pushed.

```powershell
# 3. Start Codex and install plugins
codex
```

Inside Codex:
```
/plugins
```
Install at minimum `wos-onboarding` from the `workflow-os` marketplace. The onboarding skill will guide installation of the other core plugins (`wos-memory-engine`, `wos-jira`, `wos-project`, `wos-task`) as part of its flow.

```
$welcome
```

Walk through the onboarding questions. When it finishes, you'll have a working Workflow OS install pointing at `<data_root>/workflow-os-data/`.

### What `$welcome` does

The onboarding skill (the only thing in `wos-onboarding`) asks for:
- Identity and polished role profile (Help Desk, IT Operations, System Administration, Project Management, Development / DBA, or IT Leadership with subrole).
- Role-tailoring answers that shape defaults and preferences.
- Foundation tool validation (Codex CLI, Git, Node.js required; GitHub Desktop, local Workflow OS memory engine, Atlassian Rovo app connector, Atlassian CLI, Outlook Email/Calendar recommended; other tools optional by role).
- Paths (framework engine path, local data root, optional OneDrive backup/export folder, GitHub Desktop install).
- Jira tenant URL and primary project keys, defaulting Athens users to ASD and TPM only.

Then it:
- Creates local `<data_root>/` with `memory/`, `.index/`, `.logs/`, `.agent/`.
- Writes `<data_root>/.agent/local.json` with all answers.
- Writes `<data_root>/memory/users/<username>/preferences.md`.
- Installs the remaining core plugins via the marketplace.
- Marks itself complete (`plugin_state.wos-onboarding.disabled = true`).

After onboarding:
- Use Jira as the source of truth for active project, task, phase, dependency, and assignment state.
- Use local Workflow OS memory as the receipt/log layer for conversation outcomes, checkpoints, and decisions.
- Start project-mode work with `$project-new`.
- After a project plan is uploaded into Jira as phases, use `$project-orchestrate` to analyze the Jira phase graph and optionally greenlight parallel work.
- Import an existing workspace with `$project-import`; it imports one selected folder only and writes `WOS.md` only there.
- Start one-off ticket work with `$task-new`; it does not create a project or `WOS.md`.
- Use `$task-orchestrate` only when a one-off ticket has clearly independent work streams.
- Save deliberate ticket/task progress with `$task-checkpoint`; quick status changes use `$task-update`.

### Recovery on a future clean machine

Same steps. Plus, before `$welcome`, restore the data repo:
```powershell
git clone https://github.com/<you>/workflow-os-data.git
```
Point `WOS_DATA_ROOT` at the cloned path before running bootstrap, or accept the default location and let onboarding detect the existing install.

After data is restored, verify the local SQLite memory database exists:
```powershell
Test-Path "<data_root>/.index/memory.db"
```

If you are migrating old markdown memory notes, import them explicitly:
```powershell
pwsh -File "<framework_root>/plugins/memory-engine/scripts/reindex.ps1" -LegacyVault "<old_vault_path>"
```

## What NOT to copy

- `workflow-os-data/.index/` — contains the canonical local memory database; transfer or restore it with the data repo/backups.
- `workflow-os-data/.logs/` — local-only; don't transfer.
- Any `plugins/*/mcp/node_modules/` — `npm install` runs automatically on first SessionStart.

## Developer test reset

End-user onboarding is intended to be one-and-done. During product testing only, you can reset and rerun onboarding by:

1. Back up `~/.codex/workflow-os.json`.
2. Set `data_root` to `null` and `installed` to `false`.
3. Optionally remove the sandbox data root used for the test run.
4. Open a fresh Codex session and run `$welcome` again.

Do not present this as a normal end-user uninstall/reset workflow.

## Sanity check after install

```powershell
# Sentinel exists, data_root set
$s = Get-Content "$env:USERPROFILE\.codex\workflow-os.json" -Raw | ConvertFrom-Json
$s.framework_root; $s.data_root

# Global AGENTS.md installed
Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
Test-Path "$env:USERPROFILE\.codex\AGENTS.override.md"

# Marketplace registered
codex plugin marketplace list

# Plugins installed
codex /plugins
```

If marketplace lists `workflow-os` and `/plugins` shows the five `wos-*` plugins enabled, the install is correct. The first Codex session in a directory with a `WOS.md` marker will demonstrate project auto-resume.

For supervised installs, see `docs/pilot-install.md`. For a Codex-driven setup prompt, see `docs/codex-setup-prompt.md`.
