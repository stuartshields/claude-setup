#!/bin/bash
# PostToolUse hook (Edit|Write): detects write-revert-rewrite oscillation.
# Tracks file content hashes. If a file returns to a previous state, flags it.
# Replaces prose rule: "Watch for write-delete-rewrite."
# Advisory only (exit 0).

TOOL_NAME=$(jq -r '.tool_name // ""')
FILE_PATH=$(jq -r '.tool_input.file_path // ""')

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
HASH_DIR="/tmp/claude-file-hashes-${SESSION_ID}"
mkdir -p "$HASH_DIR"

# Sanitise file path for use as filename
SAFE_NAME=$(echo "$FILE_PATH" | sed 's/[\/:]/_/g')
HASH_FILE="${HASH_DIR}/${SAFE_NAME}"

# Get current file hash
CURRENT_HASH=$(md5 -q "$FILE_PATH" 2>/dev/null || md5sum "$FILE_PATH" 2>/dev/null | cut -d' ' -f1)

[ -z "$CURRENT_HASH" ] && exit 0

# Check if we've seen this hash before (excluding the most recent entry)
if [ -f "$HASH_FILE" ]; then
	# Count how many times this hash appears in history (excluding last line)
	HISTORY_COUNT=$(sed '$d' "$HASH_FILE" 2>/dev/null | grep -c "^${CURRENT_HASH}$" || echo "0")

	if [ "$HISTORY_COUNT" -gt 0 ]; then
		echo "OSCILLATION WARNING: $(basename "$FILE_PATH") has returned to a previous state. You are writing, reverting, and rewriting — this is a loop, not iteration. Stop. Identify the conflicting constraints and surface them to the user."
	fi
fi

# Append current hash to history
echo "$CURRENT_HASH" >> "$HASH_FILE"

exit 0
