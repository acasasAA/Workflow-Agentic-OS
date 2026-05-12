# Workflow OS — Global Agent Manual

You are running inside Workflow OS, a plugin-based agentic layer for Codex. This file is the entry point. It tells you where to find everything else.

## 1. Boot protocol

Codex's native AGENTS.md cascade loads this file first, then walks the project tree merging in any `AGENTS.md` / `AGENTS.override.md` files closer to cwd. The Workflow OS data layer adds these references:

1. This file (`~/.codex/AGENTS.md`).
2. `~/.codex/AGENTS.override.md` — safety rails (a copy of `<wos_data>/.agent/boundaries.md`). Always loaded last → always wins.
3. `<wos_data>/.agent/system.md` — core engine manual. Read on demand.
4. `<wos_data>/memory/users/<me>/preferences.md` — active user preferences.
5. Project marker (`WOS.md` in cwd) — project slug for resume.
6. `<wos_data>/memory/projects/<active_slug>/state.md`, if a project is active (loaded via memory-engine MCP, not directly).

`<wos_data>` is read from `~/.codex/workflow-os.json` → `data_root`. If that file is missing, Workflow OS is not installed — direct the user to run `bootstrap.ps1` and then `$welcome`.

## 2. Hard rails

These are summarized here for visibility; full text in `~/.codex/AGENTS.override.md`. The override file is authoritative.

- **Jira**: read+write allowed (writes require per-turn confirmation, mandatory emoji format); **delete blocked at MCP layer** (single exception: agent self-correction in same turn).
- **No silent destructive ops.** Confirm in chat before any deletion, force-push, schema drop, or mass write.
- **No auto-commits.** Code changes stage but don't commit unless the user says so.
- **No secrets in URLs, logs, or memory writes.** Strip credentials before persisting.
- **Memory writes go through MCP**, not direct file edits.
- **Sandbox mode does not bypass MCP `enabled_tools` allow-lists** — those are enforced at the MCP boundary in every mode, including `danger-full-access`.

## 3. Tool surface (paths)

Read concrete values from `<wos_data>/.agent/local.json`:

- `data_root` — Workflow OS data directory.
- `vault_path` — Obsidian vault root.
- `onedrive_backup` — backup folder under OneDrive.
- `jira_tenant` — Jira Cloud base URL.
- `github_desktop` — GitHub Desktop install path (may be null).
- `active_project` — slug of the currently active project, or null.

## 4. Plugin model (Codex-native)

Plugins follow Codex's contract: `.codex-plugin/plugin.json` manifest, `skills/<name>/SKILL.md` files invoked as `$<name>`, `hooks/hooks.json` for lifecycle handlers, `.mcp.json` for MCP servers. The framework is also a marketplace — `.agents/plugins/marketplace.json` lists all Workflow OS plugins.

Currently shipped: `onboarding`, `memory-engine`, `jira`, `project`, `task`.

Codex's `/plugins` UI is authoritative for which plugins are installed and enabled. Workflow OS does not maintain a parallel registry.

## 5. Identity

Active user is named in `<wos_data>/.agent/local.json` → `user`. Their preferences live at `<wos_data>/memory/users/<user>/preferences.md`. Read them before acting on the user's behalf.

## 6. When in doubt

- Memory question? Ask the `memory-engine` MCP, don't grep the vault.
- Jira question? Use the configured Atlassian Rovo MCP (the `jira` plugin owns the policy on top of it).
- Unsure which plugin owns a behavior? `codex /plugins` lists installed plugins.
- Nothing matches? Tell the user, don't improvise.
