#!/bin/bash
# Agent hook: blocks Write/Edit when content exceeds 50 lines.
# Used by: quick-edit agent (PreToolUse on Write|Edit)
#
# Reads JSON from stdin (Claude Code hook contract).
# Write uses .tool_input.content, Edit uses .tool_input.new_string.
# Exit 2 = block the tool call.

TMPINPUT=$(mktemp)
cat > "$TMPINPUT"
trap 'rm -f "$TMPINPUT"' EXIT

TOOL=$(jq -r '.tool_name // empty' < "$TMPINPUT" 2>/dev/null)

case "$TOOL" in
	Write) content=$(jq -r '.tool_input.content // empty' < "$TMPINPUT") ;;
	Edit)  content=$(jq -r '.tool_input.new_string // empty' < "$TMPINPUT") ;;
	*)     exit 0 ;;
esac

[ -z "$content" ] && exit 0

line_count=$(echo "$content" | wc -l)
if [ "$line_count" -gt 50 ]; then
	echo "BLOCKED: Edit exceeds 50 lines ($line_count lines). Escalate to a sonnet agent." >&2
	exit 2
fi
