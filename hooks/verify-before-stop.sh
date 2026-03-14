#!/bin/bash
# UserPromptSubmit advisory digest: emits compact, rate-limited reminders.
# Policy: Stop remains block-only. Advisory output is surfaced before prompts.
# Non-blocking (always exits 0).

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')

[ "$EVENT" != "UserPromptSubmit" ] && exit 0
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
	exit 0
fi

[ -z "$SESSION_ID" ] && exit 0

# State-aware rate-limiting to avoid repeated advisory noise.
CACHE_FILE="/tmp/claude-verify-advisory-${SESSION_ID}.state"
NOW=$(date +%s)

cd "$CWD" || exit 0

# Skip if not a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	exit 0
fi

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
CHANGED_COUNT=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
TOTAL_CHANGED=$((CHANGED_COUNT + STAGED_COUNT))

NOTES=""

if [ "$TOTAL_CHANGED" -gt 0 ]; then
	NOTES="${NOTES}VERIFICATION: ${TOTAL_CHANGED} uncommitted file(s). Run project build/test/lint before finishing. "
fi

CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
[ ! -f "$CLAUDE_MD" ] && CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && [ "$CHANGED_COUNT" -gt 3 ]; then
	NOTES="${NOTES}CLAUDE.md CHECK: ${CHANGED_COUNT} modified file(s) this session. Confirm whether project conventions should be updated. "
fi

if [ -n "$NOTES" ]; then
	HAS_CLAUDE_CHECK=0
	if [ -f "$CLAUDE_MD" ] && [ "$CHANGED_COUNT" -gt 3 ]; then
		HAS_CLAUDE_CHECK=1
	fi
	STATE_KEY="${TOTAL_CHANGED}|${CHANGED_COUNT}|${HAS_CLAUDE_CHECK}"
	LAST_TS="0"
	LAST_KEY=""
	if [ -s "$CACHE_FILE" ]; then
		IFS='|' read -r LAST_TS LAST_KEY < "$CACHE_FILE"
	fi

	# Emit when state changes, or as a sparse reminder every 5 minutes.
	if [ "$STATE_KEY" = "$LAST_KEY" ] && [ $((NOW - LAST_TS)) -lt 300 ]; then
		exit 0
	fi

	echo "${NOW}|${STATE_KEY}" > "$CACHE_FILE" 2>/dev/null
	echo "$NOTES"
fi

exit 0
