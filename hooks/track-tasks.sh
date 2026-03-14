#!/bin/bash
# PostToolUse hook (matcher: TaskCreate|TaskUpdate)
# Maintains a task state file so other hooks can detect unfinished work.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

[ -z "$SESSION_ID" ] && exit 0

STATE="/tmp/claude-tasks-${SESSION_ID}.json"
MISMATCH_STATE="/tmp/claude-task-state-mismatch-${SESSION_ID}.txt"

case "$TOOL" in
	TaskCreate)
		SUBJECT=$(echo "$INPUT" | jq -r '.tool_input.subject // "unknown task"')
		# Use tool_response.id if available, otherwise fall back to sequential
		TASK_ID=$(echo "$INPUT" | jq -r '.tool_response.id // empty')
		if [ -z "$TASK_ID" ]; then
			if [ -s "$STATE" ] && jq -e . "$STATE" >/dev/null 2>&1; then
				TASK_ID=$(($(jq 'length' "$STATE") + 1))
			else
				TASK_ID="1"
			fi
		fi
		if [ -s "$STATE" ] && jq -e . "$STATE" >/dev/null 2>&1; then
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
		if [ -s "$STATE" ] && { [ "$STATUS" = "completed" ] || [ "$STATUS" = "deleted" ]; }; then
			# Require exact task id mapping to preserve task-state integrity.
			if jq -e --arg id "$TASK_ID" 'has($id)' "$STATE" >/dev/null 2>&1; then
				jq --arg id "$TASK_ID" '.[$id].done = true' \
					"$STATE" > "${STATE}.tmp" && mv "${STATE}.tmp" "$STATE"
				rm -f "$MISMATCH_STATE"
			else
				KNOWN_IDS=$(jq -r 'keys | join(", ")' "$STATE" 2>/dev/null)
				printf "TaskUpdate mismatch: taskId='%s' status='%s' known_task_ids=[%s]" "$TASK_ID" "$STATUS" "$KNOWN_IDS" > "$MISMATCH_STATE"
			fi
		fi
		;;
esac

exit 0
