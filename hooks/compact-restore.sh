#!/bin/bash
# SessionStart compact hook - reads PreCompact saved state if available,
# otherwise rebuilds context from filesystem.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
[ -z "$CWD" ] && CWD="$PWD"

# Try PreCompact saved state first
PRECOMPACT="/tmp/claude-precompact-${SESSION_ID}.txt"
if [ -s "$PRECOMPACT" ]; then
	printf 'POST-COMPACTION CONTEXT RESTORE:\n'
	cat "$PRECOMPACT"
	rm -f "$PRECOMPACT"

	# Flag that compaction occurred (consumed by drift-review-stop.sh)
	touch "/tmp/claude-compacted-${SESSION_ID}"

	# Mid-session drift checkpoint: inject modified file list for cross-checking
	TRACK_FILE="/tmp/claude-drift-${SESSION_ID}"
	if [ -f "$TRACK_FILE" ]; then
		DRIFT_COUNT=$(sort -u "$TRACK_FILE" | wc -l | tr -d ' ')
		if [ "$DRIFT_COUNT" -ge 5 ]; then
			DRIFT_LIST=$(sort -u "$TRACK_FILE" | head -20)
			printf '\n\nDRIFT CHECKPOINT: You modified %d files before compaction. Cross-check these for consistency as you continue:\n%s\n' "$DRIFT_COUNT" "$DRIFT_LIST"
		fi
	fi

	exit 0
fi

# Fallback: rebuild from filesystem
PROJECT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
RESTORE=""

CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
[ ! -f "$CLAUDE_MD" ] && CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
	RESTORE="${RESTORE}PROJECT CLAUDE.md (first 50 lines):\n$(head -50 "$CLAUDE_MD")\n\n"
fi

STATE_MD="$PROJECT_ROOT/.planning/STATE.md"
if [ -f "$STATE_MD" ]; then
	RESTORE="${RESTORE}PROJECT STATE.md:\n$(cat "$STATE_MD")\n\n"
fi

if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	CHANGED=$(git -C "$PROJECT_ROOT" diff --name-only 2>/dev/null)
	STAGED=$(git -C "$PROJECT_ROOT" diff --cached --name-only 2>/dev/null)
	if [ -n "$CHANGED" ] || [ -n "$STAGED" ]; then
		RESTORE="${RESTORE}UNCOMMITTED CHANGES:\n"
		[ -n "$STAGED" ] && RESTORE="${RESTORE}Staged: ${STAGED}\n"
		[ -n "$CHANGED" ] && RESTORE="${RESTORE}Modified: ${CHANGED}\n"
		RESTORE="${RESTORE}\n"
	fi

	RECENT=$(git -C "$PROJECT_ROOT" log --oneline -3 2>/dev/null)
	[ -n "$RECENT" ] && RESTORE="${RESTORE}RECENT COMMITS:\n${RECENT}\n\n"
fi

if [ -f "$PROJECT_ROOT/package.json" ]; then
	BUILD=$(jq -r '.scripts.build // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	TEST=$(jq -r '.scripts.test // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	LINT=$(jq -r '.scripts.lint // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	if [ -n "$BUILD" ] || [ -n "$TEST" ] || [ -n "$LINT" ]; then
		RESTORE="${RESTORE}PROJECT COMMANDS:"
		[ -n "$BUILD" ] && RESTORE="${RESTORE} build='${BUILD}'"
		[ -n "$TEST" ] && RESTORE="${RESTORE} test='${TEST}'"
		[ -n "$LINT" ] && RESTORE="${RESTORE} lint='${LINT}'"
		RESTORE="${RESTORE}\n"
	fi
fi

[ -n "$RESTORE" ] && printf "POST-COMPACTION CONTEXT RESTORE:\n%b" "$RESTORE"
exit 0
