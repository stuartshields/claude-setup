#!/bin/bash
# Stop hook: checks the assistant's final message for signs of incomplete work.
# Replaces the prompt-type hook that was unreliable with JSON output.
# Mechanical pattern matching — no model invocation needed.

IFS=$'\t' read -r SESSION_ID LAST_MSG < <(jq -r '[.session_id // "", .last_assistant_message // ""] | @tsv')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$LAST_MSG" ] && exit 0

# Safety valve: only block once per session
FLAG="/tmp/claude-quality-checked-${SESSION_ID}"
if [ -f "$FLAG" ]; then
	exit 0
fi

# Lowercase for case-insensitive matching (bash 3 compatible via tr)
LAST_MSG_LC=$(echo "$LAST_MSG" | tr '[:upper:]' '[:lower:]')

ISSUES=""

# Pattern 1: Deferring to follow-ups the user didn't ask for
if [[ "$LAST_MSG_LC" =~ (in\ a\ follow.?up|as\ a\ next\ step|for\ a\ future|in\ a\ separate\ pr|out\ of\ scope\ for\ now|beyond\ the\ scope) ]]; then
	ISSUES="${ISSUES}- Deferred work to unrequested follow-up\n"
fi

# Pattern 2: Rationalising incomplete work
if [[ "$LAST_MSG_LC" =~ (pre.?existing\ (issue|problem|bug)|was\ already\ (broken|there)|not\ related\ to\ (my|this|our)\ change) ]]; then
	ISSUES="${ISSUES}- Rationalised issues as pre-existing\n"
fi

# Pattern 3: Listing problems without fixing them
if [[ "$LAST_MSG_LC" =~ (you\ (may|might|should|could)\ (want\ to|need\ to|also)|consider\ (adding|fixing|updating)|todo|fixme|hack) ]] && \
   ! [[ "$LAST_MSG_LC" =~ (i.ve\ (fixed|updated|added|removed|changed)|done|complete) ]]; then
	ISSUES="${ISSUES}- Listed problems without fixing them\n"
fi

# Pattern 4: Claiming success without verification evidence
if [[ "$LAST_MSG_LC" =~ (all\ (done|set|good|fixed)|everything\ (works|is\ working|looks\ good)|should\ (work|be\ fine)\ now) ]] && \
   ! [[ "$LAST_MSG_LC" =~ (test|build|lint|verified|ran\ |pass|exit|output) ]]; then
	ISSUES="${ISSUES}- Declared success without verification evidence\n"
fi

# Pattern 5: Too many issues excuse
if [[ "$LAST_MSG_LC" =~ (too\ many\ (issues|errors|problems)|would\ require\ (significant|major|extensive)|beyond\ what\ can\ be) ]]; then
	ISSUES="${ISSUES}- Used 'too many issues' as excuse to stop\n"
fi

if [ -n "$ISSUES" ]; then
	touch "$FLAG"
	REASON=$(printf "QUALITY CHECK — potential shortcuts detected:\n%b\nAddress these before finishing, or explain why they're acceptable." "$ISSUES")
	jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
fi

exit 0
