# Workflow OS Confluence Workflow

Use this workflow for all Confluence documentation work.

## Required Documentation Route

Every time the plugin documents work that someone ran, it must ask which documentation route applies before drafting or publishing:

- `help_desk` - Help Desk.
- `infrastructure` - Infrastructure.
- `dev_dba` - DEV/DBA team.
- `public_athens` - Public-facing documentation for Athens employees.

The selected route determines the default Confluence space and template for that document. Do not skip this question unless the user already made one of these four choices in the same request.

## Route Configuration

Each route has an assigned Confluence space and template. During setup, collect both for every route the user wants enabled.

The setup profile shape is:

```json
{
  "documentation_routes": {
    "help_desk": {
      "label": "Help Desk",
      "space": "SPACEKEY",
      "template": "Confluence page URL, page id, or named template",
      "default_parent": "optional Confluence page URL or page id"
    },
    "infrastructure": {
      "label": "Infrastructure",
      "space": "SPACEKEY",
      "template": "Confluence page URL, page id, or named template",
      "default_parent": "optional Confluence page URL or page id"
    },
    "dev_dba": {
      "label": "DEV/DBA team",
      "space": "SPACEKEY",
      "template": "Confluence page URL, page id, or named template",
      "default_parent": "optional Confluence page URL or page id"
    },
    "public_athens": {
      "label": "Public-facing for Athens employees",
      "space": "SPACEKEY",
      "template": "Confluence page URL, page id, or named template",
      "default_parent": "optional Confluence page URL or page id"
    }
  }
}
```

If a route is selected but not configured, ask for its Confluence space and template before publishing. A draft may continue with the fallback template for that route.

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
- Use the fallback template that matches the selected route.

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
