#!/bin/bash
# Block git commit commands from being run via the Bash tool.
# PreToolUse hook — receives JSON on stdin, exit 2 to block.

command=$(jq -r '.tool_input.command // empty' 2>/dev/null)

# Match: git commit, git -C ... commit, node ... commit (gsd-tools commit)
if [[ "$command" =~ git[[:space:]]+(.*[[:space:]]+)?commit ]] || \
   [[ "$command" =~ gsd-tools[^[:space:]]*[[:space:]]+commit ]]; then
	echo "BLOCKED: Git commits are disabled. Stage your changes manually and commit when ready." >&2
	exit 2
fi

exit 0
