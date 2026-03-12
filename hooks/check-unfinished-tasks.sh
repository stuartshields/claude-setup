#!/bin/bash
# Stop + UserPromptSubmit hook — warns about incomplete tasks.
# Stop: blocks Claude from finishing (exit 2) so it addresses remaining work.
# UserPromptSubmit: injects reminder (exit 0, stdout) so Claude doesn't abandon current tasks.
# Safety: after 2 consecutive Stop blocks within 30s, downgrades to non-blocking warning.

# Read only needed fields from stdin — avoid buffering full payload (screenshots = multi-MB base64)
read -r SESSION_ID EVENT < <(jq -r '[.session_id // "", .hook_event_name // ""] | @tsv')

[ -z "$SESSION_ID" ] && exit 0

STATE="/tmp/claude-tasks-${SESSION_ID}.json"
[ ! -s "$STATE" ] && exit 0

# Count incomplete tasks
PENDING=$(jq '[to_entries[] | select(.value.done == false)] | length' "$STATE" 2>/dev/null || echo "0")
[ "$PENDING" -eq 0 ] && exit 0

SUBJECTS=$(jq -r '[to_entries[] | select(.value.done == false) | "#\(.key): \(.value.subject)"] | join(", ")' "$STATE" 2>/dev/null)

if [ "$EVENT" = "Stop" ]; then
	# Safety valve: prevent infinite loop if Claude can't complete tasks
	DEBOUNCE="/tmp/claude-task-stop-${SESSION_ID}.count"
	COUNT=0
	if [ -f "$DEBOUNCE" ]; then
		AGE=$(( $(date +%s) - $(stat -f %m "$DEBOUNCE" 2>/dev/null || stat -c %Y "$DEBOUNCE" 2>/dev/null || echo "0") ))
		if [ "$AGE" -lt 30 ]; then
			COUNT=$(cat "$DEBOUNCE" 2>/dev/null || echo "0")
		fi
	fi
	COUNT=$((COUNT + 1))
	echo "$COUNT" > "$DEBOUNCE"

	if [ "$COUNT" -gt 2 ]; then
		# Downgrade to non-blocking after 2 blocks
		echo "UNFINISHED TASKS ($PENDING remaining): $SUBJECTS — You've been reminded multiple times. Finish these or tell the user you're leaving them incomplete."
		exit 0
	fi

	echo "UNFINISHED TASKS ($PENDING remaining): $SUBJECTS — Complete these or mark them done (TaskUpdate status=completed) before finishing." >&2
	exit 2
fi

# UserPromptSubmit — non-blocking context injection
echo "ACTIVE TASKS ($PENDING in progress): $SUBJECTS — If this is a new request, add it to your task list and finish current work first."
exit 0
