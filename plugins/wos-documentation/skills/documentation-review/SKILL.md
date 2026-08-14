---
name: documentation-review
description: Review an existing draft or Confluence page against the Workflow OS documentation standard for clarity, concision, audience fit, and publish readiness.
---

# `$documentation-review` - Documentation Review

Use when the user asks for a documentation review, cleanup, readiness check, or standard compliance check. If the user wants an existing KB article rewritten into the approved structure, use `$kb-refresh`; KB Refresh is the named feature for that workflow.

## Required References

Load these before reviewing:

- `${plugin_root}/../references/setup-gate.md`
- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`

Apply `setup-gate.md` before reading, reviewing, or rewriting documentation. If persistent Documentation setup is not complete, use the per-document walkthrough when route/template/space context is needed.

## Review Inputs

Use the content supplied by the user, fetched from Confluence, or read from local files when appropriate.

Identify or ask for the documentation route:

- Help Desk.
- Infrastructure.
- DEV/DBA team.
- Public-facing for Athens employees.

Use the selected route's expected template and Confluence space as review criteria when available.

If the document is a Help Desk or public-facing how-to, check it against `ahi_how_to`. If it is an internal agent troubleshooting guide, check it against `ahi_troubleshooting`. If it is Infrastructure or DEV/DBA documentation, check it against `infra_dev_standard` or `infra_dev_break_fix_runbook`. For every built-in template, verify the section emoji standard from `templates.md` is preserved.

For Infrastructure or DEV/DBA documentation, verify the draft clearly identifies:

- KB article type: Runbook KB article or Business Process KB article.
- Audience: internal or public-facing for Athens employees.
- Correct space routing: internal Infrastructure pages use `Internal Infrastructure KB` / `IIK`; internal DEV/DBA pages use `Dev Team KB` / `DTK`; public-facing pages use `HelpDesk Public` / `AEHT`; Help Desk troubleshooting pages use `HelpDesk Troubleshooting` / `AHI`; Help Desk system-process and internal how-to pages use `HelpDesk System Processes` / `AIH`.

If reviewing a Confluence page:

- Read the page through Atlassian Rovo when available.
- Do not update the page without explicit confirmation in the current turn.

## Findings First

Lead with actionable findings ordered by severity:

- Missing or risky content.
- Audience mismatch.
- Route/template mismatch.
- Overlong or unclear sections.
- Missing validation/support/ownership.
- Source gaps.
- Secret or sensitive-data concerns.

If there are no significant issues, say that clearly.

## Review Checklist

Check:

- Audience is clear.
- Documentation route is clear.
- Content follows the selected route's assigned or fallback template.
- Built-in template section headings include the required emojis.
- Page title matches the reader's task or object.
- Public-facing content is concise and avoids unnecessary implementation detail.
- Internal content is complete enough to operate from.
- Page length is reasonable.
- Multi-page structure is justified and limited to three to five pages.
- Validation or expected result is present.
- Support path or ownership is present.
- Confluence target space and page placement are clear when publish readiness is requested.
- Sources are linked or named.
- No secrets are present.

## Output

Provide:

- Findings.
- Suggested revised outline or wording when useful.
- Publish readiness: `ready`, `needs revision`, or `blocked`.

Do not publish or update Confluence unless the user explicitly confirms that action in the current turn.
