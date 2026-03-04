#!/bin/bash
# Stop hook: blocks Claude from finishing if the project build/test is broken.
# Only runs when there are uncommitted changes (i.e. Claude edited something).

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
	exit 0
fi

cd "$CWD" || exit 0

# Skip if not a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	exit 0
fi

# Skip if no uncommitted changes (nothing was edited)
if git diff --quiet && git diff --cached --quiet 2>/dev/null; then
	exit 0
fi

# Check if CLAUDE.md needs updating (non-blocking — stdout hint, not stderr block)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
	CHANGED_COUNT=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
	if [ "$CHANGED_COUNT" -gt 3 ]; then
		echo "CLAUDE.md CHECK: $CHANGED_COUNT files changed this session. Review if project CLAUDE.md needs updating with new patterns or decisions."
	fi
fi

# Detect and run the project's build command
if [ -f "package.json" ]; then
	# Check for common build scripts
	HAS_BUILD=$(jq -r '.scripts.build // empty' package.json 2>/dev/null)
	if [ -n "$HAS_BUILD" ]; then
		# Detect package manager
		if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
			PM="bun"
		elif [ -f "pnpm-lock.yaml" ]; then
			PM="pnpm"
		elif [ -f "yarn.lock" ]; then
			PM="yarn"
		else
			PM="npm"
		fi

		BUILD_CMD="$PM run build"
	fi
elif [ -f "Makefile" ]; then
	BUILD_CMD="make"
elif [ -f "Cargo.toml" ]; then
	BUILD_CMD="cargo check"
elif [ -f "go.mod" ]; then
	BUILD_CMD="go build ./..."
elif [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
	BUILD_CMD="deno check **/*.ts"
fi

# Run build with 30s timeout
if [ -n "$BUILD_CMD" ]; then
	if command -v gtimeout >/dev/null 2>&1; then
		BUILD_OUTPUT=$(gtimeout 30 $BUILD_CMD 2>&1)
		BUILD_EXIT=$?
	elif command -v timeout >/dev/null 2>&1; then
		BUILD_OUTPUT=$(timeout 30 $BUILD_CMD 2>&1)
		BUILD_EXIT=$?
	else
		BUILD_OUTPUT=$($BUILD_CMD 2>&1)
		BUILD_EXIT=$?
	fi

	if [ $BUILD_EXIT -eq 124 ]; then
		echo "BUILD WARNING: Build timed out after 30s ($BUILD_CMD). Run manually to verify."
	elif [ $BUILD_EXIT -ne 0 ]; then
		echo "BUILD WARNING: Build failed ($BUILD_CMD). Fix errors before deploying."
		echo ""
		echo "$BUILD_OUTPUT" | tail -30
	fi
fi

# --- Test runner detection (non-blocking — warn only) ---

TEST_CMD=""
TEST_PM="${PM:-npm}"

if [ -f "package.json" ]; then
	HAS_TEST=$(jq -r '.scripts.test // empty' package.json 2>/dev/null)
	if [ -n "$HAS_TEST" ] && [ "$HAS_TEST" != "echo \"Error: no test specified\" && exit 1" ]; then
		# Detect package manager if not set from build step
		if [ -z "$PM" ]; then
			if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
				TEST_PM="bun"
			elif [ -f "pnpm-lock.yaml" ]; then
				TEST_PM="pnpm"
			elif [ -f "yarn.lock" ]; then
				TEST_PM="yarn"
			else
				TEST_PM="npm"
			fi
		fi
		TEST_CMD="$TEST_PM run test"
	fi
elif [ -f "pyproject.toml" ] || [ -f "setup.cfg" ] || [ -f "pytest.ini" ]; then
	if command -v pytest >/dev/null 2>&1; then
		TEST_CMD="pytest"
	fi
elif [ -f "Cargo.toml" ]; then
	TEST_CMD="cargo test"
elif [ -f "go.mod" ]; then
	TEST_CMD="go test ./..."
elif [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
	TEST_CMD="deno test"
elif [ -f "Makefile" ]; then
	HAS_TEST_TARGET=$(grep -c '^test:' Makefile 2>/dev/null || echo "0")
	if [ "$HAS_TEST_TARGET" -gt 0 ]; then
		TEST_CMD="make test"
	fi
fi

if [ -n "$TEST_CMD" ]; then
	# 30s timeout prevents large test suites from hanging the stop hook
	if command -v gtimeout >/dev/null 2>&1; then
		TEST_OUTPUT=$(gtimeout 30 $TEST_CMD 2>&1)
		TEST_EXIT=$?
	elif command -v timeout >/dev/null 2>&1; then
		TEST_OUTPUT=$(timeout 30 $TEST_CMD 2>&1)
		TEST_EXIT=$?
	else
		# No timeout command available — run with a background kill timer
		TEST_TMPFILE=$(mktemp)
		$TEST_CMD > "$TEST_TMPFILE" 2>&1 &
		TEST_PID=$!
		( sleep 30 && kill $TEST_PID 2>/dev/null ) &
		TIMER_PID=$!
		wait $TEST_PID 2>/dev/null
		TEST_EXIT=$?
		kill $TIMER_PID 2>/dev/null
		wait $TIMER_PID 2>/dev/null
		TEST_OUTPUT=$(cat "$TEST_TMPFILE")
		rm -f "$TEST_TMPFILE"
	fi

	if [ $TEST_EXIT -eq 124 ]; then
		echo "TEST WARNING: Tests timed out after 30s ($TEST_CMD). Run manually to verify."
	elif [ $TEST_EXIT -ne 0 ]; then
		echo "TEST WARNING: Tests failed ($TEST_CMD). Consider fixing before finishing."
		echo ""
		echo "$TEST_OUTPUT" | tail -20
	fi
fi

exit 0
