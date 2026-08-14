# Workflow OS Confluence Workflow

Use this workflow for all Confluence documentation work.

## Required Documentation Route

Every time the plugin documents work that someone ran, it must ask which documentation route applies before drafting or publishing:

- `help_desk` - Help Desk.
- `infrastructure` - Infrastructure.
- `dev_dba` - DEV/DBA team.
- `public_athens` - Public-facing documentation for Athens employees.

The selected route determines the default Confluence space and template for that document. Do not skip this question unless the user already made one of these four choices in the same request.

After the route is selected, apply the route's configured template. If the route does not have a configured template, offer the built-in template choices from `templates.md`. Help Desk should offer the AHI How-To Guide first and the AHI Troubleshooting Article second. Public-facing Athens employee documentation should use the AHI How-To Guide. Infrastructure and DEV/DBA should offer the Infrastructure/DEV Standard Page first and the Infrastructure/DEV Break/Fix Runbook second; they share these templates but keep separate Confluence spaces.

For Help Desk routing:

- Public-facing Athens employee Help Desk content goes to `HelpDesk Public` / `AEHT`.
- Help Desk troubleshooting articles go to `HelpDesk Troubleshooting` / `AHI`.
- Help Desk process, system-process, and internal how-to documentation goes to `HelpDesk System Processes` / `AIH`.

For Infrastructure and DEV/DBA routes, ask two follow-up questions before drafting:

1. Ask whether the document is a Runbook KB article or a Business Process KB article.
2. Ask whether the document is internal or public-facing for Athens employees.

If the user does not know the difference:

- Runbook KB article: use this for break/fix or operational steps that resolve an issue, restore service, perform a technical task, run commands, validate a system state, or roll back a change.
- Business Process KB article: use this for a repeatable workflow, intake process, handoff, approval path, team procedure, or non-break/fix process where the main goal is to explain how work moves from start to finish.

Use `infra_dev_break_fix_runbook` for Runbook KB articles. Use `infra_dev_standard` for Business Process KB articles.

If an Infrastructure or DEV/DBA document is internal, use that route's configured team space. The confirmed Infrastructure team space is `Internal Infrastructure KB` with space key `IIK`. The confirmed DEV/DBA team space is `Dev Team KB` with space key `DTK`. If an Infrastructure or DEV/DBA document is public-facing for Athens employees, use `HelpDesk Public` / `AEHT` instead and keep the source team visible in the draft preface.

## Route Configuration

Each route has an assigned Confluence space and template. During setup, collect both for every route the user wants enabled.

Current known route spaces:

- Help Desk public-facing: `HelpDesk Public` / `AEHT`.
- Help Desk system processes and internal how-to: `HelpDesk System Processes` / `AIH`.
- Help Desk troubleshooting: `HelpDesk Troubleshooting` / `AHI`.
- Infrastructure: `Internal Infrastructure KB` / `IIK`.
- DEV/DBA: `Dev Team KB` / `DTK`.

DEV/DBA shares Infrastructure template structure, but it must not automatically share the Infrastructure space unless the user explicitly configures it that way.

The setup profile shape is:

```json
{
  "documentation_routes": {
    "help_desk": {
      "label": "Help Desk",
      "space": "AIH",
      "spaces": {
        "system_processes": "AIH",
        "troubleshooting": "AHI",
        "public": "AEHT"
      },
      "template": "Confluence page URL, page id, named template, ahi_how_to, or ahi_troubleshooting",
      "default_parent": "optional Confluence page URL or page id"
    },
    "infrastructure": {
      "label": "Infrastructure",
      "space": "IIK",
      "template": "infra_dev_standard or infra_dev_break_fix_runbook",
      "default_parent": "optional Confluence page URL or page id"
    },
    "dev_dba": {
      "label": "DEV/DBA team",
      "space": "DTK",
      "template": "Confluence page URL, page id, named template, infra_dev_standard, or infra_dev_break_fix_runbook",
      "default_parent": "optional Confluence page URL or page id"
    },
    "public_athens": {
      "label": "Public-facing for Athens employees",
      "space": "AEHT",
      "template": "Confluence page URL, page id, named template, or ahi_how_to",
      "default_parent": "optional Confluence page URL or page id"
    }
  }
}
```

