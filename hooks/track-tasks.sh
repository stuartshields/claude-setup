#!/bin/bash
# PostToolUse hook (matcher: TaskCreate|TaskUpdate)
# Maintains a task state file so other hooks can detect unfinished work.

# Buffer stdin for multi-field extraction (TaskCreate needs subject + response id)
TMPINPUT=$(mktemp)
cat > "$TMPINPUT"

IFS=$'\t' read -r SESSION_ID TOOL < <(jq -r '[.session_id // "", .tool_name // ""] | @tsv' < "$TMPINPUT")

[ -z "$SESSION_ID" ] && exit 0

STATE="/tmp/claude-tasks-${SESSION_ID}.json"
MISMATCH_STATE="/tmp/claude-task-state-mismatch-${SESSION_ID}.txt"

# Serialize concurrent TaskCreate/TaskUpdate hooks against the state file.
# Parallel tool calls (e.g. two TaskUpdate batched in one message) otherwise race:
# both read state, both write tmp, last write loses earlier change. Use mkdir as
# atomic lock primitive (POSIX, works on macOS + Linux). Hold for the brief
# read-modify-write window only.
LOCK="/tmp/claude-tasks-${SESSION_ID}.lock"
TRIES=0
while ! mkdir "$LOCK" 2>/dev/null; do
	TRIES=$((TRIES + 1))
	# Bail out after 2s of contention — stale lock from a crashed prior run
	if [ "$TRIES" -gt 40 ]; then
		# Steal a stale lock (older than 5s)
		if [ -d "$LOCK" ]; then
			LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || date +%s) ))
			[ "$LOCK_AGE" -gt 5 ] && rmdir "$LOCK" 2>/dev/null
		fi
		break
	fi
	sleep 0.05
done
trap 'rmdir "$LOCK" 2>/dev/null; rm -f "$TMPINPUT"' EXIT

case "$TOOL" in
	TaskCreate)
		SUBJECT=$(jq -r '.tool_input.subject // "unknown task"' < "$TMPINPUT")
		# Use tool_response.id if available, otherwise fall back to sequential
		TASK_ID=$(jq -r '.tool_response.id // empty' < "$TMPINPUT")
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
		STATUS=$(jq -r '.tool_input.status // empty' < "$TMPINPUT")
		TASK_ID=$(jq -r '.tool_input.taskId // empty' < "$TMPINPUT")
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
