#!/bin/bash
# PostToolUse hook for Read. When the file uses tab indentation, inject a
# context reminder explaining the N\t separator in Read output, so Claude
# uses one fewer leading tab when constructing old_string for Edit.
# Advisory only - exit 0 always.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Detect tab indentation: any non-empty line starts with a literal tab
# in first 200 lines (cheap probe; full-file scan is unnecessary).
if head -200 "$FILE_PATH" 2>/dev/null | grep -q $'^\t'; then
	jq -n --arg path "$FILE_PATH" '{
		hookSpecificOutput: {
			hookEventName: "PostToolUse",
			additionalContext: ("Tab-indented file (\($path)). Read output uses `N\\t` as the line-number separator - this is a tab too. When constructing `old_string` for Edit, use one fewer leading tab than the raw Read output shows.")
		}
	}'
fi

exit 0
