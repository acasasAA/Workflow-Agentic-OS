---
name: documentation-publish
description: Publish or update Confluence documentation after selecting the required route, applying its assigned template and space, resolving page placement, and getting explicit confirmation.
---

# `$documentation-publish` - Publish To Confluence

Use when the user asks to create or update a Confluence documentation page.

## Required References

Load these before publishing:

- `${plugin_root}/../references/setup-gate.md`
- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`
- `${plugin_root}/../references/templates.md`

Apply `setup-gate.md` before any publish preflight or Confluence read/write. If persistent Documentation setup is not complete, run the per-document walkthrough for the current document before publishing.

## Preflight

Before any Confluence write:

1. Ask which route this is for unless already explicit: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
2. For Infrastructure or DEV/DBA, confirm whether this is a Runbook KB article or Business Process KB article.
3. For Infrastructure or DEV/DBA, confirm whether the page is internal or public-facing for Athens employees.
4. Identify the route-assigned Confluence space and template, or collect them through the per-document walkthrough. Infrastructure internal documentation uses `Internal Infrastructure KB` / `IIK`; DEV/DBA internal documentation is to be decided and must not default to `IIK`.
5. Identify whether the space is the route default or a one-request override.
6. Ask where the page should be placed: root of the space, route default parent, existing parent page/folder, or a new parent page.
7. Resolve and confirm the parent page when not publishing at the root.
8. Identify page title and whether this is a create or update.
9. Review the draft against the standard and selected route template.
10. Confirm the selected built-in template's section emojis are present and in order when a built-in template is used.
11. Show the proposed title, route, space, placement, and concise change summary.
12. Ask for explicit user confirmation to create or update Confluence.

Do not proceed on ambiguous approval. Draft approval is not publish approval.

## Tooling

- Use Atlassian Rovo first for Confluence write operations.
- If Rovo cannot perform the operation in the current session, stop at a final draft and explain what is missing.
- Do not delete, archive, move, restrict, or materially restructure Confluence pages through this skill.

## After Publishing

Return:

- Confluence page title.
- Documentation route.
- Space used.
- Placement used: root or parent page.
- Link to the page, if the tool provides one.
- Short summary of what was created or updated.
- Any follow-up review or ownership notes.

If a temporary space override was used, state that the saved default remains unchanged.
