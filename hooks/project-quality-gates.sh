#!/bin/bash
# PostToolUse hook: detects project quality commands and reminds the agent to run them.
# Advisory only - never blocks. Rate-limited to once per 60 seconds.

CACHE_FILE="/tmp/claude-quality-gates-last"

# Rate limit: skip if we ran within the last 60 seconds
if [ -f "$CACHE_FILE" ]; then
	LAST_RUN=$(cat "$CACHE_FILE" 2>/dev/null || echo 0)
	NOW=$(date +%s)
	if (( NOW - LAST_RUN < 60 )); then
		exit 0
	fi
fi

# Parse stdin for cwd
CWD=$(jq -r '.cwd // ""')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
	exit 0
fi

# Find project root
PROJECT_ROOT=$(cd "$CWD" && git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

GATES=""

# Check package.json for quality scripts
PKG="$PROJECT_ROOT/package.json"
if [ -f "$PKG" ]; then
	# Single jq call to check all script names at once
	SCRIPTS=$(jq -r '.scripts // {} | keys[]' "$PKG" 2>/dev/null)
	if [ -n "$SCRIPTS" ]; then
		for SCRIPT in lint typecheck type-check tsc check test test:unit; do
			if [[ "$SCRIPTS" =~ (^|$'\n')$SCRIPT($'\n'|$) ]]; then
				GATES="${GATES:+$GATES, }npm run $SCRIPT"
			fi
		done
	fi
fi

# Check for config files that imply available tools
if [ -z "$GATES" ] || [[ ! "$GATES" =~ "tsc" ]]; then
	if [ -f "$PROJECT_ROOT/tsconfig.json" ]; then
		GATES="${GATES:+$GATES, }npx tsc --noEmit"
	fi
fi

if [[ ! "$GATES" =~ "lint" ]]; then
	for PATTERN in "$PROJECT_ROOT/.eslintrc"* "$PROJECT_ROOT/eslint.config"*; do
		if [ -f "$PATTERN" ]; then
			GATES="${GATES:+$GATES, }npx eslint ."
			break
		fi
	done
fi

if [ -f "$PROJECT_ROOT/biome.json" ]; then
	GATES="${GATES:+$GATES, }npx biome check ."
fi

# Nothing detected - exit silently
if [ -z "$GATES" ]; then
	exit 0
fi

# Update rate limit cache
date +%s > "$CACHE_FILE"

# Output advisory context
echo "{\"additionalContext\": \"Quality gates available: $GATES. Run these before finishing.\"}"
exit 0
