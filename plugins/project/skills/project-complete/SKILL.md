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

Look up available transitions via `mcp__atlassian-rovo__list_transitions` for the project's Jira key. Show the user:

```
Available transitions for <jira_key>:
  1. <transition name 1>
  2. <transition name 2>
  ...

Transition to <Done|Closed|Resolved>? Or skip? (number / skip)
```

If the user picks a transition, draft a ✅ closeout comment per the Jira emoji format (`${plugin_root}/../jira/references/emoji-format.md` §4). Show the user, get explicit confirmation, then:

1. Call `mcp__atlassian-rovo__add_comment` to post the comment.
2. Call `mcp__atlassian-rovo__transition_issue` to perform the transition.

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
