#!/bin/bash
# Auto-approve all tool calls when working under ~/Personal/.
# Excludes project-claude-setup — stakes are higher there (global Claude config).
# PreToolUse hook — emits permissionDecision JSON to skip the approval prompt.

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

[ -z "$CWD" ] && CWD="${CLAUDE_PROJECT_DIR:-$PWD}"

case "$CWD" in
	"$HOME/Personal/project-claude-setup"*) exit 0 ;;
	"$HOME/Personal/"*) ;;
	*) exit 0 ;;
esac

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Personal project auto-approve"}}
JSON
