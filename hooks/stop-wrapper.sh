#!/bin/bash
# Wrapper for Stop hooks — guarantees valid JSON output.
# Usage: stop-wrapper.sh <actual-hook-script>
#
# Runs the target hook, captures stdout, and ensures the output
# is always valid JSON. Stderr passes through untouched (user-visible).
#
# - If stdout is valid JSON → pass through
# - If stdout is empty → output {"decision":"approve"}
# - If stdout is non-JSON text → wrap in {"decision":"approve","message":...}

HOOK="$1"

[ -z "$HOOK" ] && echo '{"decision":"approve"}' && exit 0
[ ! -x "$HOOK" ] && echo '{"decision":"approve"}' && exit 0

# Run the hook — stderr passes through to user, stdout captured
OUTPUT=$("$HOOK" 2>&2)

# Empty output → approve
if [ -z "$OUTPUT" ]; then
	echo '{"decision":"approve"}'
	exit 0
fi

# Valid JSON → pass through
if echo "$OUTPUT" | jq -e . >/dev/null 2>&1; then
	echo "$OUTPUT"
	exit 0
fi

# Non-JSON text → wrap it safely
jq -n --arg msg "$OUTPUT" '{"decision":"approve","message":$msg}' 2>/dev/null || echo '{"decision":"approve"}'
exit 0
