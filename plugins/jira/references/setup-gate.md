# Workflow OS Jira Setup Gate

`wos-jira` is mandatory in Workflow OS onboarding, and `$jira-setup` is mandatory the first time a user uses Workflow OS Jira on their Codex install.

Before running any Jira operational skill other than `$jira-setup`, confirm Jira setup is complete. Check in this order:

1. The current conversation already completed `$jira-setup` and produced a Jira profile.
2. Workflow OS local state exists at `~/.codex/workflow-os.json -> data_root -> .agent/local.json`, and `plugin_state.wos-jira.setup_completed_at` is present.
3. A saved Workflow OS memory preference exists with Jira tenant and project defaults.

If none of those are true, stop immediately and tell the user:

```text
Workflow OS Jira setup is required before I can continue. Please run `$jira-setup`; I will continue this request after setup is complete.
```

Do not continue the original Jira operation until setup is complete. Do not treat hardcoded defaults such as `ASD` and `TPM` as completed setup by themselves.

When setup completes, the profile must include:

- Jira tenant URL.
- Jira project keys.
- Default project by work type.
- Primary Jira usage.
- `plugin_state.wos-jira.setup_completed_at` when Workflow OS local state is available.

Jira setup never writes to Jira. Jira reads are allowed; Jira writes still require explicit per-action confirmation.
