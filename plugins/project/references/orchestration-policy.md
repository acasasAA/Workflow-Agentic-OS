# Workflow OS Project Orchestration Policy

Project orchestration is explicit and user-controlled. It runs only after project planning is complete and Jira contains the authoritative epic/project item plus phase tasks or subtasks.

## Sequence

1. `$project-new` creates or links the project-level Jira item and writes project memory.
2. The user enters plan mode and builds the project plan.
3. After planning, the plan is uploaded or updated in Jira as phase tasks/subtasks using WOS emoji descriptions.
4. `$project-orchestrate` reads Jira, analyzes the phase structure, and proposes execution.
5. The user chooses whether to greenlight orchestration for this project or keep it linear.
6. Implementation begins only after the user instructs the orchestrator to implement.

## Execution Graph

The orchestrator must show a dependency-aware graph before asking for the greenlight:

```text
Phase 1 first -> Phases 2/3 parallel -> Phase 4 integration
```

Parallel delegation is allowed only when phases are independent, do not touch the same files or systems, and do not require unresolved user decisions. Dependency order comes from Jira issue links when present, then Jira descriptions/comments, then the project-state memory.

Use Jira issue links for real dependencies when available, such as "Phase A blocks Phase B". Also include dependency text in descriptions for human readability. If linking fails, continue with description/memory dependency data and report the warning.

## Execution Modes

- **Worktree agent**: default for code, scripts, config, infrastructure, docs inside a repo, or any file-changing work.
- **Session-only agent**: read-only Jira analysis, Confluence/company knowledge research, context summarization, planning support, and other non-mutating work.
- **No delegation**: phases with unresolved dependencies, likely file conflicts, unclear scope, live credential/manual UI requirements, production risk without a rollback plan, or decisions that need the user first.

For non-git workspaces, warn that parallel file-editing phases are not safe. Use session-only execution unless the user explicitly accepts the risk.

## Jira Write Manifest

The orchestrator owns Jira structure:

- creates or updates phase issues
- updates descriptions
- creates dependency links
- proposes/transitions statuses
- posts final synthesis comments

Before Jira writes, show a batch write manifest with all creates, updates, links, comments, and transitions. One explicit approval in the current turn authorizes only the listed writes. Any new unlisted write requires a new confirmation.

Phase agents may post comments only on their assigned Jira item. They must not edit descriptions, parent epic content, links, transitions, or issue structure.

All Jira descriptions and comments must follow the WOS emoji format in `plugins/jira/references/emoji-format.md`.

Deletes/archive remain blocked across Rovo, `acli`, and any other Jira path. If cleanup is needed, call it out for the user to perform manually in Jira.

## Model Selection

Choose the cheapest capable model and reasoning effort for each delegated unit:

- **Lowest cost / lowest effort**: Jira summarization, routine Jira issue/comment work from approved instructions, simple documentation, status updates, and checklist cleanup.
- **Strong coding model**: code, config, scripts, infrastructure, or multi-file changes.
- **Highest reasoning**: final integration, failed verification, security-sensitive work, production-impacting changes, or cross-system debugging.
- **No subagent**: live user decisions, secrets/credential handling, unclear boundaries, or work that cannot be verified independently.

Explain the model/effort choice briefly in the execution graph.

## Superpowers Protocol

Superpowers is part of the orchestration stream, not a hook. Include a Superpowers protocol section in every orchestration plan.

"When applicable" means:

- Use `superpowers:systematic-debugging` when a phase involves a failure, broken test, error, or unclear defect.
- Use `superpowers:test-driven-development` when a phase changes meaningful code behavior and tests can reasonably be written.
- Use `superpowers:verification-before-completion` before every phase agent returns completed work.
- Use `superpowers:using-git-worktrees` for file-changing parallel phases.
- Use `superpowers:requesting-code-review` and `superpowers:receiving-code-review` for high-risk integration, production-impacting, security-sensitive, or cross-module changes.

Superpowers is not required for simple Jira-only updates, basic summaries, or low-risk documentation edits.

## Handoff Packet

Every delegated phase must return:

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

The orchestrator reviews all packets before integration, Jira synthesis, project checkpointing, or completion.
