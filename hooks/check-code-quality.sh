#!/bin/bash
# Deterministic code quality gate for Write/Edit tool calls.
# Replaces the Stop prompt hook — no LLM, no JSON validation errors.

TMPINPUT=$(mktemp)
TMPCODE=$(mktemp)
trap 'rm -f "$TMPINPUT" "$TMPCODE"' EXIT

cat > "$TMPINPUT"

FILE_PATH=$(jq -r '.tool_input.file_path // empty' < "$TMPINPUT")

# Only check code files
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx|*.py|*.css|*.html|*.sql|*.go|*.rs|*.php) ;;
	*) exit 0 ;;
esac

TOOL=$(jq -r '.tool_name' < "$TMPINPUT")

if [ "$TOOL" = "Write" ]; then
	jq -r '.tool_input.content // empty' < "$TMPINPUT" > "$TMPCODE"
elif [ "$TOOL" = "Edit" ]; then
	jq -r '.tool_input.new_string // empty' < "$TMPINPUT" > "$TMPCODE"
else
	exit 0
fi

[ ! -s "$TMPCODE" ] && exit 0

ERRORS=""

# Tabs not spaces — only for Write (full file).
# Edit skipped because replacement may need to match existing indentation.
if [ "$TOOL" = "Write" ]; then
	if grep -Eq '^ ' "$TMPCODE"; then
		ERRORS="${ERRORS}Space indentation detected — use tabs. "
	fi
fi

# No console.log in JS/TS
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx)
		if grep -q 'console\.log(' "$TMPCODE"; then
			ERRORS="${ERRORS}console.log() found — remove or use console.error. "
		fi
		;;
esac

# No placeholder comments
if grep -Eq '//\s*\.\.\.\s*$' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// ...' found — write real code. "
fi
if grep -Eiq '//\s*rest of' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// rest of...' found — write real code. "
fi

if [ -n "$ERRORS" ]; then
	echo "$ERRORS" >&2
	exit 2
fi

# --- Security-sensitive file detection (non-blocking — stdout context) ---
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
	echo "SECURITY ALERT ($SECURITY_HIT): You are editing security-sensitive code. Verify: input validation, auth checks, no hardcoded secrets, no injection vectors. Consider running the security agent after this change."
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
			for PKG in $IMPORTS; do
				# Skip node builtins
				case "$PKG" in
					fs|path|os|url|http|https|crypto|util|stream|events|buffer|child_process|assert|net|tls|dns|cluster|zlib|readline|querystring|string_decoder|timers|tty|v8|vm|worker_threads|perf_hooks|async_hooks|diagnostics_channel|node|process|module|inspector|constants|punycode|domain|sys|wasi|trace_events|repl|dgram|http2|test) continue ;;
				esac
				# Check if package exists in dependencies or devDependencies
				if ! jq -e "(.dependencies[\"$PKG\"] // .devDependencies[\"$PKG\"] // .peerDependencies[\"$PKG\"]) != null" "$PKG_JSON" >/dev/null 2>&1; then
					echo "DEPENDENCY WARNING: Package '$PKG' imported but not found in package.json. Verify this is a real package — hallucinated package names enable dependency confusion attacks."
				fi
			done
		fi
		;;
esac

exit 0
