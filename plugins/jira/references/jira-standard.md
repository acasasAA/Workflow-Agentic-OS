# Workflow OS — Jira Team Standard

This standard defines how Athens IT agents should create, review, update, maintain, and close Jira work items. It is intentionally standalone: `wos-jira` must be usable without Workflow OS memory, project, or task plugins.

## 1. Core Principle

Jira is the team source of truth for work. Every Jira item should make the next action clear to a teammate who was not in the original conversation.

Use `emoji-format.md` for all titles, descriptions, comments, transition notes, and worklogs. Use `jira-tooling.md` for the Rovo-first / ACLI-fallback tool order.

## 2. Issue Type Decision Rules

Choose the smallest issue type that accurately represents the work.

### Epic

Use an Epic when the work:

- spans multiple phases or work streams
- needs child tasks or subtasks
- has cross-team visibility or project-management reporting value
- represents a product, service, rollout, migration, platform, or major improvement

Title format:

```text
🚀 [Epic] <Name>
```

### Task

Use a Task when the work:

- is a concrete deliverable
- can be completed by one owner or one small group
- may belong under an Epic
- does not require helpdesk intake behavior

Title format:

```text
🛠️ <Verb> <object>
```

### Subtask

Use a Subtask when the work:

- is a narrow execution step under an existing Task
- should not stand alone as a team-visible deliverable
- depends on the parent task context

Title format:

```text
🔧 <Verb> <object>
```

### Helpdesk / Support Ticket

Use a ticket when the work:

- came from an end user or support request
- has a symptom, request, access need, incident, or service desk workflow
- belongs in the IT ticketing system, usually `ASD`

Title format:

```text
🎫 <area>: <symptom or request>
```

Do not create helpdesk/support work as an Epic unless the user explicitly confirms they are managing a project container in a project-management board. Normal helpdesk intake should use the service desk ticket/request shape for the target board.

## 3. Athens Project Defaults

Use these as the default starting point, unless the user gives a more specific project key.

- `ASD`: main IT ticketing / service desk work.
- `TPM`: IT project management work.

Other projects are role- or user-specific. Do not assume them for general team use.

## 4. TPM Creation Rules

`TPM` is the IT project management board. Treat Epics as project containers and Tasks/Subtasks as the normal work items.

Before creating anything in `TPM`:

- Ask the user to double-check whether an existing Epic/project already exists.
- Use the available context to search/list relevant existing `TPM` Epics before drafting a new Jira write.
- Show likely matching Epics and ask whether the new work belongs under one of them.
- Prefer creating a Task under an existing Epic when the work belongs to an existing project.
- Prefer creating a Subtask only when the work is a narrow execution step under an existing Task.
- Do not create a new Epic unless the user explicitly confirms that this is a new project container.

Team default: most users create Tasks or Subtasks in `TPM`. Epic creation is normally limited to users who own project structure, such as the current rollout owner, a designated project manager, or another explicitly authorized project owner.

## 5. ASD Creation Rules

`ASD` is the IT Team Ticketing System. Use the ticketing defaults unless the user gives a more specific request type.

Before creating anything in `ASD`, clarify whether the user needs:

- `AI/Gen Issue`: use when the user is reporting a problem, symptom, incident, broken behavior, access issue, or something that needs investigation/resolution.
- `AI/Gen Task`: use when the user is requesting planned work, setup, configuration, follow-up, or a non-incident action.

Ask this explicitly when the user's wording is ambiguous. Do not guess between `AI/Gen Issue` and `AI/Gen Task`.

Important: for service desk projects, the user-facing request type and the Jira issue type may not be the same field. Before writing, show the user both values the tool will send:

```text
Project: ASD
Jira issue type: <exact issue type that will be sent>
Service/request type: AI/Gen Issue or AI/Gen Task
```

If the selected Rovo or `acli` create path cannot set the required `AI/Gen Issue` / `AI/Gen Task` request type, stop before writing and tell the user that the tool cannot guarantee the correct helpdesk type. Do not create a best-effort ticket with the wrong type.

## 6. Creation Quality Checklist

Before creating a Jira item, verify:

- The project key is correct.
- The issue type is correct.
- For `TPM`, existing relevant Epics were checked before creating a new Epic or standalone Task.
- For `ASD`, `AI/Gen Issue` vs `AI/Gen Task` was clarified and the actual Jira issue type/request type payload was shown.
- The title has exactly one lead emoji and is action-oriented.
- The objective explains why the work exists.
- Scope says what is in and out where useful.
- Acceptance criteria or desired outcome is clear.
- Parent/related links are included when known.
- No secrets are present.
- Similar or related work was considered when context is available.

If any required detail is missing, ask for it before drafting.

## 7. Maintenance / Comment Standard

Use comments to maintain continuity. A good comment should answer:

- What changed?
- What is currently happening?
- What is blocked?
- What happens next?
- What references matter?

Use the status marker that best fits the update:

- `🟢 STATUS` for normal progress
- `🟡 STATUS` for risk/caution
- `🔴 STATUS` for blocked work
- `🔵 STATUS` for informational updates
- `✅ DONE` for completion/closure
- `🛠️ TECHNICAL` for implementation detail

Do not post vague comments such as "working on this" unless paired with useful context.

## 8. Closure Standard

Before closing or recommending closure, verify:

- The requested outcome was delivered or explicitly deferred.
- Any unresolved blocker is documented.
- The final comment uses the `✅ DONE` structure.
- References to PRs, worklogs, docs, or related tickets are included when relevant.
- The user has explicitly confirmed any Jira transition or write action.

## 9. Description Maintenance

Descriptions should be kept useful as the canonical summary of the work. Use `$jira-mod` when:

- the description is missing structure
- scope or acceptance criteria changed
- the item was created without enough context
- a project/task evolved and the description is stale

Do not use comments as a substitute for fixing a bad description when the description is the source of confusion.

## 10. Review Standard

Use `$jira-review` to evaluate an existing issue before changing it. A review should classify the issue as:

- `Pass`: already follows the standard
- `Needs cleanup`: usable but should be improved
- `Needs clarification`: missing details required for action
- `Wrong shape`: likely wrong issue type, project, parent, or scope

The review should recommend the smallest safe improvement. It must not write to Jira unless the user explicitly confirms the proposed write.

## 11. Hard Boundaries

- Jira reads are allowed.
- Jira writes require explicit confirmation in the current turn.
- Jira deletes and archives are blocked for agents.
- Do not include secrets in Jira text.
- Do not bulk-edit multiple issues through the Jira standard skills.
- If cleanup requires deletion, tell the user to do it manually in Jira.
