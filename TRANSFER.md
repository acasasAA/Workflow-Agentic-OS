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

The bootstrap will refuse to run without these:

- **Codex CLI** — `npm install -g @openai/codex` (or however you install it).
- **Node.js LTS** — current LTS, on PATH.
- **git** — for cloning the framework and the data repo's snapshots.
- **GitHub Desktop** — for managing the data repo.
- **Obsidian** — install, but don't open the vault yet. Onboarding scaffolds it first.

### Steps

```powershell
# 1. Clone the framework
cd $env:USERPROFILE
git clone https://github.com/acasasAA/Workflow-Agentic-OS.git workflow-os
cd workflow-os

# 2. Run bootstrap
.\bootstrap.ps1
```

The bootstrap will, in order:
1. Validate Codex CLI, Node, git on PATH.
2. Write `~/.codex/workflow-os.json` (sentinel pointing at the framework path).
3. Install `~/.codex/AGENTS.md` (global agent manual) and `~/.codex/AGENTS.override.md` (safety rails — always wins cascades).
4. Patch `~/.codex/config.toml` with a managed block enabling hooks and registering `WOS.md` as a project-doc fallback filename.
5. Run `codex plugin marketplace add <framework_root>`.

```powershell
# 3. Start Codex and install plugins
codex
```

Inside Codex:
```
/plugins
```
Install at minimum `wos-onboarding` from the `workflow-os` marketplace. The onboarding skill will guide installation of the other three (`wos-memory-engine`, `wos-jira`, `wos-project`) as part of its flow.

```
$welcome
```

Walk through the onboarding questions. When it finishes, you'll have a working Workflow OS install pointing at `<data_root>/workflow-os-data/`.

### What `$welcome` does

The onboarding skill (the only thing in `wos-onboarding`) asks for:
- Identity and polished role profile (Help Desk, IT Operations, System Administration, Project Management, Development / DBA, or IT Leadership with subrole).
- Role-tailoring answers that shape defaults and preferences.
- Foundation tool validation (Codex CLI, Git, Node.js required; GitHub Desktop, Obsidian, Atlassian Rovo MCP, Outlook Email/Calendar recommended; other tools optional by role).
- Paths (framework engine path, local data root, optional OneDrive backup/export folder, GitHub Desktop install).
- Jira tenant URL and primary project keys, defaulting Athens users to ASD and TPM only.

Then it:
- Creates local `<data_root>/` with `vault/`, `memory/`, `.index/`, `.logs/`, `.agent/`.
- Writes `<data_root>/.agent/local.json` with all answers.
- Writes `<data_root>/memory/users/<username>/preferences.md`.
- Installs the remaining three plugins via the marketplace.
- Marks itself complete (`plugin_state.wos-onboarding.disabled = true`).

After onboarding:
- Open Obsidian on `<data_root>/vault/` — the empty vault.
- Start your first project with `$project-new`.
- Import an existing workspace with `$project-import`; it imports one selected folder only and writes `WOS.md` only there.

### Recovery on a future clean machine

Same steps. Plus, before `$welcome`, restore the data repo:
```powershell
git clone https://github.com/<you>/workflow-os-data.git
```
Point `WOS_DATA_ROOT` at the cloned path before running bootstrap, or accept the default location and let onboarding detect the existing install.

After data is restored, regenerate the SQLite index from the vault:
```powershell
pwsh -File "<framework_root>/plugins/memory-engine/scripts/reindex.ps1" -Force
```

## What NOT to copy

- `workflow-os-data/.index/` — regenerable from the vault; don't transfer.
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

If marketplace lists `workflow-os` and `/plugins` shows the four `wos-*` plugins enabled, the install is correct. The first Codex session in a directory with a `WOS.md` marker will demonstrate auto-resume.
