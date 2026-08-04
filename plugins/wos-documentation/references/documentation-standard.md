# Workflow OS Documentation Standard

This standard applies to every document created or reviewed through the `wos-documentation` plugin.

## Named Feature

`KB Refresh` is the named feature for taking an existing KB article or Confluence page and updating it into the approved Workflow OS documentation structure. KB Refresh preserves correct source content, chooses the right route/template, removes stale or duplicated material, and returns a Confluence-ready article.

## Principles

- Confluence is the system of record for published documentation.
- Every documentation request must first be routed to one of four documentation routes: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
- Each route has an assigned Confluence space and template configured during setup.
- A different Confluence space may be used for a single request, but that override does not change the route default.
- Documentation should be useful, concise, source-backed, and easy to scan.
- Prefer one continuous Confluence article. Treat PDF-style page counts only as a planning limit, not as a reason to split a Confluence article.
- Be conservative with splitting. Use separate Confluence pages only when the reader's workflow genuinely requires separation.
- Internal documentation may be deeper than public-facing documentation, but avoid multi-page sprawl. When multiple pages are truly required, keep the set to five pages maximum and prefer fewer.
- Do not include secrets, credentials, personal access tokens, private keys, or sensitive customer data.
- Do not publish or materially update Confluence without explicit user confirmation in the current turn.

## Audience Modes

## Documentation Routes

### Help Desk

Use for support procedures, ticket-handling notes, user-impacting service behavior, intake/runbook steps, and issue-resolution documentation owned by the help desk.

### Infrastructure

Use for systems, network, identity, device management, cloud operations, access, monitoring, recovery, and operational runbooks owned by infrastructure.

### DEV/DBA Team

Use for application, database, integration, automation, deployment, data, and development-support documentation owned by DEV/DBA.

### Public-Facing For Athens Employees

Use for Athens employee-facing guides, how-tos, FAQs, access instructions, and support instructions. This route uses the public-facing audience rules.

### Public-facing

Use for employee, customer, or end-user documentation.

Public-facing documentation must:

- Start with the task, outcome, or question the reader came for.
- Use plain language and short sections.
- Include only the background needed to complete the task safely.
- Avoid implementation details unless they directly affect the user's action.
- Prefer numbered steps for procedures.
- Include expected result, support path, and known limits when relevant.
- Avoid internal acronyms unless they are defined in-line.

Recommended length:

- Short how-to: 300 to 700 words.
- Complex process: 700 to 1,200 words.
- FAQ/troubleshooting: concise entries with direct answers first.

### Internal

Use for team runbooks, implementation notes, operating procedures, decisions, audits, and handoffs.

Internal documentation may include:

- Purpose and scope.
- Owner or responsible team.
- Preconditions and dependencies.
- Step-by-step procedure.
- Validation or testing checklist.
- Rollback or recovery path.
- Known risks, open questions, and related Jira/Confluence links.

Recommended length:

- Standard internal doc: one focused page.
- Larger topic: keep as one continuous Confluence article when practical. Split only when each page has a distinct reader workflow; keep the set to five pages maximum and prefer fewer.
- Avoid long history sections; link to Jira, PRs, and previous Confluence pages instead.

## Long Source Handling

When source material is long, unstructured, exported from OneNote, or provided as a PDF-like file:

- Treat the source as raw material, not as the desired final structure.
- Compress repeated explanations, history, and duplicate steps into a concise Confluence article.
- Preserve verified facts, exact errors, commands, paths, and required operational details.
- Use `[TBD]` or `<PLACEHOLDER>` for missing information instead of expanding the document with guesses.
- Prefer one continuous Confluence article even when the source would span many PDF pages.
- If the content genuinely requires separate pages, propose the smallest useful page set and do not exceed five pages.
- Explain why any split is necessary before presenting a multi-page structure.

## Required Page Shape

Every page should include:

```text
# <Clear title>

## Purpose
<Why this page exists and who it is for.>

## Scope
<What is included and what is not included.>

## Steps or Details
<The main body. Use task-oriented headings.>

## Validation
<How the reader knows the work succeeded, or how reviewers checked the page.>

## Support or Ownership
<Who owns the page, where to ask questions, and related links.>
```

For very short public-facing docs, combine Scope and Support when the result is clearer.

## Confluence Page Rules

- Use Confluence headings in order. Do not skip from H1 to H3.
- Keep one idea per section.
- Use tables only when comparison, ownership, or field mapping is clearer than prose.
- Use expandable sections sparingly; they can hide information readers need.
- Link to approved source pages rather than copying large blocks of text.
- Name pages with the reader's task or object, not an internal work ticket.

## Review Checklist

Before publishing or updating Confluence:

- Audience is explicit: public-facing or internal.
- Page has a clear owner or support path.
- Content is concise for its audience.
- Steps are testable or reviewable.
- Claims are backed by approved sources, links, or user-provided context.
- No secrets or sensitive values are present.
- Documentation route is selected.
- Route-assigned or temporary Confluence space is confirmed.
- Page placement is confirmed: root, route default parent, existing parent, or new parent.
- User has explicitly approved the Confluence write in the current turn.
