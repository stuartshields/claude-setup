#!/bin/bash
# SessionEnd hook — cleans up temp files for this session.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

rm -f "/tmp/claude-ctx-${SESSION_ID}"*.json \
	"/tmp/claude-precompact-${SESSION_ID}.txt" \
	"/tmp/claude-tasks-${SESSION_ID}.json" \
	"/tmp/claude-task-stop-${SESSION_ID}.count" \
	"/tmp/claude-drift-${SESSION_ID}" \
	"/tmp/claude-drift-reviewed-${SESSION_ID}" \
	"/tmp/claude-compacted-${SESSION_ID}" \
	/tmp/claude-remind-* 2>/dev/null

exit 0
