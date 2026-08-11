# WOS Task

`wos-task` manages Codex-native task agendas, meeting action capture, one-off task lifecycle, checkpoints, completion, and optional Jira personal task-board sync.

## Optional Dashboard Template

The static dashboard template lives at:

```text
plugins/task/templates/task-dashboard
```

Use it when a user wants a deployable visual task board alongside `$task-agenda`. It is optional: the normal WOS Task agenda still works without a dashboard, GitHub Pages, or a backend.

To publish the dashboard, copy the contents of `templates/task-dashboard` into a standalone GitHub repository, push to `main`, and enable GitHub Pages with GitHub Actions.

