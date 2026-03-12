#!/bin/bash
# Stop hook: mechanical linter that catches common cognitive drift patterns.
# Checks all files modified this session (tracked by track-modified-files.sh).
#
# HIGH confidence issues → exit 2 (block stop, force fix)
# Compaction + many files → exit 0 with stdout review prompt (non-blocking)
# Safety: flag file prevents blocking more than once per session.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$SESSION_ID" ] && exit 0

TRACK_FILE="/tmp/claude-drift-${SESSION_ID}"
[ ! -s "$TRACK_FILE" ] && exit 0

# Safety valve: don't block more than once
FLAG="/tmp/claude-drift-reviewed-${SESSION_ID}"
if [ -f "$FLAG" ] && [ "$FLAG" -nt "$TRACK_FILE" ]; then
	exit 0
fi

FILE_COUNT=$(sort -u "$TRACK_FILE" | wc -l | tr -d ' ')
[ "$FILE_COUNT" -lt 3 ] && exit 0

ISSUES=""

# --- HIGH CONFIDENCE CHECKS (deterministic, no false positives) ---

# 1. Leftover artifact files (.bak, .orig, .tmp)
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
	PROJECT_ROOT="$CWD"
	if command -v git >/dev/null 2>&1 && git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		PROJECT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
	fi
	ARTIFACTS=$(find "$PROJECT_ROOT" -maxdepth 4 \( -name "*.bak" -o -name "*.orig" -o -name "*.tmp" \) \
		-not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" 2>/dev/null | head -10)
	if [ -n "$ARTIFACTS" ]; then
		ISSUES="${ISSUES}LEFTOVER ARTIFACTS — delete these files:\n${ARTIFACTS}\n\n"
	fi
fi

# 2. Duplicate numbered list items in modified markdown files
while IFS= read -r f; do
	[ -f "$f" ] || continue
	case "$f" in
		*.md)
			DUPES=$(awk '
			/^[0-9]+\. / {
				match($0, /^[0-9]+/)
				num = substr($0, RSTART, RLENGTH) + 0
				if (num <= prev_num && num == 1) {
					# New list starting at 1 — reset tracking
					delete seen
					prev_num = 0
				}
				if (seen[num]++) printf "  line %d: duplicate number %s.\n", NR, num
				prev_num = num
				in_list = 1
				next
			}
			/^[[:space:]]*$/ || /^#/ || /^---/ || /^[^0-9]/ {
				# Non-list line — reset for next list
				if (in_list) { delete seen; prev_num = 0; in_list = 0 }
			}
		' "$f")
			if [ -n "$DUPES" ]; then
				ISSUES="${ISSUES}DUPLICATE NUMBERING in ${f}:\n${DUPES}\n\n"
			fi
			;;
	esac
done < <(sort -u "$TRACK_FILE")

# 3. Self-referential agent files (agent tells Claude to run/spawn itself)
while IFS= read -r f; do
	[ -f "$f" ] || continue
	case "$f" in
		*.md)
			BASENAME=$(basename "$f" .md)
			# Skip short basenames (too many false positives)
			[ ${#BASENAME} -lt 4 ] && continue
			# Look for action verbs + own name, excluding frontmatter and headers
			SELF_REF=$(awk -v name="$BASENAME" 'BEGIN {
				gsub(/[.+*?[\]{}()|^$\\]/, "\\\\&", name)
			}
				NR <= 5 { next }
				tolower($0) ~ "run[[:space:]]+" tolower(name) ||
				tolower($0) ~ "spawn[[:space:]]+" tolower(name) ||
				tolower($0) ~ "launch[[:space:]]+" tolower(name) ||
				tolower($0) ~ "use[[:space:]]+" tolower(name) "[[:space:]]+agent" {
					printf "  line %d: %s\n", NR, $0
				}
			' "$f" | head -3)
			if [ -n "$SELF_REF" ]; then
				ISSUES="${ISSUES}SELF-REFERENCE in ${f} (agent references running itself):\n${SELF_REF}\n\n"
			fi
			;;
	esac
done < <(sort -u "$TRACK_FILE")

# 4. Broken paths in settings/config files that were modified
while IFS= read -r f; do
	[ -f "$f" ] || continue
	case "$f" in
		*settings.json|*settings.local.json)
			# Extract hook command paths
			HOOK_PATHS=$(jq -r '.. | .command? // empty' "$f" 2>/dev/null | grep -oE '~?/[^ "]+\.(sh|js|py)' | sort -u)
			while IFS= read -r hp; do
				[ -z "$hp" ] && continue
				RESOLVED=$(echo "$hp" | sed "s|^~|$HOME|")
				if [ ! -f "$RESOLVED" ]; then
					ISSUES="${ISSUES}BROKEN PATH in ${f}: ${hp} does not exist\n\n"
				fi
			done <<< "$HOOK_PATHS"
			;;
	esac
done < <(sort -u "$TRACK_FILE")

# --- REPORT ---

if [ -n "$ISSUES" ]; then
	touch "$FLAG"
	printf "COGNITIVE DRIFT DETECTED — fix these before finishing:\n\n%b" "$ISSUES" >&2
	exit 2
fi

# Non-blocking: if compaction occurred + many files, prompt a cross-check
COMPACTED="/tmp/claude-compacted-${SESSION_ID}"
if [ -f "$COMPACTED" ] && [ "$FILE_COUNT" -ge 5 ]; then
	FILE_LIST=$(sort -u "$TRACK_FILE" | head -20)
	printf "DRIFT CHECK: Long session (compacted) with %d modified files. Re-read these for consistency before finishing:\n\n%s\n\nCheck for: convention drift between files, broken cross-references, orphaned code." "$FILE_COUNT" "$FILE_LIST"
fi

exit 0
