#!/bin/bash
# Agent hook: blocks Write/Edit tools entirely for read-only agents.
# Used by: code-reviewer agent (PreToolUse on Write|Edit)
#
# Exit 2 = block the tool call.

echo "BLOCKED: code-reviewer is read-only. Write and Edit tools are not permitted." >&2
exit 2
