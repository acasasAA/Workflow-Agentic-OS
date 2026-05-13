# Workflow OS — Jira Tooling Policy

Workflow OS can use both the Atlassian Rovo Codex app connector and the official Atlassian CLI (`acli`) for Jira work.

## Tool order

1. **Use Atlassian Rovo first** for Jira/Confluence search, semantic lookup, fetching issues/pages, and app-connector writes that are exposed in the current session.
2. **Use `acli` as the deterministic fallback** when Rovo is unavailable or when the app connector does not expose the needed Jira operation.
3. **Use `acli` for Jira comments when no Rovo comment tool is exposed.** Write the approved comment body to a temporary file, post it with `acli jira workitem comment create --key "<KEY>" --body-file "<TEMPFILE>"`, then remove the temporary file.

## Chat usage

When the user asks for Jira work directly in chat, the agent may use these tools without invoking a Workflow OS skill, as long as the same safety rules are followed:

- Jira reads are allowed.
- Jira writes require explicit user confirmation in the current turn.
- Jira comments, descriptions, transitions, and worklogs must follow `emoji-format.md` when the write originates from Workflow OS.
- No secrets may be included in Jira text, command arguments, logs, memory notes, or temp files.

## `acli` commands

Check installation:

```powershell
acli --version
```

Check auth:

```powershell
acli auth status
acli jira auth status
```

Authenticate interactively:

```powershell
acli jira auth login --web
```

Read an issue:

```powershell
acli jira workitem view "<KEY>" --json
```

Post an approved comment from a temp file:

```powershell
acli jira workitem comment create --key "<KEY>" --body-file "<TEMPFILE>"
```

## Hard boundaries

- **Never use `acli` delete or archive commands.** `acli jira workitem delete`, `acli jira workitem archive`, comment deletes, link deletes, and equivalent destructive operations stay manual for the user.
- Do not use `acli` to bypass Rovo or Workflow OS safety boundaries.
- Do not pass secrets through command-line arguments.
- For writes, draft first, show the payload, and wait for explicit confirmation.
