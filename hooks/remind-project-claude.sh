#!/bin/bash
# UserPromptSubmit hook: emits only actionable CLAUDE.md reminders.
# Keeps steady-state prompts quiet to reduce context overhead.

# Read only needed fields — avoid buffering full payload.
read -r CWD SESSION_ID < <(jq -r '[.cwd // "", .session_id // ""] | @tsv')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
	exit 0
fi

[ -z "$SESSION_ID" ] && exit 0

cd "$CWD" || exit 0

# Find project root (git root or cwd)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# Check for CLAUDE.md at project root
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
	# Also check .claude/CLAUDE.md
	CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
	if [ ! -f "$CLAUDE_MD" ]; then
		exit 0
	fi
fi

# Skip if we're in the global .claude directory itself (not a project)
case "$PROJECT_ROOT" in
	*/.claude) exit 0 ;;
esac

# Cache file for this project/session.
PROJECT_HASH=$(printf '%s' "$PROJECT_ROOT" | md5)
CACHE_FILE="/tmp/claude-remind-${PROJECT_HASH}-${SESSION_ID}.state"

# Get file age in days
if command -v stat >/dev/null 2>&1; then
	MODIFIED=$(stat -f %m "$CLAUDE_MD" 2>/dev/null || echo 0)
	NOW=$(date +%s)
	AGE_DAYS=$(( (NOW - MODIFIED) / 86400 ))
else
	AGE_DAYS=0
fi

# Count uncommitted changed files to gauge session activity
CHANGED_FILES=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	CHANGED_FILES=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
fi

# Build only actionable reminders.
NOTES=""

if [ "$AGE_DAYS" -gt 14 ]; then
	NOTES="${NOTES}CLAUDE.md CHECK: Project CLAUDE.md is ${AGE_DAYS} days old. Review if conventions changed. "
fi

if [ "$CHANGED_FILES" -gt 8 ]; then
	NOTES="${NOTES}CLAUDE.md CHECK: ${CHANGED_FILES} files modified. If architecture changed, update project CLAUDE.md. "
fi

[ -z "$NOTES" ] && exit 0

STATE_KEY=$(printf '%s' "$NOTES" | md5)
NOW=$(date +%s)
LAST_TS="0"
LAST_KEY=""
if [ -s "$CACHE_FILE" ]; then
	IFS='|' read -r LAST_TS LAST_KEY < "$CACHE_FILE"
fi

# Re-emit only when state changes, or every 15m as a sparse reminder.
if [ "$STATE_KEY" = "$LAST_KEY" ] && [ $((NOW - LAST_TS)) -lt 900 ]; then
	exit 0
fi

echo "${NOW}|${STATE_KEY}" > "$CACHE_FILE" 2>/dev/null
echo "$NOTES"

exit 0
