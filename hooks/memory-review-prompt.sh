#!/bin/bash
# Memory review prompt - single script handling three lifecycle events.
# Trigger 1 (UserPromptSubmit): Wrap-up phrases indicating session end.
# Trigger 2 (SessionStart): Accumulated memory files from prior sessions.
# Trigger 3 (PostToolUse): Context at 30% remaining with 3+ new memory files.
# Advisory only - never blocks. Rate-limited to avoid noise.

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')

if [ -z "$CWD" ] || [ ! -d "$CWD" ] || [ -z "$SESSION_ID" ]; then
	exit 0
fi

cd "$CWD" || exit 0

# Find project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# Find memory directory for this project
PROJECT_PATH_ENCODED=$(echo "$PROJECT_ROOT" | tr '/' '-')
MEMORY_DIR="$HOME/.claude/projects/${PROJECT_PATH_ENCODED}/memory"

# No memory directory = nothing to review
[ ! -d "$MEMORY_DIR" ] && exit 0

REVIEW_CACHE="${MEMORY_DIR}/.last-review"
TRIGGER=""
NEW_COUNT=0

# ── Helper: count new memory files since last review ──

count_new_memory() {
	local LAST_TS="0"
	if [ -f "$REVIEW_CACHE" ]; then
		LAST_TS=$(cat "$REVIEW_CACHE" 2>/dev/null || echo "0")
	fi

	local COUNT=0
	for f in "$MEMORY_DIR"/*.md; do
		[ ! -f "$f" ] && continue
		[ "$(basename "$f")" = "MEMORY.md" ] && continue
		local FILE_TS
		FILE_TS=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo "0")
		if [ "$FILE_TS" -gt "$LAST_TS" ]; then
			COUNT=$((COUNT + 1))
		fi
	done

	echo "$COUNT"
}

# ── Trigger 1: Wrap-up phrases (UserPromptSubmit only) ──

if [ "$EVENT" = "UserPromptSubmit" ]; then
	# Rate limit: once per session for wrap-up detection
	WRAPUP_CACHE="/tmp/claude-memory-wrapup-${SESSION_ID}"
	[ -f "$WRAPUP_CACHE" ] && exit 0

	USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' | tr '[:upper:]' '[:lower:]')

	# Match wrap-up phrases (case-insensitive, anchored to avoid mid-task false positives)
	if echo "$USER_PROMPT" | grep -qiE "(let'?s wrap up$|let'?s finish up$|i think we'?re done|that'?s it for today|that'?s all for now|i'?m wrapping up$|i'?m done for now|end of session|call it a day|that'?s everything|good stopping point|let'?s stop here)"; then
		NEW_COUNT=$(count_new_memory)
		if [ "$NEW_COUNT" -ge 1 ]; then
			TRIGGER="wrapup"
			touch "$WRAPUP_CACHE" 2>/dev/null
		fi
	fi
fi

# ── Trigger 2: Accumulated memory (SessionStart only) ──

if [ "$EVENT" = "SessionStart" ]; then
	# Only fire on startup, clear, or compact - not resume
	SESSION_TYPE=$(echo "$INPUT" | jq -r '.source // ""')
	if [ "$SESSION_TYPE" = "resume" ]; then
		exit 0
	fi

	NEW_COUNT=$(count_new_memory)
	if [ "$NEW_COUNT" -ge 3 ]; then
		TRIGGER="memory"
	fi
fi

# ── Trigger 3: Low context with new memory (PostToolUse only) ──

if [ "$EVENT" = "PostToolUse" ]; then
	CONTEXT_THRESHOLD=30

	# Read bridge file written by statusline hook
	BRIDGE_FILE="/tmp/claude-ctx-${SESSION_ID}.json"
	[ ! -f "$BRIDGE_FILE" ] && exit 0

	# Check staleness (ignore metrics older than 60s)
	BRIDGE_TS=$(jq -r '.timestamp // 0' "$BRIDGE_FILE" 2>/dev/null)
	NOW=$(date +%s)
	if [ $((NOW - BRIDGE_TS)) -gt 60 ]; then
		exit 0
	fi

	REMAINING=$(jq -r '.remaining_percentage // 100' "$BRIDGE_FILE" 2>/dev/null)

	# Guard against non-numeric values
	[[ "$REMAINING" =~ ^[0-9]+$ ]] || exit 0

	# Only fire at or below threshold
	if [ "$REMAINING" -gt "$CONTEXT_THRESHOLD" ] 2>/dev/null; then
		exit 0
	fi

	# Debounce: 5 tool calls between prompts
	DEBOUNCE_FILE="/tmp/claude-memory-ctx-debounce-${SESSION_ID}"
	CALLS_SINCE=0
	if [ -f "$DEBOUNCE_FILE" ]; then
		CALLS_SINCE=$(cat "$DEBOUNCE_FILE" 2>/dev/null || echo "0")
	fi
	CALLS_SINCE=$((CALLS_SINCE + 1))
	echo "$CALLS_SINCE" > "$DEBOUNCE_FILE" 2>/dev/null

	# First time at threshold fires immediately, then every 5 calls
	if [ "$CALLS_SINCE" -gt 1 ] && [ $((CALLS_SINCE % 5)) -ne 0 ]; then
		exit 0
	fi

	# Only prompt if there's actually new memory to review
	NEW_COUNT=$(count_new_memory)
	if [ "$NEW_COUNT" -lt 3 ]; then
		exit 0
	fi

	# Rate limit: only fire once per session for context trigger
	CTX_PROMPTED="/tmp/claude-memory-ctx-prompted-${SESSION_ID}"
	[ -f "$CTX_PROMPTED" ] && exit 0

	TRIGGER="context"
	touch "$CTX_PROMPTED" 2>/dev/null
fi

# ── Nothing to review ──

[ -z "$TRIGGER" ] && exit 0

MEMORY_COUNT=$(find "$MEMORY_DIR" -name '*.md' -not -name 'MEMORY.md' 2>/dev/null | wc -l | tr -d ' ')

case "$TRIGGER" in
	memory)
		echo "Auto-memory has ${NEW_COUNT} new topic files since last review. Run /review-memory to review, promote, and clean up."
		;;
	context)
		echo "Context is getting low and there are ${NEW_COUNT} new memory topic files to review. Run /review-memory --compact before this session ends to avoid losing unreviewed learnings."
		;;
	wrapup)
		echo "Wrapping up with ${NEW_COUNT} unreviewed memory topic files. Run /review-memory to review, promote, and clean up before ending."
		;;
esac

exit 0
