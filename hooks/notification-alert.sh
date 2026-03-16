#!/bin/bash
# Notification hook — alerts when Claude needs attention.
# Fires on: permission_prompt, idle_prompt, auth_success, elicitation_dialog.
# Cannot block or modify notifications.

IFS=$'\t' read -r TITLE MSG < <(jq -r '[.title // "Claude Code", .message // "Needs your attention"] | @tsv')

# Terminal bell
printf '\a'

# macOS notification
osascript -e "display notification \"${MSG}\" with title \"${TITLE}\" sound name \"Ping\"" 2>/dev/null &

exit 0
