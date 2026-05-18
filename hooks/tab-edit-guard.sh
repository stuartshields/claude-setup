#!/bin/bash
# PreToolUse hook for Edit. Detects indent-style mismatch between the
# target file and old_string. Exits 2 with corrective feedback so Claude
# retries with the right indentation rather than the Edit failing silently.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
OLD_STRING=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""')

[ -z "$FILE_PATH" ] && exit 0
[ -z "$OLD_STRING" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Detect file's indent style (first 200 lines).
FILE_TABS=$(head -200 "$FILE_PATH" 2>/dev/null | grep -c $'^\t')
FILE_SPACES=$(head -200 "$FILE_PATH" 2>/dev/null | grep -cE '^ +[^ ]')

# Detect old_string's indent style.
OLD_TABS=$(printf '%s' "$OLD_STRING" | grep -c $'^\t')
OLD_SPACES=$(printf '%s' "$OLD_STRING" | grep -cE '^ +[^ ]')

# Pass through if either side has no indented lines (boundary case: single-line
# content or old_string that starts at first non-whitespace character).
[ "$FILE_TABS" -eq 0 ] && [ "$FILE_SPACES" -eq 0 ] && exit 0
[ "$OLD_TABS" -eq 0 ] && [ "$OLD_SPACES" -eq 0 ] && exit 0

# Pass through if file has mixed indent (smart-tabs are valid; ambiguous to
# call this a mismatch).
[ "$FILE_TABS" -gt 0 ] && [ "$FILE_SPACES" -gt 0 ] && exit 0

# Mismatch 1: file uses tabs, old_string uses only spaces.
if [ "$FILE_TABS" -gt 0 ] && [ "$OLD_SPACES" -gt 0 ] && [ "$OLD_TABS" -eq 0 ]; then
	echo "BLOCKED: Indent mismatch - $FILE_PATH uses tabs, but old_string uses spaces." >&2
	echo "Re-read the file and rebuild old_string using literal tab characters. Remember the Read output prefixes each line with the line number plus a tab separator - count one fewer leading tab." >&2
	exit 2
fi

# Mismatch 2: file uses spaces, old_string uses only tabs.
if [ "$FILE_SPACES" -gt 0 ] && [ "$OLD_TABS" -gt 0 ] && [ "$OLD_SPACES" -eq 0 ]; then
	echo "BLOCKED: Indent mismatch - $FILE_PATH uses spaces, but old_string uses tabs." >&2
	echo "Re-read the file and use literal space characters in old_string." >&2
	exit 2
fi

exit 0
