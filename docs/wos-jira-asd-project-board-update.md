# WOS Jira ASD and Project Board Creation Update

## Summary

This update clarifies how Workflow OS Jira should choose issue/request types when creating work in Jira.

## ASD tickets

`ASD` is treated as the IT service-desk path.

When a team member asks Workflow OS to create an `ASD` ticket, Workflow OS must ask whether the ticket is:

- `AI Gen Issue` for problems, symptoms, incidents, broken behavior, access issues, investigation, or resolution.
- `AI Gen Request` for planned work, setup, configuration, fulfillment, follow-up, or other non-incident requests.

The exact Jira display names may differ. If the available issue/request type names are not exact matches, Workflow OS should inspect the available values when tooling exposes them and select the matching value that contains `AI`. If several AI-related candidates exist, Workflow OS must show the choices and ask the user.

Before writing, Workflow OS must show:

- The exact Jira issue type that will be sent.
- The exact service/request type that will be sent, or `n/a` if the tool path has no separate request-type field.

If Workflow OS cannot verify or set the required AI-related ASD issue/request type, it must stop instead of creating a best-effort ticket with the wrong type.

## Project boards

Project boards such as `TPM`, `AJD`, `GPT`, `HMB`, infrastructure boards, and similar spaces should use the normal project-management shape when those issue types are available.

Workflow OS should prioritize:

- Epic
- Task
- Subtask

For project-board work, Workflow OS should search or list relevant existing Epics when context is available, ask whether the new work belongs under an existing Epic, and avoid creating a new Epic unless the user explicitly confirms it is a new project container.

Workflow OS should not use ASD-style AI issue/request types for project boards unless the user explicitly says that the target project is configured that way.

## Deployment impact

This affects Jira setup guidance, first-use onboarding guidance, Jira creation behavior, and colleague rollout test instructions.
