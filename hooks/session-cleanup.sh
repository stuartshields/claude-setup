#!/bin/bash
# SessionEnd hook — cleans up temp files for this session.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

PROJECT_HASH=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
	PROJECT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
	PROJECT_HASH=$(echo "$PROJECT_ROOT" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "$PROJECT_ROOT" | md5 2>/dev/null | cut -d' ' -f1 || echo "")
fi

rm -f "/tmp/claude-ctx-${SESSION_ID}"*.json \
	"/tmp/claude-precompact-${SESSION_ID}.txt" \
	"/tmp/claude-tasks-${SESSION_ID}.json" \
	"/tmp/claude-task-stop-${SESSION_ID}.count" \
	"/tmp/claude-drift-${SESSION_ID}" \
	"/tmp/claude-drift-reviewed-${SESSION_ID}" \
	"/tmp/claude-compacted-${SESSION_ID}" 2>/dev/null

if [ -n "$PROJECT_HASH" ]; then
	rm -f "/tmp/claude-remind-${PROJECT_HASH}" 2>/dev/null
fi

exit 0
