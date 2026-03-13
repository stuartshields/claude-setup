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

# Rate-limit advisory output to avoid chat noise.
CACHE_FILE="/tmp/claude-verify-advisory-${SESSION_ID}.ts"
NOW=$(date +%s)
if [ -f "$CACHE_FILE" ]; then
	LAST=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
	if [ $((NOW - LAST)) -lt 60 ]; then
		exit 0
	fi
fi

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
	echo "$NOW" > "$CACHE_FILE" 2>/dev/null
	echo "$NOTES"
fi

exit 0
