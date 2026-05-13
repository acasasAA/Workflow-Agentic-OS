---
name: project-complete
description: Close out the currently active project. Writes a final decision and worklog, proposes a Jira transition (e.g. Done), produces a brief closeout summary, and clears active_project. Use when the work is genuinely finished — not for pausing or handing off (those don't need a dedicated skill).
---

# `$project-complete` — Close Out a Project

You are closing the currently active project.

## Step 1 — Confirm intent

Resolve the active project via `${plugin_root}/scripts/active-project.ps1`. Show the user:

```
About to complete: <slug> — <name>
Jira: <jira_key>
Phase: <current phase>

Are you sure? (yes/no)
```

If no, exit cleanly without changes.

## Step 2 — Final decision (optional)

Ask: "Any final decision worth recording? (e.g. why this approach won, what was deferred, what was learned)"

If yes, call `mcp__memory-engine__memory_write`:

```json
{
  "type": "decision",
  "source": "wos-project",
  "project": "<slug>",
  "title": "<slug>-final-decision",
  "body": "<rationale + alternatives considered + impact>",
  "frontmatter_extras": { "final": true }
}
```

## Step 3 — Final worklog

Ask: "Worklog summary for the project as a whole — what was delivered?"

Call `memory_write`:

```json
{
  "type": "worklog",
  "source": "wos-project",
  "project": "<slug>",
  "title": "<slug>-final-worklog",
  "body": "<delivered bullets + Jira refs + PR/commit links>",
  "frontmatter_extras": { "final": true }
}
```

## Step 4 — Update `project-state` to closed

Call `memory_write` with `type: "project-state"` again, updating `status` to `complete` and recording `completed_at`. (This replaces the active project-state note in-place via the upsert semantics.)

## Step 5 — Jira transition (proposed, not automatic)

Load `${plugin_root}/../jira/references/jira-tooling.md`. Look up the project's Jira key using the Jira tooling order: prefer `mcp__codex_apps__atlassian_rovo._search` and `mcp__codex_apps__atlassian_rovo._fetch`; if Rovo is unavailable, use `acli jira workitem view "<key>" --json`. If transition metadata is exposed, show the user:

```
Available transitions for <jira_key>:
  1. <transition name 1>
  2. <transition name 2>
  ...

Transition to <Done|Closed|Resolved>? Or skip? (number / skip)
```

If the user picks a transition, draft a ✅ closeout comment per the Jira emoji format (`${plugin_root}/../jira/references/emoji-format.md` §4). Show the user, get explicit confirmation, then:

1. Use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.
2. Prefer `mcp__codex_apps__atlassian_rovo._transitionjiraissue` to perform the transition. If Rovo is unavailable and the transition is still explicitly confirmed, use the matching `acli jira workitem transition` flow.

If the user says skip, leave Jira alone — they'll handle it manually.

## Step 6 — Clear `active_project`

Set `<data_root>/.agent/local.json` → `active_project = null`.

## Step 7 — Closeout summary

Print to the user, in 5 bullets max:

- **Project**: name + slug + Jira key.
- **Duration**: created_at → completed_at.
- **Final phase reached**.
- **Memory artifacts**: counts of checkpoints, decisions, worklogs.
- **Jira state**: transitioned to <X> / left as <Y> for manual close.

Suggest: "If you want to revisit this project later, its memory is preserved. `$project-resume` and pick `<slug>` will bring it back as the active project."

## Hard rules

- **One project closed per invocation.** Don't batch.
- **No deletes** of memory notes or Jira items. Closing means transitioning + marking, never removing.
- **Jira transition requires explicit user confirmation** in Step 5 — never automatic.
- **The `WOS.md` marker in cwd is left in place.** It documents that this directory was once a Workflow OS project; removing it is the user's call.
