#!/bin/bash
# Notification hook — alerts when Claude needs attention.
# Fires on: permission_prompt, idle_prompt, auth_success, elicitation_dialog.
# Observe-only — cannot block or modify notifications.

INPUT=$(cat)
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"' 2>/dev/null)
MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"' 2>/dev/null)

# Terminal bell (triggers dock badge in most terminals)
printf '\a'

# macOS notification banner (visible even behind other windows)
osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"Ping\"" 2>/dev/null &

exit 0
