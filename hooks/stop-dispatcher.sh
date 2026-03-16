#!/bin/bash
# Stop hook dispatcher -- runs all Stop checks in a single hook entry.
# Replaces 4 separate stop-wrapper.sh invocations with one script.
# Buffers stdin once and replays to each sub-hook.
# Aggregates: if any sub-hook blocks, the dispatcher blocks.
# Policy: Stop is block-only. Advisory messages are surfaced via UserPromptSubmit.

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
STDIN_DATA=$(cat)

# Official loop-prevention: skip if Claude is already in forced-continuation mode
if echo "$STDIN_DATA" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
	echo '{"decision":"approve"}'
	exit 0
fi

BLOCK_OUTPUT=""

# Sub-hooks to run in order
HOOKS=(
	"check-unfinished-tasks.sh"
	"drift-review-stop.sh"
	"stop-quality-check.sh"
)

for hook in "${HOOKS[@]}"; do
	HOOK_PATH="${HOOK_DIR}/${hook}"
	[ ! -x "$HOOK_PATH" ] && continue

	# Run sub-hook: capture both stdout and stderr for reason extraction
	OUTPUT=$(echo "$STDIN_DATA" | "$HOOK_PATH" 2>&1)
	EXIT_CODE=$?

	# Skip empty output with clean exit
	[ -z "$OUTPUT" ] && [ "$EXIT_CODE" -eq 0 ] && continue

	# Check for block signal: exit code 2 OR JSON decision:block
	IS_BLOCK=false
	if [ "$EXIT_CODE" -eq 2 ]; then
		IS_BLOCK=true
	elif echo "$OUTPUT" | jq -e '.decision == "block"' >/dev/null 2>&1; then
		IS_BLOCK=true
	fi

	if [ "$IS_BLOCK" = true ]; then
		# Extract or build reason, prepend hook name
		if echo "$OUTPUT" | jq -e . >/dev/null 2>&1; then
			REASON=$(echo "$OUTPUT" | jq -r '.reason // "Blocked by hook"')
			BLOCK_OUTPUT=$(jq -n --arg reason "[$hook] $REASON" '{"decision":"block","reason":$reason}')
		else
			BLOCK_OUTPUT=$(jq -n --arg reason "[$hook] $OUTPUT" '{"decision":"block","reason":$reason}')
		fi
	fi
done

# Output result
if [ -n "$BLOCK_OUTPUT" ]; then
	echo "$BLOCK_OUTPUT"
else
	echo '{"decision":"approve"}'
fi

exit 0
