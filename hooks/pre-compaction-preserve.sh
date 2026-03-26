#!/bin/bash
# PreCompact hook — saves project state to /tmp before compaction.
# The SessionStart compact hook reads this file to restore context.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$CWD" ] || [ ! -d "$CWD" ] && exit 0

cd "$CWD" || exit 0

OUTFILE="/tmp/claude-precompact-${SESSION_ID}.txt"
RESTORE=""

# Find project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# 1. Project CLAUDE.md (first 50 lines)
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
[ ! -f "$CLAUDE_MD" ] && CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
	SUMMARY=$(head -50 "$CLAUDE_MD")
	RESTORE="${RESTORE}PROJECT CLAUDE.md (first 50 lines):\n${SUMMARY}\n\n"
fi

# 2. Project state
STATE_MD="$PROJECT_ROOT/.planning/STATE.md"
if [ -f "$STATE_MD" ]; then
	RESTORE="${RESTORE}PROJECT STATE.md:\n$(cat "$STATE_MD")\n\n"
fi

# 3. Uncommitted changes
if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	CHANGED=$(git -C "$PROJECT_ROOT" diff --name-only 2>/dev/null)
	STAGED=$(git -C "$PROJECT_ROOT" diff --cached --name-only 2>/dev/null)
	if [ -n "$CHANGED" ] || [ -n "$STAGED" ]; then
		RESTORE="${RESTORE}UNCOMMITTED CHANGES:\n"
		[ -n "$STAGED" ] && RESTORE="${RESTORE}Staged: ${STAGED}\n"
		[ -n "$CHANGED" ] && RESTORE="${RESTORE}Modified: ${CHANGED}\n"
		RESTORE="${RESTORE}\n"
	fi

	# 4. Recent commits
	RECENT=$(git -C "$PROJECT_ROOT" log --oneline -3 2>/dev/null)
	[ -n "$RECENT" ] && RESTORE="${RESTORE}RECENT COMMITS:\n${RECENT}\n\n"
fi

# 5. Build/test commands
if [ -f "$PROJECT_ROOT/package.json" ]; then
	BUILD=$(jq -r '.scripts.build // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	TEST=$(jq -r '.scripts.test // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	LINT=$(jq -r '.scripts.lint // empty' "$PROJECT_ROOT/package.json" 2>/dev/null)
	if [ -n "$BUILD" ] || [ -n "$TEST" ] || [ -n "$LINT" ]; then
		RESTORE="${RESTORE}PROJECT COMMANDS:"
		[ -n "$BUILD" ] && RESTORE="${RESTORE} build='${BUILD}'"
		[ -n "$TEST" ] && RESTORE="${RESTORE} test='${TEST}'"
		[ -n "$LINT" ] && RESTORE="${RESTORE} lint='${LINT}'"
		RESTORE="${RESTORE}\n"
	fi
elif [ -f "$PROJECT_ROOT/go.mod" ]; then
	RESTORE="${RESTORE}PROJECT COMMANDS: build='go build' test='go test ./...' vet='go vet ./...'\n"
elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
	RESTORE="${RESTORE}PROJECT COMMANDS: build='cargo build' test='cargo test' check='cargo check'\n"
elif [ -f "$PROJECT_ROOT/deno.json" ] || [ -f "$PROJECT_ROOT/deno.jsonc" ]; then
	RESTORE="${RESTORE}PROJECT COMMANDS: test='deno test' lint='deno lint'\n"
fi

printf "%b" "$RESTORE" > "$OUTFILE"
exit 0
