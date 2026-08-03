---
name: documentation-review
description: Review an existing draft or Confluence page against the Workflow OS documentation standard for clarity, concision, audience fit, and publish readiness.
---

# `$documentation-review` - Documentation Review

Use when the user asks for a documentation review, cleanup, readiness check, or standard compliance check.

## Required References

Load these before reviewing:

- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`

## Review Inputs

Use the content supplied by the user, fetched from Confluence, or read from local files when appropriate.

Identify or ask for the documentation route:

- Help Desk.
- Infrastructure.
- DEV/DBA team.
- Public-facing for Athens employees.

Use the selected route's expected template and Confluence space as review criteria when available.

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
