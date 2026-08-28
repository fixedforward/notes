# Claude Code hooks

Backup of my Claude Code hook configuration. Source of truth: `~/.claude/settings.json`.

## Files

- [`settings.hooks.json`](settings.hooks.json) — the hand-written `hooks` block (Superset-managed hooks omitted).
- [`hooks/claude-notify.sh`](hooks/claude-notify.sh) — the notification script both hooks call. Lives at `~/.claude/hooks/claude-notify.sh`.

## What the hooks do

Both events call `claude-notify.sh`, which posts a macOS `display notification` titled
"Claude Code". The subtitle names the host app that launched the session (Terminal,
iTerm, VS Code, Superset, JetBrains, an SSH session, ...), detected from
`__CFBundleIdentifier` / `TERM_PROGRAM` / the process ancestry.

| Event | Notification body |
|---|---|
| `PermissionRequest` | "Toestemming voor: `<tool_name>`" (parsed from the hook payload with `jq`) |
| `Stop` | "Sessie klaar" |

The script ends in `|| true` so a missing dependency never blocks the session.

## Restore onto a new machine

1. Copy the script into place and make it executable:

   ```bash
   mkdir -p ~/.claude/hooks
   cp AI/claude-hooks/hooks/claude-notify.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/claude-notify.sh
   ```

2. Merge the `hooks` key from `settings.hooks.json` into `~/.claude/settings.json`
   (create the file if absent):

   ```bash
   jq -s '.[0] * .[1]' ~/.claude/settings.json AI/claude-hooks/settings.hooks.json > /tmp/merged.json \
     && mv /tmp/merged.json ~/.claude/settings.json
   ```

Requires `jq`. The notifications are macOS-only (`osascript`).
