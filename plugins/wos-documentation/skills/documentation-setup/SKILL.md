---
name: documentation-setup
description: Configure Workflow OS Documentation route defaults, including Confluence spaces, templates, and optional default parent pages for Help Desk, Infrastructure, DEV/DBA, and Athens employee-facing documentation.
---

# `$documentation-setup` - Confluence Documentation Defaults

Use when the user installs `wos-documentation`, wants to set or change route defaults, or wants to add Confluence templates and page placement defaults. Persistent setup is preferred for team rollout, but operational skills may use a per-document walkthrough when setup has not been finalized.

## Required References

Load these before asking setup questions:

- `${plugin_root}/../references/documentation-standard.md`
- `${plugin_root}/../references/confluence-workflow.md`
- `${plugin_root}/../references/templates.md`

## Step 1 - Explain Scope

Briefly tell the user:

- This setup records documentation route defaults only.
- Confluence is the system of record for published documentation.
- Every documentation request will ask for a route: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
- Each route can have its own Confluence space, template, and optional default parent page.
- If setup is skipped, documentation requests can still use a per-document walkthrough, but defaults will not persist.
- Confluence reads are allowed.
- Confluence creates and updates require explicit confirmation in the current turn.
- A session/request can temporarily use another Confluence space without changing the route default.

## Step 2 - Route Spaces

Ask for the Confluence space key or space name for each route:

- Help Desk. Known Help Desk defaults are `HelpDesk System Processes` / `AIH` for system-process and internal how-to documentation, `HelpDesk Troubleshooting` / `AHI` for troubleshooting articles, and `HelpDesk Public` / `AEHT` for public-facing Help Desk content.
- Infrastructure. The confirmed Infrastructure team space is `Internal Infrastructure KB` / `IIK`.
- DEV/DBA team. The confirmed DEV/DBA team space is `Dev Team KB` / `DTK`.
- Public-facing for Athens employees. The confirmed public-facing space is `HelpDesk Public` / `AEHT`.

If multiple routes share a space, record the same space on each route. If the user wants to leave a route unconfigured, allow it and make the skill ask for that space before publishing later.

If the user gives a page URL, infer the space if possible, then ask them to confirm the space key before saving it.

Do not invent a default. If unsure, offer to search Confluence through Atlassian Rovo when available.

## Step 3 - Route Templates

Ask for the assigned template for each configured route.

Accept Confluence page URLs, page IDs, named Confluence templates, pasted template text, or built-in template choices. Never store secrets or private credentials.

Built-in choices:

- `ahi_how_to` - Primary Help Desk how-to template; also valid for Infrastructure, DEV/DBA, and Public-facing Athens employee documentation.
- `ahi_troubleshooting` - Internal agent troubleshooting guide; valid for Help Desk, Infrastructure, and DEV/DBA internal troubleshooting.
- `infra_dev_standard` - Shared Infrastructure and DEV/DBA Business Process KB article template.
- `infra_dev_break_fix_runbook` - Shared Infrastructure and DEV/DBA Runbook KB article template.

If the user does not have a template for a route yet, record the best built-in choice rather than a vague `fallback`.

During setup, Infrastructure and DEV/DBA routes can record a default template, but operational drafting must still ask whether each new document is a Runbook KB article or a Business Process KB article. After that, ask whether the document is internal or public-facing for Athens employees.

## Step 4 - Optional Default Parent Pages

Ask whether each route should have a default parent page/location inside its assigned Confluence space.

Record a default parent only when the user provides one. If not configured, the plugin must ask at publish time whether the page belongs at the root or under a parent page.

## Step 5 - Output Profile

Show the final profile in concise JSON-like form. Include a setup completion timestamp:

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
      "template": "ahi_how_to",
      "default_parent": "https://..."
    },
    "infrastructure": {
      "label": "Infrastructure",
      "space": "IIK",
      "template": "infra_dev_standard",
      "default_parent": null
    },
    "dev_dba": {
      "label": "DEV/DBA team",
      "space": "DTK",
      "template": "infra_dev_standard",
      "default_parent": null
    },
    "public_athens": {
      "label": "Public-facing for Athens employees",
      "space": "AEHT",
      "template": "ahi_how_to",
      "default_parent": "https://..."
    }
  },
  "setup_completed_at": "<ISO timestamp>"
}
```

## Step 6 - Save Setup Marker

If Workflow OS local state is available, save the route profile into `<data_root>/.agent/local.json` and set:

```json
"plugin_state": {
  "wos-documentation": {
    "mandatory": true,
    "setup_completed_at": "<ISO timestamp>"
  }
}
```

Preserve existing `plugin_state` entries, existing Jira setup, and existing optional plugin selections.

If Workflow OS Memory Engine is available, also ask whether to save this as a user preference.

If neither Workflow OS local state nor Memory Engine is available, provide the profile for the user to keep and clearly state that setup is only complete for the current conversation; future Documentation skills may ask for `$documentation-setup` again until a persistent WOS profile exists.

If the user confirms, write only the profile and high-level preference through memory-engine MCP. Do not write directly to vault files. Do not store copied page contents unless the user explicitly asks and the content contains no secrets.

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
- Only modify Workflow OS local setup state when saving this Documentation setup profile; do not modify unrelated files.
