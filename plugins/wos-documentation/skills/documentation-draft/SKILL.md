---
name: documentation-draft
description: "Draft documentation after selecting the required WOS documentation route: Help Desk, Infrastructure, DEV/DBA team, or public-facing for Athens employees."
---

# `$documentation-draft` - Draft Documentation

Use when the user asks to create, rewrite, or structure documentation before publishing. If the user asks to refresh an existing KB article into the approved standard, use `$kb-refresh`; KB Refresh is the named feature for existing KB cleanup and restructuring.

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

For Infrastructure and DEV/DBA, offer:

1. Runbook KB article - use `infra_dev_break_fix_runbook` for break/fix or technical operations.
2. Business Process KB article - use `infra_dev_standard` for repeatable workflows, handoffs, approvals, and team procedures.

If the user is unsure, explain the difference plainly:

- A Runbook KB article is for fixing or operating something technical: symptoms, commands, validation, rollback, or expected system state.
- A Business Process KB article is for explaining how a repeatable business or team workflow should happen from start to finish.

After the KB article type is clear for Infrastructure or DEV/DBA, ask whether it is internal or public-facing for Athens employees.

## Inputs To Determine

Determine from the request or ask only when necessary:

- Route: `help_desk`, `infrastructure`, `dev_dba`, or `public_athens`.
- KB article type for Infrastructure or DEV/DBA: Runbook KB article or Business Process KB article.
- Audience: `public-facing` for `public_athens`; for Infrastructure or DEV/DBA, ask whether the specific page is internal or public-facing for Athens employees.
- Topic and goal.
- Target Confluence space: route-assigned space unless the user gives a temporary override. Infrastructure internal documentation uses `Internal Infrastructure KB` / `IIK`; DEV/DBA internal documentation is to be decided and requires a space selection before publishing; public-facing Infrastructure or DEV/DBA documentation uses the configured public-facing route space.
- Template source: route-assigned Confluence template, supplied Confluence URL, `ahi_how_to`, `ahi_troubleshooting`, `infra_dev_standard`, or `infra_dev_break_fix_runbook`.
- Intended placement, if the user already knows it: root, route default parent, existing parent page, or new parent page.
- Source material: pasted notes, files, Jira tickets, Confluence pages, or user explanation.
- Whether the user wants a draft only or wants to publish after review.

## Drafting Rules

- Use the configured route template or supplied Confluence template first when available.
- Use `ahi_how_to` for public-facing how-tos and Help Desk how-to documentation.
- Use `ahi_troubleshooting` for internal agent troubleshooting guides.
- Infrastructure and DEV/DBA share `infra_dev_standard` and `infra_dev_break_fix_runbook` templates, but not Confluence spaces.
- For Infrastructure and DEV/DBA, use `infra_dev_break_fix_runbook` for Runbook KB articles and `infra_dev_standard` for Business Process KB articles.
- For public-facing Infrastructure or DEV/DBA content, keep it employee-safe: concise, no internal-only commands, no privileged access steps, and no internal escalation detail that employees should not act on directly.
- Use the exact section emojis defined in `templates.md`.
- Keep public-facing docs simple, concise, and action-oriented.
- Keep internal docs practical and complete, but usually one page.
- For long or PDF-like source material, draft one continuous Confluence article whenever practical.
- Split into multiple Confluence pages only when separate reader workflows justify it; keep the set to five pages maximum and prefer fewer.
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
