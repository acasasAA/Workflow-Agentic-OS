---
name: documentation-draft
description: "Draft documentation after selecting the required WOS documentation route: Help Desk, Infrastructure, DEV/DBA team, or public-facing for Athens employees."
---

# `$documentation-draft` - Draft Documentation

Use when the user asks to create, rewrite, or structure documentation before publishing.

## Required References

Load these before drafting:

- `${plugin_root}/../references/setup-gate.md`
- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`
- `${plugin_root}/../references/templates.md`

Apply `setup-gate.md` before drafting. If persistent Documentation setup is not complete, run the per-document walkthrough for the current document.

## Required Route Question

Any time the user documents something they ran, ask which route this is for unless the route is already explicit in the request:

- Help Desk.
- Infrastructure.
- DEV/DBA team.
- Public-facing for Athens employees.

The selected route determines the default Confluence space and template. If the route has no configured template, offer a built-in template choice from `templates.md`.

For Help Desk, offer:

1. `ahi_how_to` - primary choice for how-to documentation.
2. `ahi_troubleshooting` - internal agent troubleshooting guide.

For Public-facing for Athens employees, use `ahi_how_to`.

## Inputs To Determine

Determine from the request or ask only when necessary:

- Route: `help_desk`, `infrastructure`, `dev_dba`, or `public_athens`.
- Audience: `public-facing` for `public_athens`; otherwise `internal`.
- Topic and goal.
- Target Confluence space: route-assigned space unless the user gives a temporary override.
- Template source: route-assigned Confluence template, supplied Confluence URL, `ahi_how_to`, or `ahi_troubleshooting`.
- Intended placement, if the user already knows it: root, route default parent, existing parent page, or new parent page.
- Source material: pasted notes, files, Jira tickets, Confluence pages, or user explanation.
- Whether the user wants a draft only or wants to publish after review.

## Drafting Rules

- Use the configured route template or supplied Confluence template first when available.
- Use `ahi_how_to` for public-facing how-tos and Help Desk how-to documentation.
- Use `ahi_troubleshooting` for internal agent troubleshooting guides.
- Infrastructure and DEV/DBA may share `ahi_how_to` when documenting repeatable procedures.
- Keep public-facing docs simple, concise, and action-oriented.
- Keep internal docs practical and complete, but usually one page.
- Split into three to five pages only when separate reader workflows justify it.
- Include validation or expected result.
- Include support path or ownership.
- Link to sources rather than copying long source content.
- Do not include secrets or sensitive values.

## Output

Return a Confluence-ready draft in Markdown or Atlassian-document-friendly structure.

Include a short preface with:

- Audience.
- Route.
- Target space.
- Template used, if any.
- Intended placement, if known.
- Any source gaps or assumptions.

Do not publish unless the user explicitly asks and confirms the Confluence write in the current turn.
