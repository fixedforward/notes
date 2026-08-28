# Claude Code hooks

Backup of my Claude Code hook configuration. Source of truth: `~/.claude/settings.json`.

## Files

- [`settings.hooks.json`](settings.hooks.json) — the `hooks` block, extracted verbatim.

## What the hooks do

| Event | Action |
|---|---|
| `PermissionRequest` | macOS `display notification` — "Claude vraagt toestemming voor: `<tool_name>`" (parsed from the hook payload with `jq`) |
| `Stop` | macOS `display notification` — "Sessie klaar" |
| `PermissionRequest`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `StopFailure`, `PostToolUse`, `PostToolUseFailure` | Call `$SUPERSET_HOME_DIR/hooks/notify.sh` if present — **managed by Superset**, not hand-written; safe to drop if not using Superset |

All commands end in `|| true` so a missing dependency never blocks the session.

## Restore onto a new machine

Merge the `hooks` key from `settings.hooks.json` into `~/.claude/settings.json` (create the file if absent):

```bash
jq -s '.[0] * .[1]' ~/.claude/settings.json AI/claude-hooks/settings.hooks.json > /tmp/merged.json \
  && mv /tmp/merged.json ~/.claude/settings.json
```

Requires `jq`. The notification hooks are macOS-only (`osascript`).
