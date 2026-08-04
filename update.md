# Workflow OS Update

## WOS Documentation v0.1.8

This update adds conservative long-document handling to `wos-documentation`.

When `KB Refresh` or `$documentation-draft` receives long, unstructured, OneNote-derived, or PDF-like source material, the plugin now treats the source as raw material instead of copying its length or page shape.

Expected behavior:

- Prefer one continuous Confluence article whenever practical.
- Keep public-facing documentation simple, concise, and employee-safe.
- Keep internal documentation practical and complete without unnecessary sprawl.
- Split into multiple Confluence pages only when separate reader workflows genuinely justify it.
- Do not exceed five pages when a split is truly required, and prefer fewer pages.
- Preserve verified facts, exact errors, commands, paths, and required operational details.
- Use `[TBD]` or `<PLACEHOLDER>` for missing information instead of inventing content.

Updated plugin:

- `wos-documentation` v0.1.8

After updating WOS from GitHub, installed users should refresh or reinstall `wos-documentation` from `/plugins` so Codex loads v0.1.8.
