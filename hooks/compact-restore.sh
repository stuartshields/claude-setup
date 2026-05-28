#!/bin/bash
# SessionStart compact hook — reads PreCompact saved state if available,
# otherwise rebuilds context from filesystem.

source "$(dirname "${BASH_SOURCE[0]}")/restore-context-lib.sh"

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

RESTORE=$(build_restore_context "$PROJECT_ROOT")
[ -n "$RESTORE" ] && printf "POST-COMPACTION CONTEXT RESTORE:\n%b" "$RESTORE"
exit 0
