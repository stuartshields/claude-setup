#!/bin/bash
# PostToolUse + PostToolUseFailure hook - detects reasoning loops and error spikes.
# Advisory only (exit 0). Warnings to stdout become system reminders.

# Single jq call to extract only what we need - avoids buffering full payload
IFS=$'\t' read -r SESSION_ID TOOL_NAME EVENT TOOL_INPUT < <(jq -r '[.session_id // "", .tool_name // "", .hook_event_name // "", (.tool_input | tostring) // ""] | @tsv')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$TOOL_NAME" ] && exit 0

LOG_FILE="/tmp/claude-perf-${SESSION_ID}.log"

# Determine success/failure from event type
STATUS="ok"
[ "$EVENT" = "PostToolUseFailure" ] && STATUS="fail"

# Hash input - first 8 chars for dedup (macOS: md5 reads from pipe, outputs 32-char hex directly)
INPUT_HASH=$(printf '%s' "$TOOL_INPUT" | md5 | cut -c1-8)

# Append: tool_name|input_hash|status
echo "${TOOL_NAME}|${INPUT_HASH}|${STATUS}" >> "$LOG_FILE"

# Only analyse every 5th entry to reduce overhead
LINE_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ')
[ $((LINE_COUNT % 5)) -ne 0 ] && exit 0

# Scan last 10 entries
LAST_10=$(tail -10 "$LOG_FILE" 2>/dev/null)
[ -z "$LAST_10" ] && exit 0

# Repeat detection: same tool + same input hash 3+ times in last 10
REPEAT_COUNT=$(echo "$LAST_10" | awk -F'|' -v tool="$TOOL_NAME" -v hash="$INPUT_HASH" '$1 == tool && $2 == hash' | wc -l | tr -d ' ')
if [ "$REPEAT_COUNT" -ge 3 ]; then
	echo "PERF WARNING: Repeated identical call to ${TOOL_NAME} detected (${REPEAT_COUNT}x). Possible reasoning loop."
fi

# Error rate: 5+ failures in last 10
ERROR_COUNT=$(echo "$LAST_10" | awk -F'|' '$3 == "fail"' | wc -l | tr -d ' ')
if [ "$ERROR_COUNT" -ge 5 ]; then
	echo "PERF WARNING: High tool failure rate (${ERROR_COUNT}/10). Session may be degraded."
fi

exit 0
