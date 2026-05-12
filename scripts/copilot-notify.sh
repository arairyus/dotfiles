#!/usr/bin/env bash

set -euo pipefail

payload="$(cat)"
event="${COPILOT_NOTIFY_EVENT:-$(printf '%s' "$payload" | jq -r '.hook_event_name // "unknown"')}"
notification_type="$(printf '%s' "$payload" | jq -r '.notification_type // empty')"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty')"
message="$(printf '%s' "$payload" | jq -r '.message // empty')"

title="Copilot CLI"
body="$message"

case "$event:$notification_type" in
  notification:elicitation_dialog)
    title="Copilot CLI: Input needed"
    body="${body:-Copilot is waiting for your input.}"
    ;;
  notification:permission_prompt)
    title="Copilot CLI: Permission needed"
    body="${body:-Copilot needs permission to continue.}"
    ;;
  notification:agent_completed)
    title="Copilot CLI: Background agent done"
    body="${body:-A background agent completed.}"
    ;;
  notification:agent_idle)
    title="Copilot CLI: Agent waiting"
    body="${body:-A background agent is waiting for follow-up.}"
    ;;
  notification:shell_completed)
    title="Copilot CLI: Shell completed"
    body="${body:-A shell command completed.}"
    ;;
esac

if [ -n "$cwd" ]; then
  body="$body"$'\n'"$cwd"
fi

body="${body:0:240}"
terminal_body="${title}: ${body//$'\n'/ }"

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null 2>&1; then
  cmux notify --title "$title" --body "$body" >/dev/null
elif [ -w /dev/tty ]; then
  printf '\033]9;%s\007' "$terminal_body" >/dev/tty
fi
