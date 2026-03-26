#!/bin/bash
# PreToolUse hook (Bash): blocks when the same command is run 4+ times in a row.
# Empty output from linters/tests means success — re-running is a loop.

COMMAND=$(jq -r '.tool_input.command // ""')

[ -z "$COMMAND" ] && exit 0

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
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
		exit 2
	fi
else
	echo "0" > "$REPEAT_FILE"
fi

echo "$COMMAND" > "$LAST_CMD_FILE"
exit 0
