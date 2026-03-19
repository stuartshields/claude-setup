#!/bin/bash
# PostToolUse + PostToolUseFailure hook.
# Tracks hook outcomes per session and refreshes a markdown summary for governance reviews.

# Single jq call — avoid buffering full PostToolUse payload
IFS=$'\t' read -r SESSION_ID EVENT TOOL_NAME < <(jq -r '[.session_id // "", .hook_event_name // "PostToolUse", .tool_name // "unknown"] | @tsv')

[ -z "$SESSION_ID" ] && exit 0

STATUS="ok"
[ "$EVENT" = "PostToolUseFailure" ] && STATUS="fail"

LOG_DIR="$HOME/.claude/logs"
SUMMARY_FILE="$HOME/.claude/docs/governance/evidence/hook-observability-summary.md"
LOG_FILE="$LOG_DIR/hook-observability-${SESSION_ID}.log"

mkdir -p "$LOG_DIR" "$HOME/.claude/docs/governance/evidence" 2>/dev/null || exit 0

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${EVENT}|${TOOL_NAME}|${STATUS}" >> "$LOG_FILE"

# Only rebuild summary every 10th entry (per session) to reduce I/O
LINE_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ')
[ $((LINE_COUNT % 10)) -ne 0 ] && exit 0

TMP_FILE="${SUMMARY_FILE}.tmp"
ALL_LOGS="$LOG_DIR"/hook-observability-*.log

# Aggregate across all session logs
TOTAL_COUNT=$(cat $ALL_LOGS 2>/dev/null | wc -l | tr -d ' ')
OK_COUNT=$(awk -F'|' '$4 == "ok" { c++ } END { print c + 0 }' $ALL_LOGS 2>/dev/null)
FAIL_COUNT=$(awk -F'|' '$4 == "fail" { c++ } END { print c + 0 }' $ALL_LOGS 2>/dev/null)
SESSION_COUNT=$(ls -1 $ALL_LOGS 2>/dev/null | wc -l | tr -d ' ')
EARLIEST=$(awk -F'|' 'FNR==1{print $1}' $ALL_LOGS 2>/dev/null | sort | head -1)
LATEST=$(tail -1 "$LOG_FILE" | cut -d'|' -f1)

{
	echo "# Hook Observability Summary"
	echo ""
	echo "- Sessions Tracked: ${SESSION_COUNT}"
	echo "- Date Range: ${EARLIEST:-unknown} to ${LATEST:-unknown}"
	echo "- Last Updated (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "- Latest Session: ${SESSION_ID}"
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
	' $ALL_LOGS 2>/dev/null | sort
} > "$TMP_FILE" && mv "$TMP_FILE" "$SUMMARY_FILE"

exit 0
