#!/bin/bash
# Agent hook: blocks Write/Edit when content exceeds 50 lines.
# Used by: quick-edit agent (PreToolUse on Write|Edit)
#
# Exit 2 = block the tool call.

TOOL_INPUT="${TOOL_INPUT:-}"

line_count=$(echo "$TOOL_INPUT" | grep -c '')
if [ "$line_count" -gt 50 ]; then
	echo "BLOCKED: Edit exceeds 50 lines ($line_count lines). Escalate to a sonnet agent."
	exit 2
fi
