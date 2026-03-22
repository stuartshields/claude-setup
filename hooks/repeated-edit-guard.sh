#!/bin/bash
# PreToolUse hook (Edit): warns when the same file is edited 4+ times in a session.
# Catches workaround chains — repeated fixes to the same file signal a wrong mental model.
# Advisory only (exit 0). Warning text becomes a system reminder.

FILE_PATH=$(jq -r '.tool_input.file_path // ""')

[ -z "$FILE_PATH" ] && exit 0

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
COUNTER_FILE="/tmp/claude-edit-count-${SESSION_ID}"

# Count edits to this file
CURRENT=$(grep -c "^${FILE_PATH}$" "$COUNTER_FILE" 2>/dev/null || echo "0")
echo "$FILE_PATH" >> "$COUNTER_FILE"
NEXT=$((CURRENT + 1))

if [ "$NEXT" -ge 4 ]; then
	echo "WORKAROUND CHAIN WARNING: You have edited $(basename "$FILE_PATH") ${NEXT} times this session. Stop and re-read ~/.claude/rules/discipline.md § 'No workaround chains' before continuing. If your fix didn't work after 3 edits, your mental model is wrong — investigate the root cause, don't patch the symptoms."
fi

exit 0
