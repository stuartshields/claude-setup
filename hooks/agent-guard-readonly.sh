#!/bin/bash
# Agent hook: blocks destructive/write commands for read-only agents.
# Used by: code-reviewer agent (PreToolUse on Bash)
#
# Reads JSON from stdin (Claude Code hook contract), extracts .tool_input.command.
# Exit 2 = block the tool call.

command=$(jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$command" ] && exit 0

pattern='^\s*(rm|mv|cp|chmod|chown|git\s+(commit|push|reset|checkout|merge|rebase|branch\s+-[dD])|npm\s+(publish|install)|pnpm\s+(publish|install)|yarn\s+(publish|add))'
if echo "$command" | grep -qiE "$pattern"; then
	echo "BLOCKED: code-reviewer is read-only. Destructive or write commands are not permitted." >&2
	exit 2
fi
