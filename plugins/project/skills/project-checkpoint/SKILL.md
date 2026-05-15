---
name: project-checkpoint
description: Write a structured checkpoint for the currently active project. Use when the user wants a deliberate save point — captures phase, blockers, next actions, and a narrative. Complements the automatic session-summary writes from the Stop hook; this one is high-signal and user-curated.
---

# `$project-checkpoint` — Manual Project Checkpoint

You are writing a deliberate checkpoint for the active project.

## Step 1 — Confirm active project

Call `${plugin_root}/scripts/active-project.ps1` to resolve the active project slug. If `slug` is null, tell the user there's no active project (suggest `$project-new` or `$project-resume`) and exit.

## Step 2 — Read current state

Call the exposed memory-engine MCP `memory_search` tool when available:

```json
{ "type": "project-state", "project": "<slug>", "limit": 1 }
```

If the memory-engine MCP is installed but not exposed as a callable tool in the active conversation, use the supported local helper instead of inventing a local file fallback:

```powershell
$argsJson = '{"type":"project-state","project":"<slug>","limit":1}'
node "${memory_plugin_root}/scripts/memory-call.mjs" memory_search $argsJson
```

Resolve `memory_plugin_root` from the installed Workflow OS memory-engine plugin path when needed, usually under `~/.codex/plugins/cache/workflow-os/wos-memory-engine/<version>`.

If memory-engine is not installed or the helper fails, stop and report that project memory is unavailable. Do not write `docs/checkpoints`, repo checkpoint artifacts, markdown checkpoint files, or any other local substitute unless the user explicitly asks for a file export.

Show the user the current `phase`, `status`, and `next_milestone`. Confirm they're still accurate, or ask what's changed.

## Step 3 — Gather checkpoint content

Ask the user for these in order. Skip any they say is unchanged or N/A:

1. **Current phase** (e.g. "design", "implementation", "review"). Defaults to the previous checkpoint's phase if unchanged.
2. **Blockers** — bullet list. Empty if none.
3. **Next actions** — bullet list. What's the next concrete step.
4. **Narrative** — 3-5 sentences. The picture: what happened since the last checkpoint, what's the current state, what's the user's concern or focus.

## Step 4 — Write the checkpoint

Call the exposed memory-engine MCP `memory_write` tool when available:

```json
{
  "type": "checkpoint",
  "source": "wos-project",
  "project": "<slug>",
  "title": "<slug>-checkpoint-<short-date>",
  "body": "<the narrative + optional H2 sections for blockers and next actions>",
  "frontmatter_extras": {
    "phase": "<phase>",
    "blockers": ["..."],
    "next_actions": ["..."]
  }
}
```

If the memory-engine MCP is installed but not exposed as a callable tool in the active conversation, use the supported local helper:

```powershell
$argsJson = '<json arguments for memory_write>'
node "${memory_plugin_root}/scripts/memory-call.mjs" memory_write $argsJson
```

If the helper fails, stop and report the failure. Do not create a repo-local checkpoint file as a substitute.

## Step 5 — Optional Jira sync

Ask the user: "Post a 🟡 (or 🟢 / 🔴 based on blockers) comment to the project's Jira key summarizing this checkpoint?"

If yes, load `${plugin_root}/../jira/references/emoji-format.md` §1 and `${plugin_root}/../jira/references/jira-tooling.md`, draft the comment, and get confirmation. Then use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

## Step 6 — Update `project-state`

If `phase`, `status`, or `next_milestone` changed in Step 2, call the exposed `memory_write` tool or the same supported local helper again with `type: "project-state"` to update the canonical state note. (Same project, same slug — the new write replaces the old by virtue of identical type+project+slug semantics in the memory-engine upsert.)

## Hard rules

- **One checkpoint per `$project-checkpoint` invocation.** Don't batch.
- **No Jira write without explicit confirmation in Step 5.**
- **No local checkpoint substitutes.** Checkpoints are memory notes. Only create markdown files when the user explicitly requests a file export.
- **Blockers and next_actions must be concrete.** "Lots of stuff" is not a blocker; "Awaiting legal sign-off on data residency" is.
