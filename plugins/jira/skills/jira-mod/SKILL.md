---
name: jira-mod
description: Modify the description of an existing Jira work item to bring it into the Workflow OS emoji-format structure, or to update its content. Use when the user wants to edit a Jira description (not add a comment). Requires explicit confirmation; shows a diff before writing.
---

# `$jira-mod` — Manual Jira Description Edit

You are modifying the **description** field of an existing Jira work item on the user's explicit request. Comments use `$jira-update`; this skill is for descriptions only.

## Required reference

Load `${plugin_root}/../references/emoji-format.md` before drafting. The new description **must** follow §2 (Description structure).
Load `${plugin_root}/../references/jira-tooling.md` before choosing Jira tooling.

## Steps

1. **Ask the user for the Jira key.** Use the Jira tooling order from `jira-tooling.md`. Prefer `mcp__codex_apps__atlassian_rovo._search` and `mcp__codex_apps__atlassian_rovo._fetch`; if Rovo is unavailable, use `acli jira workitem view "<key>" --json` to fetch current state including the existing description.

2. **Show the user the current description.** Ask what they want changed:
   - Reformat to Workflow OS structure (preserving content)?
   - Update specific sections (Objective / Scope / Acceptance / Links / Notes)?
   - Add a section that's missing?

3. **Draft the new description** using the §2 skeleton. Preserve any content the user wants kept.

4. **Show a side-by-side or before/after diff:**
   ```
   BEFORE:
   <current>
   ──────────────────
   AFTER:
   <proposed>
   ──────────────────
   Apply? (yes/no)
   ```

5. **On yes**: prefer `mcp__codex_apps__atlassian_rovo._editjiraissue`; if Rovo is unavailable, use the matching `acli jira workitem edit` flow after confirmation.

6. **On success**, tell the user the work item is updated. Offer to also post a 🔵 informational comment via `$jira-update` noting the description change (only if substantive).

7. **On no**, ask what to change. Loop on step 3.

## Hard rules

- **Never blank-out the description** without explicit confirmation that the user wants it empty.
- **Preserve external links and attachment references** unless the user says to drop them.
- **No secrets.**
- **No bulk edits across multiple issues.** This skill edits one key at a time.
- **No deletes** — even of sections within a description, ask before removing substantial content.
