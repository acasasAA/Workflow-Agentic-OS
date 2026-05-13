# Workflow OS — Safety Boundaries

These rules are non-negotiable. They apply regardless of plugin, project, user preference, or sandbox mode. Plugins MUST NOT register hooks that bypass them.

## 1. External services

### Jira (Atlassian Rovo app connector + Atlassian CLI)

- **Read**: always allowed through Atlassian Rovo or `acli` (`_search`, `_fetch`, `acli jira workitem view`, comment listing, transition lookup, etc.).
- **Write**: allowed *per-action* with explicit user confirmation in the current turn. Authorization does not carry across turns. The mandatory Workflow OS Jira-emoji format applies to all writes (see `plugins/jira/references/emoji-format.md`). Use Rovo first; use `acli` as the deterministic fallback/companion when Rovo is unavailable or lacks the needed operation.
- **Delete/archive**: **blocked for agents across all Jira tool paths**. Delete and archive operations (`delete_issue`, `delete_comment`, `delete_link`, `archive_issue`, `acli jira workitem delete`, `acli jira workitem archive`, comment deletes, etc.) cannot be called by any skill, hook, or subagent. Deletes stay with the user — they perform them manually in Jira.
- **Agent self-cleanup exception**: the agent may delete an artifact it itself created in error during the current turn (single bad comment, wrong subtask) with explicit user confirmation. No other auto-delete pathway exists.

### GitHub

- No pushes, no force operations, no PR merges without explicit per-action confirmation.

### OneDrive

- Writes only to the designated `onedrive_backup` folder. Never write outside it.

### Email / Slack / Teams

- No automated sends. Drafts only, surfaced to the user.

## 2. Filesystem

- No recursive deletes outside `<data_root>` and `<framework_root>` without confirmation.
- On Windows OneDrive paths, directory removal uses `cmd /c rd /s /q` via subprocess. Never `shutil.rmtree` directly.
- Never modify files in `vault/` directly. Use the `memory-engine` MCP.
- Never modify files in `vault/.obsidian/` programmatically. That's Obsidian's config.

## 3. Secrets

- Never persist credentials, tokens, or API keys to memory notes, logs, or commits.
- Never include secrets in URL parameters.
- If a secret appears in a tool output, redact it before any further processing.

## 4. Memory writes

- Writes go through `memory-engine` MCP. Plugins do not open vault files for write.
- Frontmatter is mandatory on every note. Missing frontmatter = MCP rejects the write.
- Session summaries record outcomes and decisions, not transcripts or chain-of-thought.

## 5. Codex hooks

- Hooks may not invoke destructive operations without user confirmation in the same turn.
- Hooks may not auto-commit, auto-push, or auto-send messages.
- A hook that fails must not block the session — it logs the failure and yields.

## 6. Sandbox modes do not bypass tool policy

- Tool allow-lists and Workflow OS safety boundaries (e.g. the Jira no-delete/no-archive rule above) apply in **every** sandbox mode, including `danger-full-access`.
- Sandbox mode governs filesystem and command execution. MCP tool access is enforced at the MCP boundary, and CLI usage remains governed by Workflow OS policy.
- Elevating sandbox does not unlock Jira deletes/archive, GitHub force-push, or any other policy-gated action. Those gates only move by deliberately editing the explicit policy — deliberate, auditable.
