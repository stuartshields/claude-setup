#!/bin/bash
# PostToolUse hook (Read|Grep|Glob): warns after consecutive read-only tool calls without an edit.
# Replaces prose rule: "After 5 file reads without a code change, stop."
# Advisory only (exit 0). Warning text becomes a system reminder.

INPUT=$(cat)
TOOL_NAME=$(jq -r '.tool_name // ""' <<<"$INPUT")

# Prefer stdin session_id (canonical); fall back to CLAUDE_CODE_SESSION_ID env var (2.1.132+).
SESSION_ID=$(jq -r '.session_id // ""' <<<"$INPUT")
SESSION_ID="${SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-unknown}}"
READ_COUNT_FILE="/tmp/claude-read-count-${SESSION_ID}"

# Reset counter on write/edit tools (tracked by the tool name that triggered this)
case "$TOOL_NAME" in
	Write|Edit|MultiEdit)
		echo "0" > "$READ_COUNT_FILE"
		exit 0
		;;
esac

# Increment read counter
CURRENT=$(cat "$READ_COUNT_FILE" 2>/dev/null || echo "0")
NEXT=$((CURRENT + 1))
echo "$NEXT" > "$READ_COUNT_FILE"

if [ "$NEXT" -ge 12 ]; then
	echo "CONTEXT DRIFT: ${NEXT} consecutive reads without action. You are gathering context without using it. Summarise what you've learned, then either act or ask the user what's missing."
elif [ "$NEXT" -ge 8 ]; then
	echo "CONTEXT CHECK: ${NEXT} reads without an edit. Do you have enough to act? If not, what specific question remains?"
fi
# Thresholds raised 5/7 → 8/12 (2026-05-15). Investigation-heavy work (audits,
# code review across many files) routinely hit the old thresholds during normal
# operation. Raising preserves the signal for true drift while reducing noise.

exit 0
