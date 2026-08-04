---
name: jira-update
description: Append a comment to a Jira work item using the Workflow OS emoji-formatted comment structure. Use when the user wants to log progress, surface a blocker, or note completion on a specific Jira key outside of a project flow. Requires explicit confirmation before posting.
---

# `$jira-update` — Manual Jira Comment

You are posting a comment to a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/setup-gate.md` first. If Jira setup is not complete, stop and send the user to `$jira-setup` before doing anything else.
Load `${plugin_root}/../references/jira-standard.md` before drafting. Use it to choose the right update type and avoid vague comments.
Load `${plugin_root}/../references/emoji-format.md` before drafting. The comment **must** follow §1 (Comment structure) including the status marker.
Load `${plugin_root}/../references/jira-tooling.md` before choosing Jira tooling.

## Steps

1. **Ask the user for:**
   - **Jira key** (e.g. `ASD-42`). Verify exact keys using the Jira tooling order from `jira-tooling.md`; prefer Rovo JQL `key = <KEY>` when exposed, then `acli` fallback if needed.
   - **Status marker**: 🟢 / 🟡 / 🔴 / 🔵 / ✅ / 🛠️ (per §1 table).
   - **Summary line** (one sentence).
   - **What's done**, **In progress**, **Blockers**, **Next**, **Refs** — only the sections that have content.

2. **Check usefulness** against `jira-standard.md`. If the update would be vague, ask for enough detail to make the next action, blocker, or outcome clear.

3. **Draft the comment** using §1's template. Show the user the draft.

4. **Confirm before posting:**
   ```
   Posting to <key>:
   ──────────────────
   <full comment>
   ──────────────────
   Post? (yes/no)
   ```

5. **On yes**: use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback from `${plugin_root}/../references/jira-tooling.md`: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

6. **On success**, tell the user the comment ID or success result returned. If Workflow OS memory-engine is available and the user indicates time spent, optionally write a `worklog` memory note; if memory is unavailable, do not fail the Jira workflow.

7. **On no**, ask what to change. Loop on step 3.

## Hard rules

- **One status marker per comment.** Pick the most accurate one.
- **No edits to other people's comments** — `$jira-update` only adds new ones. To edit our own latest, use `$jira-mod`.
- **No secrets.**
- **Per-action confirmation** — don't reuse authorization across keys.
- **Standalone behavior**: this skill must work with only `wos-jira` installed. Do not require memory-engine, project, or task plugins.
