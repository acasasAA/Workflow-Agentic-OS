# Workflow OS Documentation Setup Gate

`wos-documentation` supports two setup modes while the team finalizes the operating model:

- Persistent setup: `$documentation-setup` records spaces, templates, and optional parent pages once, then future documentation requests reuse that profile.
- Per-document walkthrough: when no persistent setup exists, the plugin asks the route, template choice, Confluence space, and placement questions for the current document only.

In a full Workflow OS onboarding flow, prefer persistent setup. In direct documentation requests, use the per-document walkthrough instead of blocking the user.

Before running any Documentation operational skill other than `$documentation-setup`, check whether persistent Documentation setup is complete. Check in this order:

1. The current conversation already completed `$documentation-setup` and produced a documentation route profile.
2. Workflow OS local state exists at `~/.codex/workflow-os.json -> data_root -> .agent/local.json`, and `plugin_state.wos-documentation.setup_completed_at` is present.
3. A saved Workflow OS memory preference exists with a `documentation_routes` profile.

If none of those are true, run the per-document walkthrough and collect:

- Documentation route: Help Desk, Infrastructure, DEV/DBA team, or Public-facing for Athens employees.
- Template choice: configured route template, `ahi_how_to`, or `ahi_troubleshooting`.
- Target Confluence space.
- Placement: root, configured/default parent, existing parent page, or new parent page.

Do not claim the per-document walkthrough saved defaults. If the user wants the same choices reused later, send them to `$documentation-setup`.

When setup completes, the profile must include:

- A `documentation_routes` object.
- Route labels for Help Desk, Infrastructure, DEV/DBA team, and Public-facing for Athens employees.
- Space/template/default-parent values where known.
- `plugin_state.wos-documentation.setup_completed_at` when Workflow OS local state is available.

Documentation setup never writes to Confluence. Confluence reads are allowed; Confluence creates and updates still require explicit per-action confirmation.
