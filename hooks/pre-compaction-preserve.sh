#!/bin/bash
# PreCompact hook — saves project state to /tmp before compaction.
# The SessionStart compact hook reads this file to restore context.

source "$(dirname "${BASH_SOURCE[0]}")/restore-context-lib.sh"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$CWD" ] || [ ! -d "$CWD" ] && exit 0

cd "$CWD" || exit 0

OUTFILE="/tmp/claude-precompact-${SESSION_ID}.txt"
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

RESTORE=$(build_restore_context "$PROJECT_ROOT")
printf "%b" "$RESTORE" > "$OUTFILE"
exit 0
