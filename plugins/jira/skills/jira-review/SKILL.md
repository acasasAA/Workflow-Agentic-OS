---
name: jira-review
description: Review an existing Jira work item against the Workflow OS Jira team standard. Use when a user wants to check ticket quality, identify missing context, choose the right issue type, or prepare safe cleanup before any Jira write.
---

# `$jira-review` — Jira Quality Review

You are reviewing one existing Jira work item against the Workflow OS Jira team standard. This skill is read-first and write-optional.

## Required References

Load these before reviewing:

- `${plugin_root}/../references/jira-standard.md`
- `${plugin_root}/../references/emoji-format.md`
- `${plugin_root}/../references/jira-tooling.md`

## Step 1 — Identify The Jira Item

Ask for exactly one Jira key if the user has not provided it.

Use the Jira tooling order from `jira-tooling.md`:

1. Prefer Rovo JQL for exact keys when exposed: `key = <KEY>`.
2. Use Rovo Search + Fetch for semantic lookup when the user gives a phrase instead of a key.
3. Use `acli jira workitem view "<KEY>" --json` when Rovo is unavailable or lacks the needed read.

Jira reads are allowed. Do not write during this step.

## Step 2 — Review Against The Standard

Evaluate the item against `jira-standard.md` and `emoji-format.md`.

Check:

- Project key and likely project fit.
- Issue type fit: Epic / Task / Subtask / helpdesk ticket.
- Title format: exactly one lead emoji and clear action/symptom wording.
- Description structure: Objective, Scope, Acceptance criteria, Links, Notes.
- Whether the next action is clear.
- Whether blockers, owner/assignee, parent, related work, or references are missing.
- Whether the item appears stale, underspecified, duplicated, or in the wrong shape.
- Whether any text may contain secrets or sensitive values.

Classify the item as one of:

- `Pass`
- `Needs cleanup`
- `Needs clarification`
- `Wrong shape`

## Step 3 — Report Findings

Give a concise review:

```text
Jira Review: <KEY>
Verdict: <Pass | Needs cleanup | Needs clarification | Wrong shape>

What looks good
- <bullet>

Issues found
- <bullet>

Recommended cleanup
- <bullet>

Suggested next action
- <one clear next step>
```

If the item passes, say so clearly and do not invent unnecessary cleanup.

## Step 4 — Optional Drafts

If cleanup is useful, offer only the smallest safe next write:

- `$jira-mod` style description cleanup
- `$jira-update` style comment
- title recommendation for the user to approve
- issue-type/project/parent recommendation for manual or approved follow-up

Draft the proposed Jira text using `emoji-format.md`.

## Step 5 — Confirmation Before Writes

If the user wants a write, show the exact payload and ask for explicit confirmation in the current turn.

Allowed writes after confirmation:

- Add a comment.
- Update the description.
- Update supported metadata only if the Jira tooling exposes it and the user explicitly approves.

Use Rovo first. Use `acli` fallback only when appropriate under `jira-tooling.md`.

## Hard Rules

- Review only one Jira item at a time.
- No deletes or archives.
- Do not edit comments.
- Do not write without explicit confirmation.
- Do not include secrets in findings or drafts.
- If the fix requires deletion, tell the user to do it manually in Jira.
- If the issue belongs in a different project or issue type and the tooling cannot safely move it, recommend the change; do not improvise.
