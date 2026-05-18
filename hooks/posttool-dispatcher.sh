#!/bin/bash
# PostToolUse + PostToolUseFailure dispatcher.
# Replaces 8 separate PostToolUse hook entries with one. Buffers stdin once,
# replays it to each applicable sub-hook based on tool name.
# All sub-hooks are advisory (exit 0). Their stdout concatenates into one
# system reminder message; the dispatcher itself always exits 0.

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat)

TOOL_NAME=$(jq -r '.tool_name // ""' <<<"$INPUT")
[ -z "$TOOL_NAME" ] && exit 0

# Parallel arrays: tool-name regex + hook filename. Order matters.
MATCHERS=(
	"^(Write|Edit)$"
	"^(Write|Edit)$"
	"^(Bash|Edit|Write)$"
	"^(TaskCreate|TaskUpdate)$"
	"^(Bash|Edit|Write)$"
	"^(Bash|Edit|Write)$"
	"^(Read|Grep|Glob|Edit|Write)$"
	"^(Edit|Write)$"
)
HOOKS=(
	"track-modified-files.sh"
	"project-quality-gates.sh"
	"hook-observability-summary.sh"
	"track-tasks.sh"
	"detect-perf-degradation.sh"
	"memory-review-prompt.sh"
	"context-drift-guard.sh"
	"repeated-approach-guard.sh"
)

OUTPUTS=""

for i in "${!HOOKS[@]}"; do
	MATCHER="${MATCHERS[$i]}"
	HOOK="${HOOKS[$i]}"

	# Skip if tool doesn't match this hook's pattern
	echo "$TOOL_NAME" | grep -qE "$MATCHER" || continue

	HOOK_PATH="${HOOK_DIR}/${HOOK}"
	[ ! -x "$HOOK_PATH" ] && continue

	OUT=$(printf '%s' "$INPUT" | "$HOOK_PATH" 2>/dev/null)
	[ -n "$OUT" ] && OUTPUTS="${OUTPUTS}${OUT}"$'\n'
done

[ -n "$OUTPUTS" ] && printf '%s' "$OUTPUTS"

exit 0
