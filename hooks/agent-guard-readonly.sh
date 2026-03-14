#!/bin/bash
# Agent hook: blocks destructive/write commands for read-only agents.
# Used by: code-reviewer agent (PreToolUse on Bash)
#
# Checks TOOL_INPUT against a pattern of destructive commands.
# Exit 2 = block the tool call.

TOOL_INPUT="${TOOL_INPUT:-}"

pattern='^\s*(rm|mv|cp|chmod|chown|git\s+(commit|push|reset|checkout|merge|rebase|branch\s+-[dD])|npm\s+(publish|install)|pnpm\s+(publish|install)|yarn\s+(publish|add))'
if echo "$TOOL_INPUT" | grep -qiE "$pattern"; then
	echo "BLOCKED: code-reviewer is read-only. Destructive or write commands are not permitted."
	exit 2
fi
