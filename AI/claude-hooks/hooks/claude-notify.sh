#!/usr/bin/env bash
# Posts a macOS notification for Claude Code hook events. The subtitle names the
# host app that launched this session (Terminal, iTerm, VS Code, Superset, ...).
# Wired to PermissionRequest and Stop in ~/.claude/settings.json.
# Hook payload = JSON on stdin.

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
tool=$(printf '%s' "$input"  | jq -r '.tool_name // empty')

# --- which app is hosting this Claude Code session? ------------------------------
app_from_bundle_id() {
  case "$1" in
    com.microsoft.VSCode)          echo "VS Code" ;;
    com.microsoft.VSCodeInsiders)  echo "VS Code Insiders" ;;
    com.vscodium.codium)           echo "VSCodium" ;;
    com.apple.Terminal)            echo "Terminal" ;;
    com.googlecode.iterm2)         echo "iTerm" ;;
    dev.warp.Warp*)                echo "Warp" ;;
    com.mitchellh.ghostty)         echo "Ghostty" ;;
    com.github.wez.wezterm)        echo "WezTerm" ;;
    net.kovidgoyal.kitty)          echo "kitty" ;;
    co.zeit.hyper)                 echo "Hyper" ;;
    com.jetbrains.*|com.google.android.studio) echo "JetBrains" ;;
    *claude*|com.anthropic.*)      echo "Claude app" ;;
    *) echo "" ;;
  esac
}

app_from_term_program() {
  case "$1" in
    vscode)         echo "VS Code" ;;
    Apple_Terminal) echo "Terminal" ;;
    iTerm.app)      echo "iTerm" ;;
    WarpTerminal)   echo "Warp" ;;
    ghostty)        echo "Ghostty" ;;
    WezTerm)        echo "WezTerm" ;;
    Hyper)          echo "Hyper" ;;
    tmux)           echo "tmux" ;;
    *) echo "" ;;
  esac
}

app_from_ancestry() {
  local pid=$PPID exe i
  for i in $(seq 1 15); do
    { [ -z "$pid" ] || [ "$pid" -le 1 ]; } 2>/dev/null && break
    exe=$(ps -o comm= -p "$pid" 2>/dev/null) || break
    case "$exe" in
      */Visual\ Studio\ Code.app/*|*Code\ Helper*) echo "VS Code"; return ;;
      */iTerm.app/*)      echo "iTerm"; return ;;
      */Terminal.app/*)   echo "Terminal"; return ;;
      */Warp.app/*)       echo "Warp"; return ;;
      */Ghostty.app/*)    echo "Ghostty"; return ;;
      */WezTerm.app/*)    echo "WezTerm"; return ;;
      */kitty.app/*)      echo "kitty"; return ;;
      */Hyper.app/*)      echo "Hyper"; return ;;
      */Claude.app/*)     echo "Claude app"; return ;;
      */Applications/*.app/*)
        printf '%s\n' "$exe" | sed -E 's#.*/Applications/([^/]+)\.app/.*#\1#'; return ;;
      sshd*|*/sshd)       echo "SSH-sessie"; return ;;
    esac
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  echo ""
}

detect_host() {
  [ -n "${SUPERSET_HOME_DIR}${SUPERSET_AGENT_ID}${SUPERSET_WORKSPACE_ID}" ] && { echo "Superset"; return; }
  [ "${CLAUDE_CODE_ENTRYPOINT}" = "intellij" ] && { echo "JetBrains"; return; }
  [ -n "$SSH_CONNECTION" ] && { echo "SSH-sessie"; return; }

  local a
  a=$(app_from_bundle_id "${__CFBundleIdentifier}"); [ -n "$a" ] && { echo "$a"; return; }
  a=$(app_from_term_program "${TERM_PROGRAM}");      [ -n "$a" ] && { echo "$a"; return; }
  a=$(app_from_ancestry);                            [ -n "$a" ] && { echo "$a"; return; }
  echo "${TERM_PROGRAM:-onbekende app}"
}

subtitle=$(detect_host)

case "$event" in
  PermissionRequest) body="Toestemming voor: ${tool:-een tool}" ;;
  Stop)              body="Sessie klaar" ;;
  *)                 body="${event:-Claude Code}" ;;
esac

osascript \
  -e 'on run argv' \
  -e 'display notification (item 1 of argv) with title "Claude Code" subtitle (item 2 of argv)' \
  -e 'end run' \
  "$body" "$subtitle" 2>/dev/null || true
