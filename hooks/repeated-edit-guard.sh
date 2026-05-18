#!/bin/bash
# PreToolUse hook (Edit|Write): warns when the same file is edited 2+ times in a session.
# Catches workaround chains — repeated fixes to the same file signal a wrong mental model.
# Advisory only (exit 0). Warning text becomes a system reminder.

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")

[ -z "$FILE_PATH" ] && exit 0

# Prefer stdin session_id (canonical); fall back to CLAUDE_CODE_SESSION_ID env var (2.1.132+).
SESSION_ID=$(jq -r '.session_id // ""' <<<"$INPUT")
SESSION_ID="${SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-unknown}}"
COUNTER_FILE="/tmp/claude-edit-count-${SESSION_ID}"

# Count edits to this file
CURRENT=$(grep -c "^${FILE_PATH}$" "$COUNTER_FILE" 2>/dev/null || echo "0")
echo "$FILE_PATH" >> "$COUNTER_FILE"
NEXT=$((CURRENT + 1))

if [ "$NEXT" -ge 5 ]; then
	echo "WORKAROUND CHAIN WARNING: You have edited $(basename "$FILE_PATH") ${NEXT} times this session. Invoke the 'debugging' skill and apply § 'Anti-Loop Protocol'. If your fix didn't work after several edits, your mental model is wrong — state your hypothesis to the user, verify with a tool call, then fix. Do not guess with code."
elif [ "$NEXT" -ge 3 ]; then
	echo "DIAGNOSIS CHECK: This is your 3rd edit to $(basename "$FILE_PATH"). Before continuing, confirm: did you diagnose the root cause, or are you guessing? If guessing, stop and investigate first."
fi

# Thresholds raised 2/3 → 3/5 (2026-05-15). Multi-step refactors and review-feedback
# workflows legitimately edit the same file 2-3 times; firing on the 2nd edit was noise.

exit 0
