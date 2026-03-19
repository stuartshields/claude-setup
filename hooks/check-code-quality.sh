#!/bin/bash
# Deterministic code quality gate for Write/Edit tool calls.
# Replaces the Stop prompt hook — no LLM, no JSON validation errors.

TMPINPUT=$(mktemp)
TMPCODE=$(mktemp)
trap 'rm -f "$TMPINPUT" "$TMPCODE"' EXIT

cat > "$TMPINPUT"

# Single jq call for metadata (was 2 separate calls: file_path + tool_name)
IFS=$'\t' read -r FILE_PATH TOOL < <(jq -r '[(.tool_input.file_path // ""), (.tool_name // "")] | @tsv' < "$TMPINPUT")

# Only check code files
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx|*.py|*.css|*.html|*.sql|*.go|*.rs|*.php) ;;
	*) exit 0 ;;
esac

# Extract content based on tool type (1 jq call, only for matching code files)
case "$TOOL" in
	Write) jq -r '.tool_input.content // empty' < "$TMPINPUT" > "$TMPCODE" ;;
	Edit)  jq -r '.tool_input.new_string // empty' < "$TMPINPUT" > "$TMPCODE" ;;
	*)     exit 0 ;;
esac

[ ! -s "$TMPCODE" ] && exit 0

ERRORS=""
NONBLOCKING_NOTES=""

# Smart indentation check (ESLint smart-tabs / editorconfig-checker heuristic).
# Allows: docblock continuation ( * ...), smart tabs (tab+spaces for alignment).
# Flags: pure space indentation (spaces as sole indent mechanism).
if grep -Eq '^ +[^*[:space:]]' "$TMPCODE"; then
	# Space-indented non-docblock lines exist — check if tabs are also present.
	# If yes, spaces are likely alignment (smart tabs) — allow it.
	if ! grep -q '^\t' "$TMPCODE"; then
		ERRORS="${ERRORS}INDENTATION: Space indentation detected — rewrite using tabs. "
	fi
fi

# Trailing whitespace — blocking error.
if grep -Eq '[[:space:]]$' "$TMPCODE"; then
	ERRORS="${ERRORS}TRAILING WHITESPACE: Remove trailing spaces/tabs from line endings. "
fi

# No console.log or debugger in JS/TS
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx)
		if grep -q 'console\.log(' "$TMPCODE"; then
			ERRORS="${ERRORS}console.log() found — remove or use console.error. "
		fi
		if grep -Eq '^\s*debugger\s*;?\s*$' "$TMPCODE"; then
			ERRORS="${ERRORS}debugger statement found — remove before shipping. "
		fi
		;;
esac

# No placeholder comments or stub implementations
if grep -Eq '//\s*\.\.\.\s*$' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// ...' found — write real code. "
fi
if grep -Eiq '//\s*rest of' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// rest of...' found — write real code. "
fi
if grep -Eiq '//\s*(TODO|FIXME|HACK|XXX):?\s*(implement|add|finish|complete|fill|wire)' "$TMPCODE"; then
	ERRORS="${ERRORS}TODO stub found — implement the logic instead of leaving a TODO. "
fi
if grep -Eiq '(#|//|/\*)\s*(placeholder|stub|skeleton|not yet implemented|left as exercise)' "$TMPCODE"; then
	ERRORS="${ERRORS}Stub/placeholder comment found — write the real implementation. "
fi
if grep -Eq 'throw new Error\(['\''"]not implemented' "$TMPCODE"; then
	ERRORS="${ERRORS}'throw not implemented' found — write the real implementation. "
fi
if grep -Eq 'pass\s*#\s*(todo|fixme|implement|stub)' "$TMPCODE"; then
	ERRORS="${ERRORS}Python pass stub found — implement the logic. "
fi

if [ -n "$ERRORS" ]; then
	echo "$ERRORS" >&2
	exit 2
fi

