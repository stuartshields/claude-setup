#!/bin/bash
# UserPromptSubmit hook: Injects project CLAUDE.md context before every prompt.
# Ensures Claude always has the project's source of truth loaded and flags divergence.

# Read only .cwd from stdin — avoid buffering full payload (screenshots = multi-MB base64)
CWD=$(jq -r '.cwd // ""')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
	exit 0
fi

cd "$CWD" || exit 0

# Find project root (git root or cwd)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# Check for CLAUDE.md at project root
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
	# Also check .claude/CLAUDE.md
	CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"
	if [ ! -f "$CLAUDE_MD" ]; then
		exit 0
	fi
fi

# Skip if we're in the global .claude directory itself (not a project)
case "$PROJECT_ROOT" in
	*/.claude) exit 0 ;;
esac

# --- Cache check FIRST (before expensive git/stat calls) ---
# macOS: printf '%s' | md5 outputs just the 32-char hex hash (no filename prefix)
PROJECT_HASH=$(printf '%s' "$PROJECT_ROOT" | md5)
CACHE_FILE="/tmp/claude-remind-${PROJECT_HASH}"

# If cache file was written in the last 30 seconds, skip entirely.
# The message can only change if CLAUDE.md was modified or files were committed,
# neither of which happens multiple times within 30 seconds.
if [ -f "$CACHE_FILE" ]; then
	CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
	if [ "$CACHE_AGE" -lt 30 ]; then
		exit 0
	fi
fi

# --- Cache miss or stale: compute full message ---

# Get file age in days
if command -v stat >/dev/null 2>&1; then
	MODIFIED=$(stat -f %m "$CLAUDE_MD" 2>/dev/null || echo 0)
	NOW=$(date +%s)
	AGE_DAYS=$(( (NOW - MODIFIED) / 86400 ))
else
	AGE_DAYS=0
fi

# Count uncommitted changed files to gauge session activity
CHANGED_FILES=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	CHANGED_FILES=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
fi

# Build context message
MSG="PROJECT CLAUDE.md ACTIVE: $CLAUDE_MD"

if [ "$AGE_DAYS" -gt 7 ]; then
	MSG="$MSG | STALE ($AGE_DAYS days old) — consider updating after this task."
fi

if [ "$CHANGED_FILES" -gt 5 ]; then
	MSG="$MSG | $CHANGED_FILES files changed this session — if architecture decisions were made, update CLAUDE.md."
fi

MSG="$MSG | RULE: If your changes diverge from what CLAUDE.md specifies, ask the user: 'This differs from the project CLAUDE.md — should I update it first?'"

# Check if message content changed since last injection
# macOS: printf '%s' | md5 outputs just the 32-char hex hash
MSG_HASH=$(printf '%s' "$MSG" | md5)

if [ -s "$CACHE_FILE" ] && [ "$(cat "$CACHE_FILE" 2>/dev/null)" = "$MSG_HASH" ]; then
	# Same message as last prompt — update cache timestamp but skip injection
	touch "$CACHE_FILE"
	exit 0
fi

# New or changed message — inject and update cache
echo "$MSG_HASH" > "$CACHE_FILE" 2>/dev/null
echo "$MSG"
exit 0
