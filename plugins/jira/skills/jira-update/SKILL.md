---
name: jira-update
description: Append a comment to a Jira work item using the Workflow OS emoji-formatted comment structure. Use when the user wants to log progress, surface a blocker, or note completion on a specific Jira key outside of a project flow. Requires explicit confirmation before posting.
---

# `$jira-update` — Manual Jira Comment

You are posting a comment to a Jira work item on the user's explicit request.

## Required reference

Load `${plugin_root}/../references/emoji-format.md` before drafting. The comment **must** follow §1 (Comment structure) including the status marker.
Load `${plugin_root}/../references/jira-tooling.md` before choosing Jira tooling.

## Steps

1. **Ask the user for:**
   - **Jira key** (e.g. `PHX-42`). Verify with `mcp__codex_apps__atlassian_rovo._search` or `mcp__codex_apps__atlassian_rovo._fetch` to confirm it exists.
   - **Status marker**: 🟢 / 🟡 / 🔴 / 🔵 / ✅ / 🛠️ (per §1 table).
   - **Summary line** (one sentence).
   - **What's done**, **In progress**, **Blockers**, **Next**, **Refs** — only the sections that have content.

2. **Draft the comment** using §1's template. Show the user the draft.

3. **Confirm before posting:**
   ```
   Posting to <key>:
   ──────────────────
   <full comment>
   ──────────────────
   Post? (yes/no)
   ```

4. **On yes**: use the Atlassian Rovo Codex app connector's Jira comment tool if exposed in the current session. If no comment tool is exposed, use the `acli` fallback from `${plugin_root}/../references/jira-tooling.md`: write the approved comment to a temp file, run `acli jira workitem comment create --key "<key>" --body-file "<tempfile>"`, then remove the temp file.

5. **On success**, optionally write a `worklog` memory note if the user indicates they spent time on this. Tell the user the comment ID returned.

6. **On no**, ask what to change. Loop on step 2.

## Hard rules

- **One status marker per comment.** Pick the most accurate one.
- **No edits to other people's comments** — `$jira-update` only adds new ones. To edit our own latest, use `$jira-mod`.
- **No secrets.**
- **Per-action confirmation** — don't reuse authorization across keys.
