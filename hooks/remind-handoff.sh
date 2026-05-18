#!/bin/bash
# UserPromptSubmit advisory: nudge to run the handoff skill before /clear
# on long sessions without a recent HANDOFF.md.
# Policy: advisory only (exit 0), surfaced before the next prompt.
# Rate-limited to once per session per condition (cleared on SessionStart clear|resume).

INPUT=$(cat)

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')
[ "$EVENT" != "UserPromptSubmit" ] && exit 0

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // ""')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0
[ -z "$CWD" ] || [ ! -d "$CWD" ] && exit 0

# Threshold: ~200 transcript events. Long enough that /clear would lose real work.
THRESHOLD=200
LINES=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
[ -z "$LINES" ] && exit 0
[ "$LINES" -lt "$THRESHOLD" ] && exit 0

# Skip if HANDOFF.md exists and was touched in the last hour - user already handed off.
HANDOFF="${CWD}/HANDOFF.md"
if [ -f "$HANDOFF" ]; then
	MTIME=$(stat -f %m "$HANDOFF" 2>/dev/null || stat -c %Y "$HANDOFF" 2>/dev/null)
	NOW=$(date +%s)
	if [ -n "$MTIME" ] && [ $((NOW - MTIME)) -lt 3600 ]; then
		exit 0
	fi
fi

# Rate-limit: once per 30 min per session for this condition.
CACHE_FILE="/tmp/claude-remind-handoff-${SESSION_ID}.state"
NOW=$(date +%s)
LAST_TS="0"
if [ -s "$CACHE_FILE" ]; then
	LAST_TS=$(cat "$CACHE_FILE")
fi
if [ $((NOW - LAST_TS)) -lt 1800 ]; then
	exit 0
fi

echo "$NOW" > "$CACHE_FILE" 2>/dev/null
echo "HANDOFF: Long session (${LINES} transcript events). Consider invoking the handoff skill before /clear so the next session can resume from HANDOFF.md."

exit 0
