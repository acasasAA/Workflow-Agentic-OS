# Workflow OS — Jira Write Format (Emoji Structure)

This format is mandatory for all writes to Jira originating from Workflow OS — comments, descriptions, titles, transitions. Used by the `wos-jira` plugin's skills and by every other plugin (`wos-project`) that writes to Jira through the Atlassian Rovo MCP.

## 1. Comment structure

Every Workflow OS comment starts with a status marker and a one-line summary, followed by structured sections. Sections are optional; omit if empty.

```
🟢 STATUS · <one-line summary of the update>

📋 What's done
- <bullet>
- <bullet>

🚧 In progress
- <bullet>

⛔ Blockers
- <bullet>

🔜 Next
- <bullet>

🔗 Refs
- <jira key or url>
```

Status markers (pick one):

| Marker | Use when |
|---|---|
| 🟢 | On track, normal progress |
| 🟡 | Caution: risk surfaced, needs attention but not blocked |
| 🔴 | Blocked: external dependency or decision required |
| 🔵 | Informational update, no state change |
| ✅ | Completion / done / closing comment |
| 🛠️ | Technical / implementation detail |

## 2. Description structure (epics, tasks, subtasks, tickets)

When Workflow OS creates a Jira work item, the description follows this skeleton. Sections are filled in based on what's known; leave headings even if the body is "TBD" so the structure stays predictable.

```
## 🎯 Objective
<one to three sentences>

## 📦 Scope
- In scope:
- Out of scope:

## ✅ Acceptance criteria
- <Given/When/Then or bullet criteria>

## 🔗 Links
- Parent: <key>
- Related: <key>
- External: <url>

## 📝 Notes
<free-form context>
```

## 3. Title conventions

- **Epic**: `[Epic] <Name>` — short, action-oriented (e.g. `[Epic] Migrate billing to new auth`).
- **Task**: `<Verb> <object>` — imperative (e.g. `Implement webhook handler`). No prefix needed.
- **Subtask**: same as task, but typically scoped narrower (e.g. `Add retry logic to webhook handler`).
- **Ticket** (helpdesk-style): `<area>: <symptom>` (e.g. `Payments: invoice email not sent`).

Avoid emoji in titles unless the team convention already uses them.

## 4. Transition comments

When transitioning a Jira item (e.g. To Do → In Progress, In Progress → Done), add a comment using §1's format. For closures, use the ✅ marker and include:

```
✅ DONE · <what was delivered>

📋 Delivered
- <bullet>

🔗 Refs
- PR: <url>
- Worklog: <link>
```

## 5. Worklog entries

Worklog descriptions follow this brief shape — they're terse, machine-parseable, and feed the Workflow OS `worklog` memory type:

```
🛠️ <category> · <one-line summary>
Time: <Xh Ym>
Refs: <pr|commit|comment-link>
```

Categories (pick one): `implementation`, `investigation`, `review`, `meeting`, `documentation`, `support`, `other`.

## 6. Hard rules

- **No deletes via writes.** Even if the Rovo MCP exposed a delete tool, Workflow OS's `enabled_tools` allow-list excludes it. Do not work around this.
- **No secrets in any field.** Strip tokens, passwords, keys before writing.
- **One status marker per comment.** Don't stack them.
- **Section headings are required** when their content is present. Skip sections you have nothing to put under.
- **Mention the Jira key only when linking elsewhere**, never as decoration ("for JIRA-123 we did X" — fine; "JIRA-123: did X" — redundant since you're commenting on JIRA-123).
