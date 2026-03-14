#!/bin/bash
# PostToolUse + PostToolUseFailure hook.
# Tracks hook outcomes per session and refreshes a markdown summary for governance reviews.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "PostToolUse"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

[ -z "$SESSION_ID" ] && exit 0

STATUS="ok"
[ "$EVENT" = "PostToolUseFailure" ] && STATUS="fail"

LOG_DIR="$HOME/.claude/logs"
SUMMARY_FILE="$HOME/.claude/docs/governance/evidence/hook-observability-summary.md"
LOG_FILE="$LOG_DIR/hook-observability-${SESSION_ID}.log"
TMP_FILE="${SUMMARY_FILE}.tmp"

mkdir -p "$LOG_DIR" "$HOME/.claude/docs/governance/evidence" 2>/dev/null || exit 0

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${EVENT}|${TOOL_NAME}|${STATUS}" >> "$LOG_FILE"

TOTAL_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ')
OK_COUNT=$(awk -F'|' '$4 == "ok" { c++ } END { print c + 0 }' "$LOG_FILE")
FAIL_COUNT=$(awk -F'|' '$4 == "fail" { c++ } END { print c + 0 }' "$LOG_FILE")

{
	echo "# Hook Observability Summary"
	echo ""
	echo "- Session ID: ${SESSION_ID}"
	echo "- Last Updated (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "- Source Log: ${LOG_FILE}"
	echo ""
	echo "## Totals"
	echo ""
	echo "- Total Events: ${TOTAL_COUNT}"
	echo "- Successful Events: ${OK_COUNT}"
	echo "- Failed Events: ${FAIL_COUNT}"
	echo ""
	echo "## By Tool and Status"
	echo ""
	echo "| Tool | Status | Count |"
	echo "|---|---|---:|"
	awk -F'|' '
		{
			key = $3 "|" $4;
			count[key]++;
		}
		END {
			for (k in count) {
				split(k, parts, "|");
				printf "| %s | %s | %d |\n", parts[1], parts[2], count[k];
			}
		}
	' "$LOG_FILE" | sort
} > "$TMP_FILE" && mv "$TMP_FILE" "$SUMMARY_FILE"

exit 0
