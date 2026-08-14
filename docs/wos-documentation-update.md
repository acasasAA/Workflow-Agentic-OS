# WOS Documentation Update

## Version

`wos-documentation` v0.1.9

## What changed

This update tightens the documentation workflow so WOS Documentation follows the same process no matter how a user asks for a KB article, draft, refresh, review, or Confluence publish.

### Required question gate

When required information is missing, WOS Documentation must ask direct questions before drafting.

This means:

- "Let me know if there are gaps" means ask the missing questions first.
- The plugin must not provide a completed draft after listing unresolved gaps.
- Blocking gaps should stop the draft until the user answers.
- Non-blocking unknowns can still be marked as `[TBD]` or `<PLACEHOLDER>` after the required intake is complete.

For Help Desk troubleshooting articles, WOS Documentation now asks for missing details such as:

- Exact issue, symptom, error, or requested support action.
- Known user, device, asset, ticket, or reference values.
- Which values should become placeholders.
- Approved resolution path.
- Whether commands, Windows Settings, or admin actions are allowed.
- Required access level or role.
- Validation checks.
- Escalation owner.
- Confluence placement when publishing is requested.

### Emoji section headings are required

All built-in templates now require emoji section headings.

This applies to:

- AHI How-To
- AHI Troubleshooting
- Infrastructure/DEV Standard Page
- Infrastructure/DEV Break/Fix Runbook
- Help Desk Runbook
- Infrastructure Runbook
- DEV/DBA Technical Note
- Public-Facing Guide
- Internal Runbook
- Internal Decision Note

The plugin must preserve the emoji in each section heading even if the source material or the user request does not include emojis.

### Confirmed Confluence spaces

WOS Documentation now uses the confirmed Confluence spaces by default:

- Public-facing Athens employee and Help Desk public content: `HelpDesk Public` / `AEHT`
- Help Desk troubleshooting articles: `HelpDesk Troubleshooting` / `AHI`
- Help Desk system-process and internal how-to documentation: `HelpDesk System Processes` / `AIH`
- Infrastructure internal documentation: `Internal Infrastructure KB` / `IIK`
- DEV/DBA internal documentation: `Dev Team KB` / `DTK`

Users can still provide a one-request Confluence space override, but that does not change the saved route default.

`JSM Optimization Advisory` is intentionally out of scope for WOS Documentation route defaults.

### Existing long-document behavior remains

The v0.1.8 long-document behavior still applies:

- Treat long, unstructured, OneNote-derived, or PDF-like material as raw source.
- Prefer one continuous Confluence article whenever practical.
- Split into multiple Confluence pages only when separate reader workflows genuinely justify it.
- Do not exceed five pages when a split is truly required, and prefer fewer.

## What users need to do

After the Workflow OS marketplace is updated from GitHub, users should update or reinstall `wos-documentation` from `/plugins` so Codex loads v0.1.9.

Expected plugin version:

- `wos-documentation` v0.1.9

## Quick test prompt

Use this prompt after updating to confirm the behavior:

```text
Use WOS Documentation to make a Help Desk internal troubleshooting KB from this short note. Let me know if there are gaps.

Note:
Device needs to leave and rejoin Entra ID before Intune enrollment works. User was told to reboot and sign back into Office.
```

Expected behavior:

- WOS Documentation should ask direct questions first.
- It should not provide a completed draft with unresolved gaps.
- When the draft is created later, the sections should use emoji headings.
