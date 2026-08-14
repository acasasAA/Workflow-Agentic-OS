# Workflow OS Documentation Templates

These are fallback templates. If the selected documentation route has an assigned Confluence template, use that template first.

## Built-In Template Assignment

Use these built-in template choices when a route does not have a configured Confluence template:

| Template choice | Primary route | Also allowed for | Source |
|---|---|---|---|
| `ahi_how_to` | Help Desk | Infrastructure, DEV/DBA team, Public-facing for Athens employees | AHI Template - How-to guide |
| `ahi_troubleshooting` | Help Desk | Infrastructure, DEV/DBA team | AHI Template - Troubleshooting article |
| `infra_dev_standard` | Infrastructure, DEV/DBA team | None | Infrastructure/DEV Confluence standard template |
| `infra_dev_break_fix_runbook` | Infrastructure, DEV/DBA team | None | IIK Runbook Template |

When documenting work that was run, ask the user which template choice applies after the route is selected if the route has more than one valid choice. For Help Desk, offer `ahi_how_to` first and `ahi_troubleshooting` second.

Every built-in template must use its defined emoji section headings. Do not remove the emoji from a section title, even when the source material or user wording does not include emojis.

Infrastructure and DEV/DBA share template structure only. They do not share Confluence spaces. Use the route-selected space from setup or the per-document walkthrough.

For Infrastructure and DEV/DBA, ask whether the document is a Runbook KB article or a Business Process KB article:

- Runbook KB article maps to `infra_dev_break_fix_runbook`.
- Business Process KB article maps to `infra_dev_standard`.

If the user is unsure, explain that a Runbook KB article fixes or operates something technical, while a Business Process KB article explains how a repeatable business/team workflow should happen.

## AHI How-To Guide

Use for public-facing how-to documentation and as the primary Help Desk template choice. Infrastructure and DEV/DBA may also use it when documenting a repeatable procedure for their audiences.

```text
# <How-to title>

## 🛠 Instructions
1. <First step>
2. <Second step>
3. <Third step>

## ⚠️ Important
<Highlight important information here. In Confluence, use an info/warning panel and choose the appropriate panel color or style.>

## 🔗 Related articles
- <Related Confluence page, service guide, Jira issue, vendor article, or support page>
```

## AHI Troubleshooting Article

Use for internal agent troubleshooting guides, especially Help Desk internal troubleshooting and other internal support teams when diagnosing or resolving known issues.

```text
# <Troubleshooting title>

## 🔴 Problem
<Describe the symptom, error, requester impact, or condition being investigated.>

## 🛠 Solution
1. <First troubleshooting or resolution step>
2. <Second troubleshooting or resolution step>
3. <Third troubleshooting or resolution step>

## ⚠️ Important
<Highlight important information here. In Confluence, use an info/warning panel and choose the appropriate panel color or style.>

## ✅ Validation
- <How to confirm the issue is resolved or the requested action succeeded>

## 🚦 Escalation
- <When to escalate and to whom>

## 🔗 Related articles
- <Related Confluence page, runbook, Jira issue, vendor article, dashboard, or support page>
```

## Infrastructure/DEV Standard Page

Use for general Infrastructure and DEV/DBA documentation that is not specifically a break/fix runbook. Use this exact section order and section emoji standard.

```text
# <Title>

## 🧭 Summary
State the purpose of the page in 1-3 concise sentences.

## 📦 Scope
State what the page covers and what it does not cover when relevant.

## 📥 Inputs
List required inputs, prerequisites, source documents, systems, or assumptions.
Use [TBD] for unknown values.

## 🛠 Procedure
Write steps as atomic actions.
Include the expected result after each step when it improves clarity or verifiability.

Example pattern:
1. Open the target system.
2. Select the required item.

## 📤 Output
State the expected deliverable, state change, artifact, or page outcome.
Make sure there are labels for the page.

## ✅ Validation
List checks that confirm the procedure or output is correct.
Use concrete checks, not vague statements.

## ⚠️ Exceptions
List failure cases, missing prerequisites, edge cases, escalation rules, or unsupported variants.

## 🔗 References
List source pages, tickets, documents, URLs, or related materials.
Use [TBD] if references are expected but unavailable.
```

## Infrastructure/DEV Break/Fix Runbook

