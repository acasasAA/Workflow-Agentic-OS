---
name: project-orchestrate
description: Use when a Workflow OS project has completed planning, Jira contains the project phase issues, and the user wants dependency-aware orchestration before implementation.
---

# `$project-orchestrate` — Orchestrate Project Execution

You are the Workflow OS project orchestrator. This skill runs after planning is complete and Jira has the authoritative project phase structure. Do not use this to create the initial project, import an existing workspace, or replace `$project-new`.

Load `${plugin_root}/references/orchestration-policy.md` and follow it. Load `${plugin_root}/../jira/references/emoji-format.md` before drafting Jira descriptions or comments.

## Step 1 — Confirm Project Source

Resolve the active project with `${plugin_root}/scripts/active-project.ps1`. If no project is active, ask for the project Jira key or route the user to `$project-new`, `$project-import`, or `$project-resume`.

Fetch the project-level Jira item with Atlassian Rovo. Jira reads are allowed. Confirm that Jira now contains the planned phase tasks/subtasks. If phase issues are missing, stop and tell the user orchestration starts only after the plan has been uploaded/updated into Jira.

## Step 2 — Analyze Jira

Read the parent item, child phase issues, descriptions, comments, statuses, assignees, and issue links. Treat Jira as the source of truth.

Identify:

- phase titles and Jira keys
- dependencies and blockers
- likely file/system ownership
- work type: code/config/docs/research/Jira-only
- safe parallel groups
- phases that must stay linear
- missing information that blocks delegation

Do not infer hidden dependencies optimistically. When uncertain, mark a phase linear or ask the user.

## Step 3 — Present Execution Graph

Show a compact graph before asking for greenlight:

```text
Execution graph from Jira

Phase 1: <key> <title>
  -> must run first because <dependency>

Phase 2: <key> <title>
Phase 3: <key> <title>
  -> can run in parallel after Phase 1

Phase 4: <key> <title>
  -> integration and verification
```

For each phase, include execution mode, model/effort choice, Superpowers protocol, and why it is safe or unsafe to delegate.

## Step 4 — Jira Write Manifest

If Jira needs updates before implementation, show a write manifest:

- creates/updates
- description changes
- dependency links
- status transitions
- orchestration comments

Use the WOS emoji format for descriptions and comments. Ask for one explicit approval for the manifest in the current turn. Execute only listed writes after approval. Any new write requires new confirmation.

Deletes are blocked. If cleanup is needed, tell the user exactly what to delete manually in Jira.

## Step 5 — Greenlight Or Opt Out

Ask whether to greenlight orchestration for this project:

- If yes, record the approved execution graph and proceed only when the user says to implement.
- If no, record that this project is linear and continue with normal single-thread work.

Opt-out is project-specific and does not change global Workflow OS behavior.

## Step 6 — Implementation Dispatch

When the user explicitly says to implement, delegate only the approved independent work:

- Use worktree execution for file-changing phases in git-backed workspaces.
- Use session-only execution for read-only/research/Jira-only phases.
- Do not delegate phases with unresolved dependencies, conflicts, manual credential flows, or unclear boundaries.
- Give every agent its assigned Jira key, allowed Jira action scope, model/effort guidance, Superpowers protocol, and required handoff packet.

Subagents may post comments on their assigned Jira item only. Description edits, dependency links, transitions, final synthesis, and parent updates stay with the orchestrator.

## Step 7 — Integrate

Review handoff packets, inspect diffs where applicable, run verification, and resolve conflicts. If verification fails, use `superpowers:systematic-debugging` before declaring completion.

After integration, produce a final synthesis and, with explicit approval, update Jira and write a project checkpoint.

## Hard Rules

- No orchestration before the plan is represented in Jira.
- No automatic implementation before user greenlight and an explicit implement instruction.
- No delegated deletes.
- No Jira write outside an approved manifest.
- No secrets in Jira, memory, handoff packets, or `WOS.md`.
