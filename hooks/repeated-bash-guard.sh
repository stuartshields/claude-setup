#!/bin/bash
# PreToolUse hook (Bash): warns when the same command is run 4+ times in a row.
# Empty output from linters/tests means success — re-running is a loop.
# Advisory only (exit 0). Blocking via exit 2 hits anthropics/claude-code#24327
# where Claude stops responding instead of acting on the feedback.

INPUT=$(cat)
COMMAND=$(jq -r '.tool_input.command // ""' <<<"$INPUT")

[ -z "$COMMAND" ] && exit 0

# Prefer stdin session_id (canonical); fall back to CLAUDE_CODE_SESSION_ID env var (2.1.132+).
SESSION_ID=$(jq -r '.session_id // ""' <<<"$INPUT")
SESSION_ID="${SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-unknown}}"
LAST_CMD_FILE="/tmp/claude-last-bash-${SESSION_ID}"
REPEAT_FILE="/tmp/claude-bash-repeat-${SESSION_ID}"

LAST_CMD=""
[ -f "$LAST_CMD_FILE" ] && LAST_CMD=$(cat "$LAST_CMD_FILE")

if [ "$COMMAND" = "$LAST_CMD" ]; then
	REPEATS=$(cat "$REPEAT_FILE" 2>/dev/null || echo "0")
	REPEATS=$((REPEATS + 1))
	echo "$REPEATS" > "$REPEAT_FILE"

	if [ "$REPEATS" -ge 3 ]; then
		echo "PERF WARNING: You are re-running the same Bash command. Empty output from linters means success. If you expected different output, vary your approach (add --verbose, check pwd, inspect exit code) — do not re-run identically."
	fi
else
	echo "0" > "$REPEAT_FILE"
fi

echo "$COMMAND" > "$LAST_CMD_FILE"
exit 0