# --- Security-sensitive file detection (non-blocking context) ---
BASENAME=$(basename "$FILE_PATH" 2>/dev/null | tr '[:upper:]' '[:lower:]')
DIRPATH=$(dirname "$FILE_PATH" 2>/dev/null | tr '[:upper:]' '[:lower:]')

SECURITY_HIT=""
# Check filename patterns
case "$BASENAME" in
	*auth*|*login*|*password*|*passwd*|*token*|*session*|*crypto*|*secret*|*credential*|*oauth*|*jwt*|*csrf*|*sanitiz*|*escape*|*permission*|*rbac*|*acl*)
		SECURITY_HIT="filename match: $BASENAME"
		;;
esac
# Check directory patterns
case "$DIRPATH" in
	*auth*|*middleware*|*security*|*guard*|*permission*|*policy*)
		SECURITY_HIT="directory match: $DIRPATH"
		;;
esac
# Check content for security-sensitive patterns
if [ -z "$SECURITY_HIT" ]; then
	if grep -Eiq '(password|secret|api.?key|private.?key|bcrypt|argon2|pbkdf2|createHash|createHmac|jwt\.sign|jwt\.verify|setCookie.*httpOnly|csrf|xss|sanitize|escape|eval\(|innerHTML|dangerouslySetInnerHTML|exec\(|child_process|subprocess)' "$TMPCODE" 2>/dev/null; then
		SECURITY_HIT="content match: security-sensitive patterns detected"
	fi
fi

if [ -n "$SECURITY_HIT" ]; then
	NONBLOCKING_NOTES="${NONBLOCKING_NOTES}SECURITY ALERT ($SECURITY_HIT): You are editing security-sensitive code. Verify: input validation, auth checks, no hardcoded secrets, no injection vectors. Consider running the security agent after this change. "
fi

# --- Dependency verification (JS/TS only, non-blocking) ---
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx)
		# Find project root
		PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || dirname "$FILE_PATH")
		PKG_JSON="$PROJ_ROOT/package.json"
		if [ -f "$PKG_JSON" ]; then
			# Extract imported package names (not relative paths)
			IMPORTS=$(grep -Eo "(from|require\()\s*['\"]([^./][^'\"]*)" "$TMPCODE" 2>/dev/null | sed "s/.*['\"]//g" | sed 's/\/.*//g' | sort -u)

			# Filter out node builtins
			FILTERED=""
			for PKG in $IMPORTS; do
				case "$PKG" in
					fs|path|os|url|http|https|crypto|util|stream|events|buffer|child_process|assert|net|tls|dns|cluster|zlib|readline|querystring|string_decoder|timers|tty|v8|vm|worker_threads|perf_hooks|async_hooks|diagnostics_channel|node|process|module|inspector|constants|punycode|domain|sys|wasi|trace_events|repl|dgram|http2|test) continue ;;
				esac
				FILTERED="${FILTERED}${PKG}\n"
			done

			# Single batched jq call to check all packages at once (was 1 jq per package)
			if [ -n "$FILTERED" ]; then
				MISSING=$(printf '%b' "$FILTERED" | sed '/^$/d' | jq -R -s -r --slurpfile pkg "$PKG_JSON" '
					split("\n") | map(select(length > 0)) | .[] as $name |
					if ($pkg[0].dependencies[$name] // $pkg[0].devDependencies[$name] // $pkg[0].peerDependencies[$name]) == null
					then $name
					else empty
					end
				' 2>/dev/null)

				if [ -n "$MISSING" ]; then
					while IFS= read -r PKG; do
						NONBLOCKING_NOTES="${NONBLOCKING_NOTES}DEPENDENCY WARNING: Package '$PKG' imported but not found in package.json. Verify this is a real package. "
					done <<< "$MISSING"
				fi
			fi
		fi
		;;
esac

if [ -n "$NONBLOCKING_NOTES" ]; then
	jq -n --arg notes "$NONBLOCKING_NOTES" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			additionalContext: $notes
		}
	}'
fi

exit 0
