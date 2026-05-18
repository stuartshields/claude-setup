#!/bin/bash
# PreToolUse hook for Bash. When sed/awk/perl/tr is about to operate on a
# tab-indented file, inject an advisory suggesting Edit instead.
# Advisory only - exit 0 always.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
[ -z "$COMMAND" ] && exit 0

# Only fire for text-mangling commands.
case "$COMMAND" in
	*sed[[:space:]]*|*awk[[:space:]]*|*perl[[:space:]]*|*tr[[:space:]]*) ;;
	*) exit 0 ;;
esac

# Scan tokens for an existing file path with tab indentation.
TAB_FILE=""
read -r -a TOKENS <<<"$COMMAND"
for TOKEN in "${TOKENS[@]}"; do
	FILE=${TOKEN#\"}
	FILE=${FILE%\"}
	FILE=${FILE#\'}
	FILE=${FILE%\'}
	[ -f "$FILE" ] || continue
	if head -100 "$FILE" 2>/dev/null | grep -q $'^\t'; then
		TAB_FILE="$FILE"
		break
	fi
done

[ -z "$TAB_FILE" ] && exit 0

jq -n --arg file "$TAB_FILE" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		additionalContext: ("Tab-indented file detected (\($file)). Prefer the Edit tool over sed/awk/perl/tr for indented files - text tools can mangle indentation. Re-read the file and use Edit instead.")
	}
}'

exit 0
