# Workflow OS Task Orchestration Policy

Task orchestration is a lightweight companion to project orchestration. It is for ticket-sized work with clearly independent streams. It must not create project phases, write `WOS.md`, or behave like `$project-new`.

## When To Orchestrate

Use task orchestration only when the ticket or task has multiple independent work streams that can be safely handled in parallel, such as:

- read-only investigation plus documentation drafting
- logs/config review plus Jira/customer-facing summary
- independent checks against separate systems
- small code/config work plus separate verification research

Do not orchestrate when the task is a single action, requires live user choices, requires credentials/manual UI work, touches shared files from multiple streams, or has unclear acceptance criteria.

## Execution Modes

- **Worktree agent**: file-changing work in a git-backed workspace.
- **Session-only agent**: read-only investigation, Jira summarization, documentation review, and context gathering.
- **No delegation**: unclear, dependent, credential-heavy, production-sensitive, or conflict-prone work.

For non-git folders, warn before any parallel file-editing work and prefer linear execution.

## Jira Rules

The task orchestrator may manage routine Jira comments and status recommendations, but description edits and transitions require explicit approval. Task agents may post comments only on their assigned Jira item or stream summary if approved.

All Jira descriptions and comments must follow the WOS emoji format in `plugins/jira/references/emoji-format.md`.

Deletes/archive remain blocked across Rovo, `acli`, and any other Jira path. If cleanup is needed, call it out for the user to do manually.

## Model Selection

Choose the cheapest capable model:

- lowest cost for Jira/context summaries, routine comments, simple docs, and checklist updates
- stronger coding model for code/config/scripts/infrastructure changes
- highest reasoning for failed verification, security-sensitive work, production impact, or final integration

Explain model/effort choices in the task execution plan.

## Superpowers Protocol

Superpowers is part of the task orchestration skill stream, not a hook.

Use:

- `superpowers:systematic-debugging` for errors, broken tests, incidents, and unclear defects
- `superpowers:test-driven-development` for meaningful code behavior changes where tests are reasonable
- `superpowers:verification-before-completion` before returning completed work
- `superpowers:using-git-worktrees` for file-changing parallel streams
- code review skills for high-risk or production-impacting work

Superpowers is not required for simple Jira-only updates, summaries, or low-risk docs.

## Handoff Packet

Every delegated stream must return:

```text
Phase/task:
Jira key:
Execution mode:
Model/effort used:
Superpowers used:
Files changed:
Commands run:
Verification result:
Jira comment posted:
Risks/blockers:
Dependencies discovered:
Recommended next step:
```
