#!/bin/bash
# Shared helper for the compaction hooks.
# build_restore_context <project_root> assembles the post-compaction restore
# block (CLAUDE.md head, uncommitted changes, recent commits, build/test
# commands) and prints it to stdout. Callers expand it with `printf "%b"`.
# Sourced by pre-compaction-preserve.sh and compact-restore.sh.

build_restore_context() {
	local PROJECT_ROOT="$1"
	local RESTORE=""

	# 1. Project CLAUDE.md (first 50 lines)
	local CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
	[ ! -f "$CLAUDE_MD" ] && CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
	if [ -f "$CLAUDE_MD" ]; then
		RESTORE="${RESTORE}PROJECT CLAUDE.md (first 50 lines):\n$(head -50 "$CLAUDE_MD")\n\n"
	fi

	# 2. Uncommitted changes + 3. Recent commits
	if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		local CHANGED STAGED RECENT
		CHANGED=$(git -C "$PROJECT_ROOT" diff --name-only 2>/dev/null)
		STAGED=$(git -C "$PROJECT_ROOT" diff --cached --name-only 2>/dev/null)
		if [ -n "$CHANGED" ] || [ -n "$STAGED" ]; then
			RESTORE="${RESTORE}UNCOMMITTED CHANGES:\n"
			[ -n "$STAGED" ] && RESTORE="${RESTORE}Staged: ${STAGED}\n"
			[ -n "$CHANGED" ] && RESTORE="${RESTORE}Modified: ${CHANGED}\n"
			RESTORE="${RESTORE}\n"
		fi

		RECENT=$(git -C "$PROJECT_ROOT" log --oneline -3 2>/dev/null)
		[ -n "$RECENT" ] && RESTORE="${RESTORE}RECENT COMMITS:\n${RECENT}\n\n"
	fi

	# 4. Build/test commands
	if [ -f "$PROJECT_ROOT/package.json" ]; then
		local BUILD TEST LINT
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

	printf '%s' "$RESTORE"
}
