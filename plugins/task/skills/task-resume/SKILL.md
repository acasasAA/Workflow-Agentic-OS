---
name: task-resume
description: Resume or switch to a one-off Workflow OS task by slug or Jira key. Use when the user wants context for a ticket-sized task without loading a project.
---

# `$task-resume` — Resume One-Off Task

You are switching active task context.

## Step 1 — Pick task

If the user provided a Jira key or slug, search for it:

```json
{ "type": "task-state", "query": "<input>", "limit": 5 }
```

If not, list recent tasks:

```json
{ "type": "task-state", "limit": 10 }
```

Show task slug, Jira key, status, and next action. Let the user pick.

## Step 2 — Set active_task

Call `${plugin_root}/scripts/active-task.ps1 -Set <task-slug>`.

Do not alter `active_project`.

## Step 3 — Summarize

In 3-5 bullets, summarize:

- task title and Jira key
- current status
- blocker/dependency
- next action
- whether a Jira read should be performed now

Jira reads are allowed. Do not write to Jira from this skill.
