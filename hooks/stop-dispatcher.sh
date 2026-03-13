#!/bin/bash
# Stop hook dispatcher -- runs all Stop checks in a single hook entry.
# Replaces 4 separate stop-wrapper.sh invocations with one script.
# Buffers stdin once and replays to each sub-hook.
# Aggregates: if any sub-hook blocks, the dispatcher blocks.
# Policy: Stop is block-only. Advisory messages are surfaced via UserPromptSubmit.

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
STDIN_DATA=$(cat)

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

	# Run sub-hook: stderr passes through, stdout captured
	OUTPUT=$(echo "$STDIN_DATA" | "$HOOK_PATH" 2>&2)
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
		# Ensure output is valid JSON
		if echo "$OUTPUT" | jq -e . >/dev/null 2>&1; then
			[ -z "$BLOCK_OUTPUT" ] && BLOCK_OUTPUT="$OUTPUT"
		else
			# Non-JSON blocking output -- wrap it
			WRAPPED=$(jq -n --arg reason "$OUTPUT" '{"decision":"block","reason":$reason}' 2>/dev/null)
			[ -z "$BLOCK_OUTPUT" ] && BLOCK_OUTPUT="${WRAPPED:-"{\"decision\":\"block\"}"}"
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
