# Workflow OS v2 — Draft

A plugin-based agentic layer for Codex. Five plugins: `onboarding`, `memory-engine`, `jira`, `project`, `task`. The repo IS the marketplace. For team installs, register it as a Git marketplace so `/plugins` can upgrade after changes are pushed.

The most broadly deployable module is `wos-jira`: a standalone Athens IT Jira standard for consistent setup, issue creation, updates, review, description maintenance, and closure comments. For general users, install `wos-jira` first and run `$jira-setup`. Project/task/memory/orchestration modules are optional for users who want deeper Workflow OS structure.

This is a clean-slate draft, staged for review before moving to the real `workflow-os` repo on the new machine.

## Layout

```
v2/
├── AGENTS.md                            global agent manual (→ ~/.codex/AGENTS.md)
├── bootstrap.ps1                        one-shot installer for new machines
├── scripts/install/                     preflight, prerequisite, and Codex setup helpers
├── templates/codex/                     deployable WOS Codex config template
├── docs/                                pilot install and Codex setup prompts
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
    ├── jira/                            standalone Athens IT Jira standard + Rovo/ACLI wrapper + emoji format
    │   └── .codex-plugin/, skills/, references/
    ├── project/                         project lifecycle + orchestration + selective import + auto-resume
        └── .codex-plugin/, skills/, hooks/, scripts/
    └── task/                            one-off ticket task lifecycle
        └── .codex-plugin/, skills/, scripts/
```

## Design summary

- **Codex-native.** Manifests at `.codex-plugin/plugin.json`. Skills with `$<name>` invocation. Hooks at `hooks/hooks.json` using Codex's event names (`SessionStart`, `Stop`, etc.). MCP via `.mcp.json`.
- **Two repos.** `workflow-os` (framework + plugins, shareable) and `workflow-os-data` (local user vault + index + prefs, private). OneDrive is an optional backup/export target, not the primary data root.
- **Memory.** Obsidian vault + SQLite FTS5, accessed only via `memory-engine` MCP. Auto-resume from `SessionStart` hook in the `project` plugin reads project state + last checkpoint + recent summaries on every new session.
- **Jira.** Uses the Atlassian Rovo Codex app connector first, with Atlassian CLI (`acli`) as a deterministic fallback/companion for gaps such as comments. The `jira` plugin is standalone and layers the Athens IT Jira standard, Workflow OS policy, and the mandatory emoji format on top of both tool paths; deletes/archive stay manual.
- **Runtimes.** Node for MCP servers, PowerShell for hooks and install scripts.
- **Onboarding.** `$welcome` is role-tailored for Athens IT users, validates foundation tools, defaults Jira to ASD/TPM, and records preferences.
- **Role-based tools.** Missing optional tools such as Azure DevOps/Azure Boards, AWS CLI/MCP, Microsoft Learn MCP/CLI, and Superpowers are not required on every machine. `$welcome` recommends them only when the selected teammate role or director focus needs them.
- **Platform discovery.** After minimum tools are satisfied, `$welcome` asks what other platforms the teammate uses, searches for matching CLIs and Codex MCP/app connectors, and records those as teammate-specific additions rather than global requirements.
- **Projects and tasks.** `$project-new` starts scoped project work, uploads the completed plan to Jira as phases, then `$project-orchestrate` can analyze Jira and propose dependency-aware execution before implementation. `$project-import` selectively imports one existing workspace folder and writes a `WOS.md` marker only there. `$task-new` handles one-off Jira tickets without creating a project, and `$task-orchestrate` offers lightweight orchestration only when a task has independent streams.
- **DR.** Live local data → manual/on-demand OneDrive backup/export → GitHub Desktop versioned snapshots → SQLite regenerable from vault.

## Upgrade flow

For maintainers:

1. Commit and push Workflow OS changes to `main`.
2. Team members open `/plugins` and use **Upgrade** on the Workflow OS marketplace.

For machines still registered to a local path, switch once:

```powershell
codex plugin marketplace remove workflow-os
codex plugin marketplace add https://github.com/acasasAA/Workflow-Agentic-OS.git --ref main
```

After that, `/plugins` can upgrade from Git whenever `main` changes.

## Moving to a new machine

See [TRANSFER.md](TRANSFER.md). Short version:
1. Push v2/ contents to a private GitHub repo as `workflow-os`.
2. On the new machine: run `scripts/install/preflight.ps1`, then `scripts/install/setup-codex.ps1`, then open Codex and run `$welcome`.
