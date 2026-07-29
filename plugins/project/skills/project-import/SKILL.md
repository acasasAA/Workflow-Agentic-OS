---
name: project-import
description: Import one existing workspace folder into Workflow OS. Use when the user already has a project folder and wants Workflow OS memory, WOS.md auto-resume, optional Jira linkage, and optional active_project selection without bulk-importing sibling folders.
---

# `$project-import` — Import Existing Workspace

You are importing exactly one existing workspace into Workflow OS. This skill is intentionally selective: never scan or bulk-import all folders under a parent such as `MS DEV`, and never write markers to sibling folders.

## Step 1 — Choose one workspace folder

Ask for the absolute path to the existing project/workspace folder.

Rules:

- The path must exist and must be a directory.
- Import only that exact folder.
- Do not import children or sibling folders unless the user invokes this skill again for another folder.
- If `WOS.md` already exists in the selected folder, read it and ask whether the user wants to reuse that project slug or stop. Do not overwrite without confirmation.

## Step 2 — Project identity

Ask:

1. **Project name**. Default from the folder name.
2. **Description**. One to three sentences explaining what the workspace is and why it matters.

Derive a permanent slug from the name:

- lowercase
- hyphenated
- letters/numbers/hyphens only
- <= 30 characters where practical

Show the slug and ask for confirmation before writing anything. If project-state receipts already exist for that slug, ask the user to choose a different slug or confirm they are linking this folder to that existing project.

## Step 3 — Optional Jira linkage

Load `${plugin_root}/../jira/references/jira-tooling.md` before choosing Jira tooling.

Ask whether the workspace has an existing Jira epic or ticket.

- If yes, ask for the key. For exact key verification, prefer `mcp__codex_apps__atlassian_rovo._searchjiraissuesusingjql` with `jql: "key = <KEY>"` and `cloudId` set to the Jira site URL. If that tool is not exposed, use `mcp__codex_apps__atlassian_rovo._search` plus `_fetch` with the returned ARI. If Rovo is unavailable or the Rovo call fails, use `acli jira workitem view "<key>" --json` to verify title/type.
- If Jira is unavailable, record the key as user-provided and mark it unverified.
- If no, proceed with `jira_key = null`.

Do not create Jira issues from this skill. `$project-import` is for linking existing workspaces; new Jira creation belongs in `$project-new` and still requires explicit confirmation.

## Step 4 — Append project-state receipt

Call the exposed memory-engine MCP `memory_write` tool when available:

```json
{
  "type": "project-state",
  "source": "wos-project",
  "project": "<slug>",
  "title": "<slug>-state",
  "body": "<markdown body with description, workspace path, Jira link if any, and import note>",
  "frontmatter_extras": {
    "name": "<name>",
    "jira_key": "<key-or-null>",
    "jira_type": "<epic|ticket|unknown|null>",
    "workspace_path": "<absolute folder path>",
    "phase": null,
    "status": "active",
    "next_milestone": null,
    "imported": true
  }
}
```

If the memory-engine MCP is installed but not exposed as a callable tool in the active conversation, use the supported local helper instead of hand-rolling stdio:

```powershell
$argsJson = '<json arguments for memory_write>'
node "${memory_plugin_root}/scripts/memory-call.mjs" memory_write $argsJson
```

Resolve `memory_plugin_root` from the installed Workflow OS memory-engine plugin path when needed, usually under `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`.

If memory-engine is not installed or the helper fails, stop and report that the project cannot be imported yet. Do not create `WOS.md` without a project-state receipt unless the user explicitly asks for a marker-only recovery.

## Step 5 — Write WOS.md marker

Write `WOS.md` only in the selected workspace folder:

```markdown
---
project_slug: <slug>
jira_key: <key-or-null>
workspace_path: <absolute folder path>
imported: true
created: <ISO timestamp>
---

# <Name>

<Description>

This file marks this folder as the Workflow OS workspace for `<slug>`.
```

Hard rule: do not write `WOS.md` to the parent folder or any sibling folder.

## Step 6 — Optional active project

Ask:

> Make `<slug>` the active Workflow OS project now?

If yes, set `<data_root>/.agent/local.json` → `active_project = "<slug>"` using `${plugin_root}/scripts/active-project.ps1 -Set <slug>`.

If no, leave `active_project` unchanged. Auto-resume will still work whenever Codex opens inside the selected workspace because `WOS.md` is present.

## Step 7 — Finish

Summarize:

- imported project name and slug
- selected workspace folder
- Jira key or "none"
- marker path
- active_project changed or unchanged

Tell the user to open a fresh Codex session in that workspace to verify auto-resume.

## Hard rules

- One workspace per invocation.
- No bulk import.
- No sibling folder writes.
- No Jira writes.
- No deletes.
- No secrets in `WOS.md` or memory receipts.