Use for Infrastructure and DEV/DBA break/fix runbooks. Keep the document brief, use direct language, preserve exact errors and commands, and use placeholders for missing values.

```text
# <Runbook title>

## 🔴 Problem
Describe the issue in one or two sentences.
Include:
- The affected system
- The observed symptom or error
- The expected behavior

## 🛠 Solution
Provide the fix in numbered order.
1. State the action.
2. Include the exact command, path, or setting.
3. Add a validation step when needed.

## ✅ Expected Result
State what confirms the issue is resolved.

## 🏷 Labels
Use only when applicable:
> 📝 NOTE: Helpful context
> ⚠️ WARNING: Possible service, access, or data impact
> 🔐 ADMIN: Elevated permissions required
> ✅ VALIDATION: Confirms the fix worked
> ↩️ ROLLBACK: Reverses the change
> ⏳ TODO: Missing information

## 🤖 AI Instructions
Keep the document brief.
Use direct language.
Do not include background unless required to understand the fix.
Do not invent system names, paths, commands, or values.
Use <PLACEHOLDERS> for missing details.
Preserve exact errors and commands from the source material.
Return the completed runbook in Markdown.
```

## Help Desk Runbook

```text
# <Service or issue>: <support action>

## 🎯 Purpose
<What this helps the help desk resolve or complete.>

## 👥 Applies to
- Queue/request type:
- Users affected:
- Systems involved:

## 📥 Intake
- <Information to gather from the requester>

## 🛠 Procedure
1. <Step>
2. <Step>
3. <Step>

## ✅ Validation
- <How to confirm the issue is resolved>

## 🚦 Escalation
- <When to escalate and to whom>

## 🔗 Related links
- <Jira, Confluence, vendor, or system link>
```

## Infrastructure Runbook

```text
# <System>: <operation>

## 🎯 Purpose
<Why this operation exists.>

## 📦 Scope
- In scope:
- Out of scope:

## 📋 Prerequisites
- <Access, approval, tool, maintenance window, backup>

## 🛠 Procedure
1. <Step>
2. <Step>
3. <Step>

## ✅ Validation
- <Monitoring, logs, service checks, user checks>

## ↩️ Recovery
- <Rollback or failover path>

## 👤 Ownership
<Team or escalation path.>
```

## DEV/DBA Technical Note

```text
# <Application, database, or integration>: <change or procedure>

## 🎯 Purpose
<What this documents and why it matters.>

## 📦 Scope
- In scope:
- Out of scope:

## 🧩 Technical context
<Architecture, data flow, dependency, or implementation detail needed by the team.>

## 🛠 Procedure
1. <Step>
2. <Step>
3. <Step>

## ✅ Validation
- <Test, query, deployment check, or log check>

## ↩️ Rollback or recovery
- <How to revert or recover>

## 🔗 Related links
- <Jira, PR, repo, runbook, dashboard>
```

## Public-Facing Guide

```text
# <Task or feature name>

## 🧭 What this helps you do
<One or two sentences.>

## 📋 Before you start
- <Requirement, access, or prerequisite>

## 🛠 Steps
1. <Step>
2. <Step>
3. <Step>

## ✅ Expected result
<What success looks like.>

## 🔎 Troubleshooting
| Issue | What to try |
|---|---|
| <Issue> | <Resolution> |

## 🛟 Get help
<Support path or owner.>
```

## Internal Runbook

```text
# <System or process>: <action>

## 🎯 Purpose
<Why this page exists.>

## 📦 Scope
- In scope:
- Out of scope:

## 👤 Owner
<Team, role, or escalation path.>

## 📋 Preconditions
- <Access, tool, approval, or dependency>

## 🛠 Procedure
1. <Step>
2. <Step>
3. <Step>

## ✅ Validation
- <Check>
- <Check>

## ↩️ Recovery
- <Rollback, fallback, or escalation path>

## 🔗 Related links
- <Jira, PR, Confluence, source system>
```

## Internal Decision Note

```text
# Decision: <short decision>

## ✅ Decision
<The decision in one short paragraph.>

## 🧭 Context
<Why the decision was needed.>

## ⚖️ Options considered
| Option | Pros | Cons |
|---|---|---|
| <Option> | <Pros> | <Cons> |

## 📣 Impact
<Who or what changes because of this.>

## ➡️ Follow-up
- <Action, owner, or link>
```
