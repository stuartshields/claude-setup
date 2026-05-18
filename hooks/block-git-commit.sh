#!/bin/bash
# Block git commit commands and destructive Bash operations.
# PreToolUse hook — receives JSON on stdin, exit 2 to block.

command=$(jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$command" ] && exit 0

# --- Git commit blocking (~/Work only) ---
if [[ "$PWD" == "$HOME/Work"* ]]; then
	if [[ "$command" =~ git[[:space:]]+(.*[[:space:]]+)?commit ]] || \
	   [[ "$command" =~ gsd-tools[^[:space:]]*[[:space:]]+commit ]]; then
		echo "BLOCKED: Git commits are disabled in ~/Work. Stage your changes manually and commit when ready." >&2
		exit 2
	fi
fi

# --- Git branch deletion blocking ---
# Allow deleting worktree-agent-* branches only
if [[ "$command" =~ git[[:space:]]+(.*[[:space:]]+)?branch[[:space:]]+-[a-zA-Z]*D ]] && \
   ! [[ "$command" =~ worktree-agent- ]]; then
	echo "BLOCKED: git branch -D is only allowed for worktree-agent-* branches." >&2
	exit 2
fi

# --- Destructive command blocking ---
# rm -rf (with any flag ordering) — only match rm as an actual command,
# not when it appears inside grep/echo/string arguments.
# Anchors: start of command, or after && || ; | ( — with optional whitespace.
#
# Allowlist: permit rm -rf when the command is exactly "rm -rf <harness-path>"
# (single target, no chaining) and the path has at least one segment past the
# harness subdirectory. This allows "rm -rf ~/.claude/skills/foo/" but still
# blocks "rm -rf ~/.claude/", "rm -rf ~/.claude/skills/", and pipelines like
# "cd / && rm -rf .". Added after harness cleanup work was repeatedly false-
# blocked despite being authorised.
HARNESS_RM_ALLOW_RE='^[[:space:]]*rm[[:space:]]+-[a-zA-Z]*[fr][a-zA-Z]*[[:space:]]+(\~|\$HOME|/Users/[^/]+)/\.claude/(skills|agents|hooks|backups|paste-cache|logs|todos|tasks|file-history|projects)/[^[:space:]/]+/?[[:space:]]*(2>/dev/null|2>&1)?[[:space:]]*$'

if [[ "$command" =~ $HARNESS_RM_ALLOW_RE ]]; then
	: # Allowed harness cleanup — fall through
elif [[ "$command" =~ (^|[[:space:];\&\|\(])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f ]] || \
     [[ "$command" =~ (^|[[:space:];\&\|\(])rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r ]]; then
	echo "BLOCKED: rm -rf is not allowed. Allowed exception: \"rm -rf <path>\" where <path> is a single subdirectory of ~/.claude/{skills,agents,hooks,backups,paste-cache,logs,todos,tasks,file-history,projects}/. Remove files individually or ask the user." >&2
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
# curl/wget posting data to external URLs (but allow localhost)
if [[ "$command" =~ (curl|wget)[[:space:]].*(-d[[:space:]]|--data|--upload|-X[[:space:]]*POST|-X[[:space:]]*PUT|-F[[:space:]]) ]]; then
	# Allow localhost requests for testing
	if ! [[ "$command" =~ http://localhost ]] && ! [[ "$command" =~ http://127.0.0.1 ]]; then
		echo "BLOCKED: Outbound data transfer via curl/wget. Ask the user first." >&2
		exit 2
	fi
fi

exit 0
