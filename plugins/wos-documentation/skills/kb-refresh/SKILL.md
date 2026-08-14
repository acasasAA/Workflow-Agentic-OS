---
name: kb-refresh
description: Refresh an existing KB article or Confluence page into the approved Workflow OS documentation structure while preserving correct source content.
---

# `$kb-refresh` - KB Refresh

Use when the user asks to update, clean up, restructure, standardize, modernize, or bring an existing KB article into the Workflow OS documentation standard.

KB Refresh means:

- Read the existing documentation or source material.
- Identify the correct documentation route, KB article type, audience, Confluence space, and template.
- Preserve accurate content, exact errors, commands, links, and operational details.
- Remove duplication, stale filler, unsupported claims, and structure that does not match the selected template.
- Return a refreshed, Confluence-ready KB article.

## Required References

Load these before refreshing a KB article:

- `${plugin_root}/../references/setup-gate.md`
- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`
- `${plugin_root}/../references/templates.md`

Apply `setup-gate.md` before refreshing. If persistent Documentation setup is not complete, run the per-document walkthrough for the current KB refresh.

## Required Inputs

Identify from the request or ask only when missing:

- Existing KB source: pasted text, local file, Confluence page URL, page ID, or page title.
- Documentation route: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
- For Infrastructure or DEV/DBA: Runbook KB article or Business Process KB article.
- For Infrastructure or DEV/DBA: internal or public-facing for Athens employees.
- Target Confluence space: route default, public-facing route space, or one-request override. Known defaults are `Internal Infrastructure KB` / `IIK`, `Dev Team KB` / `DTK`, `HelpDesk Public` / `AEHT`, `HelpDesk Troubleshooting` / `AHI`, and `HelpDesk System Processes` / `AIH`.
- Intended placement if the user plans to publish: root, route default parent, existing parent page, or new parent page.

If required information is missing, ask direct questions and stop before returning a refreshed KB. Do not output a completed KB after a "Gaps To Confirm" list. Treat "let me know if there are gaps" as a request to ask questions first.

If the user does not know whether the article is a Runbook KB article or Business Process KB article, explain:

- Runbook KB article: fixes or operates something technical, usually with symptoms, commands, validation, rollback, or expected system state.
- Business Process KB article: explains how a repeatable business or team workflow should happen from start to finish.

## Refresh Rules

- Keep verified source content.
- Preserve exact error messages, commands, paths, and values from the source.
- Use placeholders like `<PLACEHOLDER>` or `[TBD]` for missing values instead of inventing them.
- Use the selected route's configured template when available.
- Use the built-in template from `templates.md` when no configured template exists.
- Preserve the required section emojis for every built-in template, including Help Desk templates.
- Public-facing content must be simple, concise, employee-safe, and free of internal-only commands, privileged access steps, and internal escalation details.
- Internal content should be practical and complete, but usually one page.
- For long, unstructured, OneNote-derived, PDF-like, or multi-page source material, treat the source length as raw input only. The Confluence output should usually be one continuous article.
- Be conservative with page splitting. Do not split into multiple Confluence pages unless the article covers separate reader workflows; keep any multi-page refresh to five pages maximum and prefer fewer.
- If a split is necessary, explain why each page needs to exist before returning the refreshed structure.
- Do not include secrets, credentials, tokens, or private personal data.

## Confluence Handling

Confluence reads are allowed through Atlassian Rovo when available.

Do not update Confluence during KB Refresh unless the user explicitly asks to publish/update and confirms the Confluence write in the current turn. If the user wants to publish after the refresh, hand off to `$documentation-publish`.

## Output

Return:

- A short KB Refresh preface with route, article type, audience, target space, template used, and assumptions.
- The refreshed KB article in Confluence-ready Markdown or Atlassian-document-friendly structure.
- A short list of source gaps, removed stale content, or items needing owner confirmation when relevant.

If the source document is too incomplete to refresh safely, ask the missing questions first. Use `[TBD]` only for non-blocking values after the required intake questions have been answered.
