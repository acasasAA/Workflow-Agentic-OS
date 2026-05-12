# Workflow OS v2 — Draft

A plugin-based agentic layer for Codex. Five plugins: `onboarding`, `memory-engine`, `jira`, `project`, `task`. The repo IS the marketplace — Codex installs plugins from this directory via `codex plugin marketplace add`.

This is a clean-slate draft, staged for review before moving to the real `workflow-os` repo on the new machine.

## Layout

```
v2/
├── AGENTS.md                            global agent manual (→ ~/.codex/AGENTS.md)
├── bootstrap.ps1                        one-shot installer for new machines
├── TRANSFER.md                          new-machine setup checklist
├── .agents/plugins/marketplace.json     lists the Workflow OS plugins for Codex's marketplace
├── .agent/
│   ├── system.md                        core engine manual
│   └── boundaries.md                    safety rails (→ ~/.codex/AGENTS.override.md)
└── plugins/
    ├── onboarding/                      first-run setup
    │   └── .codex-plugin/, skills/, hooks/, scripts/
    ├── memory-engine/                   SQLite FTS5 + Node MCP server
    │   └── .codex-plugin/, mcp/, .mcp.json, hooks/, scripts/
    ├── jira/                            Atlassian Rovo MCP wrapper + emoji format
    │   └── .codex-plugin/, skills/, .mcp.json, references/
    └── project/                         project lifecycle + selective import + auto-resume
        └── .codex-plugin/, skills/, hooks/, scripts/
    └── task/                            one-off ticket task lifecycle
        └── .codex-plugin/, skills/, scripts/
```

## Design summary

- **Codex-native.** Manifests at `.codex-plugin/plugin.json`. Skills with `$<name>` invocation. Hooks at `hooks/hooks.json` using Codex's event names (`SessionStart`, `Stop`, etc.). MCP via `.mcp.json`.
- **Two repos.** `workflow-os` (framework + plugins, shareable) and `workflow-os-data` (local user vault + index + prefs, private). OneDrive is an optional backup/export target, not the primary data root.
- **Memory.** Obsidian vault + SQLite FTS5, accessed only via `memory-engine` MCP. Auto-resume from `SessionStart` hook in the `project` plugin reads project state + last checkpoint + recent summaries on every new session.
- **Jira.** Uses Atlassian Rovo MCP from the marketplace. The `jira` plugin layers policy (no-delete `enabled_tools` allow-list) and the mandatory Workflow OS emoji format.
- **Runtimes.** Node for MCP servers, PowerShell for hooks and install scripts.
- **Onboarding.** `$welcome` is role-tailored for Athens IT users, validates foundation tools, defaults Jira to ASD/TPM, and records preferences.
- **Projects and tasks.** `$project-new` starts scoped project work. `$project-import` selectively imports one existing workspace folder and writes a `WOS.md` marker only there. `$task-new` handles one-off Jira tickets without creating a project.
- **DR.** Live local data → manual/on-demand OneDrive backup/export → GitHub Desktop versioned snapshots → SQLite regenerable from vault.

## Moving to a new machine

See [TRANSFER.md](TRANSFER.md). Short version:
1. Push v2/ contents to a private GitHub repo as `workflow-os`.
2. On the new machine: clone, `.\bootstrap.ps1`, then open Codex and run `$welcome`.
