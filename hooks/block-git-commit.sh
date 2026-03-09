#!/bin/bash
# Block git commit commands and destructive Bash operations.
# PreToolUse hook — receives JSON on stdin, exit 2 to block.

command=$(jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$command" ] && exit 0

# --- Git commit blocking ---
if [[ "$command" =~ git[[:space:]]+(.*[[:space:]]+)?commit ]] || \
   [[ "$command" =~ gsd-tools[^[:space:]]*[[:space:]]+commit ]]; then
	echo "BLOCKED: Git commits are disabled. Stage your changes manually and commit when ready." >&2
	exit 2
fi

# --- Destructive command blocking ---
# rm -rf (with any flag ordering) — only match rm as an actual command,
# not when it appears inside grep/echo/string arguments.
# Anchors: start of command, or after && || ; | ( — with optional whitespace.
if echo "$command" | grep -qE '(^|[;&|]\s*|\|\|\s*|&&\s*|\(\s*)rm\s+-[a-zA-Z]*r[a-zA-Z]*f\b|(^|[;&|]\s*|\|\|\s*|&&\s*|\(\s*)rm\s+-[a-zA-Z]*f[a-zA-Z]*r\b'; then
	echo "BLOCKED: rm -rf is not allowed. Remove files individually or ask the user." >&2
	exit 2
fi

# Filesystem destruction patterns
if echo "$command" | grep -qE '>\s*/dev/sd|mkfs\.|:\(\)\{|fork\s*bomb'; then
	echo "BLOCKED: Destructive filesystem operation detected." >&2
	exit 2
fi

# chmod/chown on broad paths
if echo "$command" | grep -qE '(chmod|chown)\s+.*-R\s+[/~]'; then
	echo "BLOCKED: Recursive permission change on broad path. Be more specific." >&2
	exit 2
fi

# --- Data exfiltration blocking ---
# curl/wget posting data to external URLs
if echo "$command" | grep -qE '(curl|wget)\s.*(-d\s|--data|--upload|-X\s*POST|-X\s*PUT|-F\s)'; then
	echo "BLOCKED: Outbound data transfer via curl/wget. Ask the user first." >&2
	exit 2
fi

exit 0
