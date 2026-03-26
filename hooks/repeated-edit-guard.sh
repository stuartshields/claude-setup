#!/bin/bash
# PreToolUse hook (Edit|Write): warns when the same file is edited 2+ times in a session.
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

if [ "$NEXT" -ge 3 ]; then
	echo "WORKAROUND CHAIN WARNING: You have edited $(basename "$FILE_PATH") ${NEXT} times this session. Stop and re-read ~/.claude/rules/debugging.md § 'Anti-Loop Protocol'. If your fix didn't work after 2 edits, your mental model is wrong — state your hypothesis to the user, verify with a tool call, then fix. Do not guess with code."
elif [ "$NEXT" -ge 2 ]; then
	echo "DIAGNOSIS CHECK: This is your 2nd edit to $(basename "$FILE_PATH"). Before continuing, confirm: did you diagnose the root cause, or are you guessing? If guessing, stop and investigate first."
fi

exit 0
