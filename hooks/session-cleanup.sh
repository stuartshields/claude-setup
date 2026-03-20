#!/bin/bash
# SessionEnd hook - cleans up temp files for this session.

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
	"/tmp/claude-task-state-mismatch-${SESSION_ID}.txt" \
	"/tmp/claude-task-mismatch-prompt-${SESSION_ID}.ts" \
	"/tmp/claude-task-prompt-${SESSION_ID}.state" \
	"/tmp/claude-drift-${SESSION_ID}" \
	"/tmp/claude-drift-reviewed-${SESSION_ID}" \
	"/tmp/claude-compacted-${SESSION_ID}" \
	"/tmp/claude-perf-${SESSION_ID}.log" \
	"/tmp/claude-verify-advisory-${SESSION_ID}.state" \
	"/tmp/claude-quality-checked-${SESSION_ID}" 2>/dev/null

if [ -n "$PROJECT_HASH" ]; then
	rm -f "/tmp/claude-remind-${PROJECT_HASH}-${SESSION_ID}.state" 2>/dev/null
fi

# Rotate hooks.log to prevent unbounded growth (issue #16047)
HOOKS_LOG="$HOME/.claude/hooks.log"
if [ -f "$HOOKS_LOG" ]; then
	LOG_SIZE=$(wc -c < "$HOOKS_LOG" 2>/dev/null | tr -d ' ')
	# Rotate if larger than 512KB
	if [ "${LOG_SIZE:-0}" -gt 524288 ]; then
		# Keep last 200 lines for debugging, discard the rest
		tail -200 "$HOOKS_LOG" > "${HOOKS_LOG}.tmp" 2>/dev/null && \
			mv "${HOOKS_LOG}.tmp" "$HOOKS_LOG" 2>/dev/null
	fi
fi

exit 0
