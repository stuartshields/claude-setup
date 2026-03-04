#!/bin/bash
# PostToolUse hook (Write|Edit): tracks files modified during this session.
# Consumed by drift-review-stop.sh (Stop) and compact-restore.sh (compaction checkpoint).

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[ -z "$SESSION_ID" ] && exit 0

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
[ -z "$FILE_PATH" ] && exit 0

TRACK_FILE="/tmp/claude-drift-${SESSION_ID}"

# Deduplicate — only append if not already tracked
grep -qxF "$FILE_PATH" "$TRACK_FILE" 2>/dev/null || echo "$FILE_PATH" >> "$TRACK_FILE"

exit 0
