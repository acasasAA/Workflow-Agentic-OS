---
name: documentation-setup
description: Configure Workflow OS Documentation route defaults, including Confluence spaces, templates, and optional default parent pages for Help Desk, Infrastructure, DEV/DBA, and Athens employee-facing documentation.
---

# `$documentation-setup` - Confluence Documentation Defaults

Use when the user installs `wos-documentation`, wants to set or change route defaults, or wants to add Confluence templates and page placement defaults.

## Required References

Load these before asking setup questions:

- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`

## Step 1 - Explain Scope

Briefly tell the user:

- This setup records documentation route defaults only.
- Confluence is the system of record for published documentation.
- Every documentation request will ask for a route: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
- Each route can have its own Confluence space, template, and optional default parent page.
- Confluence reads are allowed.
- Confluence creates and updates require explicit confirmation in the current turn.
- A session/request can temporarily use another Confluence space without changing the route default.

## Step 2 - Route Spaces

Ask for the Confluence space key or space name for each route:

- Help Desk.
- Infrastructure.
- DEV/DBA team.
- Public-facing for Athens employees.

If multiple routes share a space, record the same space on each route. If the user wants to leave a route unconfigured, allow it and make the skill ask for that space before publishing later.

If the user gives a page URL, infer the space if possible, then ask them to confirm the space key before saving it.

Do not invent a default. If unsure, offer to search Confluence through Atlassian Rovo when available.

## Step 3 - Route Templates

Ask for the assigned template for each configured route.

Accept Confluence page URLs, page IDs, named Confluence templates, or pasted template text. Never store secrets or private credentials.

If the user does not have a template for a route yet, record `fallback` for that route and use `templates.md`.

## Step 4 - Optional Default Parent Pages

Ask whether each route should have a default parent page/location inside its assigned Confluence space.

Record a default parent only when the user provides one. If not configured, the plugin must ask at publish time whether the page belongs at the root or under a parent page.

## Step 5 - Output Profile

Show the final profile in concise JSON-like form:

```json
{
  "documentation_routes": {
    "help_desk": {
      "label": "Help Desk",
      "space": "SPACEKEY",
      "template": "https://...",
      "default_parent": "https://..."
    },
    "infrastructure": {
      "label": "Infrastructure",
      "space": "SPACEKEY",
      "template": "https://...",
      "default_parent": null
    },
    "dev_dba": {
      "label": "DEV/DBA team",
      "space": "SPACEKEY",
      "template": "fallback",
      "default_parent": null
    },
    "public_athens": {
      "label": "Public-facing for Athens employees",
      "space": "SPACEKEY",
      "template": "https://...",
      "default_parent": "https://..."
    }
  }
}
```

## Step 6 - Save Preference

If Workflow OS Memory Engine is available, ask whether to save this as a user preference.

If the user confirms, write only the profile and high-level preference through memory-engine MCP. Do not write directly to vault files. Do not store copied page contents unless the user explicitly asks and the content contains no secrets.

If memory is unavailable, provide the profile for the user to keep and continue without failing.

## Step 7 - Finish

Tell the user they can now use:

- `$documentation-draft`
- `$documentation-review`
- `$documentation-publish`

## Hard Rules

- Do not write to Confluence during setup.
- Do not store secrets.
- Do not assume route spaces.
- Do not permanently change a route space from a one-time override.
