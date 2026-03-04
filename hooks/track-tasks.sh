#!/bin/bash
# PostToolUse hook (matcher: TaskCreate|TaskUpdate)
# Maintains a task state file so other hooks can detect unfinished work.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

[ -z "$SESSION_ID" ] && exit 0

STATE="/tmp/claude-tasks-${SESSION_ID}.json"

case "$TOOL" in
	TaskCreate)
		SUBJECT=$(echo "$INPUT" | jq -r '.tool_input.subject // "unknown task"')
		# Use tool_response.id if available, otherwise fall back to sequential
		TASK_ID=$(echo "$INPUT" | jq -r '.tool_response.id // empty')
		if [ -z "$TASK_ID" ]; then
			if [ -f "$STATE" ] && jq -e . "$STATE" >/dev/null 2>&1; then
				TASK_ID=$(($(jq 'length' "$STATE") + 1))
			else
				TASK_ID="1"
			fi
		fi
		if [ -f "$STATE" ] && jq -e . "$STATE" >/dev/null 2>&1; then
			jq --arg id "$TASK_ID" --arg s "$SUBJECT" \
				'. + {($id): {"subject": $s, "done": false}}' \
				"$STATE" > "${STATE}.tmp" && mv "${STATE}.tmp" "$STATE"
		else
			jq -n --arg id "$TASK_ID" --arg s "$SUBJECT" '{($id):{"subject":$s,"done":false}}' > "$STATE"
		fi
		;;
	TaskUpdate)
		STATUS=$(echo "$INPUT" | jq -r '.tool_input.status // empty')
		TASK_ID=$(echo "$INPUT" | jq -r '.tool_input.taskId // empty')
		if [ -f "$STATE" ] && { [ "$STATUS" = "completed" ] || [ "$STATUS" = "deleted" ]; }; then
			# Try exact match first, then scan by subject as fallback
			if jq -e --arg id "$TASK_ID" 'has($id)' "$STATE" >/dev/null 2>&1; then
				jq --arg id "$TASK_ID" '.[$id].done = true' \
					"$STATE" > "${STATE}.tmp" && mv "${STATE}.tmp" "$STATE"
			else
				# Fallback: mark first unfinished task as done.
				jq '(
					to_entries
					| map(select(.value.done == false))
					| first
					| .key
				) as $first_undone
				| if $first_undone then .[$first_undone].done = true else . end' \
					"$STATE" > "${STATE}.tmp" 2>/dev/null && mv "${STATE}.tmp" "$STATE" || true
			fi
		fi
		;;
esac

exit 0
