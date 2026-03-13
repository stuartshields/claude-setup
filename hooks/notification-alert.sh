#!/bin/bash
# Notification hook — alerts when Claude needs attention.
# Fires on: permission_prompt, idle_prompt, auth_success, elicitation_dialog.
# Cannot block or modify notifications.

TYPE=$(jq -r '.notification_type // "attention"')

# Terminal bell
printf '\a'

# macOS notification
osascript -e "display notification \"Claude Code: ${TYPE}\" with title \"Claude Code\" sound name \"Ping\"" 2>/dev/null &

exit 0
