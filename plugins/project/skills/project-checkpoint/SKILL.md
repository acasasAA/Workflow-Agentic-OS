---
name: project-checkpoint
description: Write a structured checkpoint for the currently active project. Use when the user wants a deliberate save point — captures phase, blockers, next actions, and a narrative. Complements the automatic session-summary writes from the Stop hook; this one is high-signal and user-curated.
---

# `$project-checkpoint` — Manual Project Checkpoint

You are writing a deliberate checkpoint for the active project.

## Step 1 — Confirm active project

Call `${plugin_root}/../scripts/active-project.ps1` to resolve the active project slug. If `slug` is null, tell the user there's no active project (suggest `$project-new` or `$project-resume`) and exit.

## Step 2 — Read current state

Call `mcp__memory-engine__memory_search`:

```json
{ "type": "project-state", "project": "<slug>", "limit": 1 }
```

Show the user the current `phase`, `status`, and `next_milestone`. Confirm they're still accurate, or ask what's changed.

## Step 3 — Gather checkpoint content

Ask the user for these in order. Skip any they say is unchanged or N/A:

1. **Current phase** (e.g. "design", "implementation", "review"). Defaults to the previous checkpoint's phase if unchanged.
2. **Blockers** — bullet list. Empty if none.
3. **Next actions** — bullet list. What's the next concrete step.
4. **Narrative** — 3-5 sentences. The picture: what happened since the last checkpoint, what's the current state, what's the user's concern or focus.

## Step 4 — Write the checkpoint

Call `mcp__memory-engine__memory_write`:

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

## Step 5 — Optional Jira sync

Ask the user: "Post a 🟡 (or 🟢 / 🔴 based on blockers) comment to the project's Jira key summarizing this checkpoint?"

If yes, load `${plugin_root}/../../jira/references/emoji-format.md` §1, draft the comment, get confirmation, then call `mcp__atlassian-rovo__add_comment`.

## Step 6 — Update `project-state`

If `phase`, `status`, or `next_milestone` changed in Step 2, call `memory_write` again with `type: "project-state"` to update the canonical state note. (Same project, same slug — the new write replaces the old by virtue of identical type+project+slug semantics in the memory-engine upsert.)

## Hard rules

- **One checkpoint per `$project-checkpoint` invocation.** Don't batch.
- **No Jira write without explicit confirmation in Step 5.**
- **Blockers and next_actions must be concrete.** "Lots of stuff" is not a blocker; "Awaiting legal sign-off on data residency" is.