If a route is selected but not configured, ask for its Confluence space before publishing. A draft may continue with the appropriate built-in template choice from `templates.md`.

## Space Selection

1. Load the user's documentation route profile when available.
2. Ask for the required route if it was not already supplied in the request.
3. Use the Confluence space assigned to the selected route.
4. If the user gives a one-time override, state the active space for this request and confirm it will not persist.
5. If no space is configured for the selected route, ask the user for the Confluence space key or space name before publishing.

Legacy profile fields may exist from older versions:

```json
{
  "default_confluence_space": "SPACEKEY",
  "default_audience": "internal",
  "public_docs_space": "SPACEKEY",
  "internal_docs_space": "SPACEKEY",
  "template_pages": {
    "public": "Confluence page URL or page id",
    "internal": "Confluence page URL or page id"
  }
}
```

Treat those fields as fallback only. The route map is authoritative for new setup.

## Required Questions Before Drafting

When required information is missing, ask direct questions and wait for answers before creating the draft. Do not provide a completed KB draft after a "Gaps To Confirm" list.

For Help Desk troubleshooting articles, required questions include:

- What exact issue, symptom, error, or request should the KB solve?
- What user, device, asset tag, ticket, or reference values are known and which should be placeholders?
- What are the approved resolution steps, including whether any command, admin action, or Windows setting is allowed?
- What access level or role should perform the steps?
- What validation checks prove the issue is resolved?
- Who owns escalation if the steps fail?
- Where should the page be placed in Confluence if publishing is requested?

If the user provides a screenshot, conversation, or short note and says to "let me know if there are gaps," ask these as questions first. Only draft after the user answers.

## Page Placement

After the route and space are known, ask where the page should go inside that Confluence space:

- At the root of the space.
- Under the configured default parent page for that route.
- Under an existing parent page or folder/page chosen by the user.
- Under a newly named parent page, if the user wants a new container and confirms the create action.

For Confluence, "folder" usually means a parent page in the page tree. If the user says folder, interpret it as the intended parent page and confirm the exact target before writing.

If the target parent page is not known:

1. Ask for a Confluence page URL, page title, or page id.
2. Search/fetch through Atlassian Rovo when available to resolve it.
3. Confirm the resolved parent page before publishing.

## Tooling

- Use the Atlassian Rovo connector first for Confluence search, fetch, create, and update actions.
- If Rovo is unavailable or lacks the required operation, tell the user what is missing and continue with a draft instead of improvising a write path.
- Confluence reads are allowed.
- Confluence creates and updates require explicit user confirmation in the current turn.
- Do not delete, archive, move, restrict, or materially restructure Confluence pages unless the user explicitly requests the specific action and the governing safety policy allows it.

## Template Handling

When a route-specific Confluence template page is configured or supplied:

1. Fetch the template before drafting.
2. Treat the template as the primary structure.
3. Keep the Workflow OS documentation standard as the quality bar.
4. If the template conflicts with the standard, explain the conflict and choose the safer, more concise structure unless the user says otherwise.

When no template is available:

- Use `documentation-standard.md` and `templates.md`.
- Use the built-in template choice that matches the selected route and document type.
- For Infrastructure or DEV/DBA, use `infra_dev_standard` unless the user is documenting a break/fix incident or runbook, then use `infra_dev_break_fix_runbook`.
- For public-facing Infrastructure or DEV/DBA content, remove internal-only implementation detail, commands, privileged access notes, and escalation details that employees should not use directly.
- Do not include `JSM Optimization Advisory` in WOS Documentation route defaults unless a future request explicitly brings it into scope.

## Publishing Flow

Before a Confluence create or update:

1. Identify the selected route.
2. Identify the route-assigned or temporary target space.
3. Identify the route template or fallback template.
4. Ask where the page should be placed: root, route default parent, existing parent page, or new parent page.
5. Resolve and confirm parent page when needed.
6. Show the proposed title, route, space, placement, and concise change summary.
7. Ask for explicit confirmation to publish or update.
8. After a successful write, return the Confluence link and summarize what changed.

Never treat draft approval as publish approval unless the user explicitly says to publish/update Confluence.

## Session Override

When the user says to use another Confluence space for this session or this document:

- Use that space only for the active request.
- Do not update the saved default.
- Mention the temporary space in the final answer.
- Return to the saved default on the next request unless the user overrides again.
