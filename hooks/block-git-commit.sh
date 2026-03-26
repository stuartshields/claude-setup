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
if [[ "$command" =~ (^|[[:space:];\&\|\(])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f ]] || \
   [[ "$command" =~ (^|[[:space:];\&\|\(])rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r ]]; then
	echo "BLOCKED: rm -rf is not allowed. Remove files individually or ask the user." >&2
	exit 2
fi

# Filesystem destruction patterns
if [[ "$command" =~ \>[[:space:]]*/dev/sd ]] || \
   [[ "$command" =~ mkfs\. ]] || \
   [[ "$command" =~ :\(\)\{ ]] || \
   [[ "$command" =~ fork[[:space:]]*bomb ]]; then
	echo "BLOCKED: Destructive filesystem operation detected." >&2
	exit 2
fi

# chmod/chown on broad paths
if [[ "$command" =~ (chmod|chown)[[:space:]]+.*-R[[:space:]]+[/~] ]]; then
	echo "BLOCKED: Recursive permission change on broad path. Be more specific." >&2
	exit 2
fi

# --- Data exfiltration blocking ---
# curl/wget posting data to external URLs
if [[ "$command" =~ (curl|wget)[[:space:]].*(-d[[:space:]]|--data|--upload|-X[[:space:]]*POST|-X[[:space:]]*PUT|-F[[:space:]]) ]]; then
	echo "BLOCKED: Outbound data transfer via curl/wget. Ask the user first." >&2
	exit 2
fi

exit 0
