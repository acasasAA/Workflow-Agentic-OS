---
name: welcome
description: Run the Workflow OS first-time setup. Use this when the user has just installed Workflow OS and needs to scaffold their workflow-os-data directory, set identity and role, configure Jira and OneDrive paths, and install the rest of the plugin set. Should only run once per machine; subsequent invocations should detect existing install and offer repair or exit.
---

# Workflow OS — First-Run Setup

You are running the `welcome` skill from the `wos-onboarding` plugin. Your job in this turn is to set the user up from scratch. Do not skip steps. Do not assume answers. If a question's answer is unclear, ask once; if still unclear, write a TODO note in the file and continue.

## Preconditions

1. Run `${plugin_root}/scripts/detect-state.ps1`. Parse the JSON output.
2. If `state == "installed"`, stop and tell the user Workflow OS is already installed. Suggest they invoke `$project-resume` to switch projects or just start using Codex normally. Exit.
3. If `state == "partial"`, list the files present vs missing. Ask whether to **repair** (complete the missing parts) or **wipe-and-restart**. Wipe requires explicit user confirmation. Default to repair.
4. Otherwise (`state == "missing"`), proceed with fresh install.

## Step 1 — Identity & role

Ask the user, one at a time, brief answers only:

1. **Username** (used for `memory/users/<username>/`). Suggest the OS username (`$env:USERNAME`) as default.
2. **Display name** — how they want to be addressed.
3. **Role** — pick one or write-in: `engineer`, `pm`, `analyst`, `support`, `ops`, `other:<text>`.
4. **Work style** — two sentences max. Examples: "direct, bulleted answers, no filler" or "explain reasoning when changing established patterns."

## Step 2 — Paths

Ask, with sensible Windows defaults:

1. **Framework path** — where the `workflow-os` repo lives. Default: read from `~/.codex/workflow-os.json` → `framework_root` (set by `bootstrap.ps1`).
2. **Data path** — where `workflow-os-data` will live. Default: `C:\Users\<user>\workflow-os-data`.
3. **OneDrive backup folder** — absolute path. Default: `C:\Users\<user>\OneDrive\workflow-os-backup`. Create if it doesn't exist (confirm before creating).
4. **GitHub Desktop install path** — auto-detect via `(Get-Command github -ErrorAction SilentlyContinue).Source` or check `$env:LOCALAPPDATA\GitHubDesktop\`. Null if not found.

## Step 3 — Jira (Atlassian Rovo)

1. **Jira tenant URL** (e.g. `https://athens.atlassian.net`).
2. **Primary project key(s)** the user works in day-to-day (comma-separated, optional).
3. Tell the user: writes are allowed per-action with their confirmation; **deletes are blocked at the MCP layer** and stay manual. They can override the allow-list later by editing `~/.codex/config.toml` if they need delete operations (rare).

## Step 4 — Install remaining plugins

The four-plugin set: `wos-onboarding` (this one — already installed), `wos-memory-engine`, `wos-jira`, `wos-project`.

Install via Codex's plugin mechanism. Try in order:
- If headless install is available (`codex plugin install <marketplace>/<name>`), use it for the remaining three.
- Otherwise, instruct the user: "Type `/plugins` in Codex, then install: `wos-memory-engine`, `wos-jira`, `wos-project`. Press Enter here when done."

## Step 5 — Write data files

Use the `memory-engine` MCP if it's installed and reachable. Otherwise, fall back to direct file writes (documented exception during onboarding only; all subsequent writes go through MCP).

Write:

1. **`<data_path>/.agent/local.json`** — populated with Steps 1–3 answers + the installed plugin set:

   ```json
   {
     "version": "0.1.0",
     "user": "<username>",
     "display_name": "<display name>",
     "role": "<role>",
     "data_root": "<data_path>",
     "framework_root": "<framework_path>",
     "vault_path": "<data_path>/vault",
     "onedrive_backup": "<onedrive_path>",
     "jira_tenant": "<url>",
     "github_desktop": "<path-or-null>",
     "active_project": null,
     "installed_plugins": ["wos-onboarding", "wos-memory-engine", "wos-jira", "wos-project"],
     "plugin_state": {
       "wos-onboarding": { "disabled": true, "completed_at": "<ISO timestamp>" }
     }
   }
   ```

2. **`<data_path>/memory/users/<username>/preferences.md`** — note with frontmatter `type: preference`. Body: display name, role, work style, communication preferences.

3. **`<data_path>/vault/.obsidian/`** — leave empty; Obsidian initializes on first open.

4. **Empty directories**: `<data_path>/memory/projects/`, `<data_path>/memory/daily/`, `<data_path>/.index/`, `<data_path>/.logs/`.

5. **Update `~/.codex/workflow-os.json`**: set `data_root` and `installed: true`.

## Step 6 — Mark complete

1. Confirm `plugin_state.wos-onboarding.disabled = true` in `local.json`.
2. Summarize what was created in 5 bullets max.
3. Tell the user what to do next:
   - Open Obsidian on the new vault: `<data_path>/vault/`.
   - Start their first project with `$project-new`.

## Failure modes

- **Unwritable path**: stop and report. Do not partially write.
- **User aborts mid-flow**: write `plugin_state.wos-onboarding = { "disabled": false, "partial": true, "completed_steps": [...] }` so the next run can resume.
- **Memory-engine unreachable during Step 5**: fall back to direct file writes for onboarding only. Log a warning.
- **Never write credentials.** If a Jira URL contains a token (e.g. `?token=...`), strip it and ask the user to re-enter clean.
