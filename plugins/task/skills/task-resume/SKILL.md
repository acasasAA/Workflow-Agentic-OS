---
name: task-resume
description: Resume or switch to a Workflow OS task agenda, one-off task, or Jira-linked task by slug or Jira key. Use when the user wants task context without loading a project.
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

Show task slug, Jira key if any, status, due date if any, and next action. Let the user pick.

## Step 2 — Set active_task

Call `${plugin_root}/scripts/active-task.ps1 -Set <task-slug>`.

Do not alter `active_project`.

## Step 3 — Summarize

If the selected task is an agenda, show the agenda table first. Otherwise summarize in 3-5 bullets:

- task title and Jira key
- current status
- due date/time, if any
- blocker/dependency
- next action
- whether a Jira read should be performed now

Jira reads are allowed. Do not write to Jira from this skill.
