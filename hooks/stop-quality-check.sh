#!/bin/bash
# Stop hook: checks the assistant's final message for high-precision shortcut patterns.
# Mechanical pattern matching — no model invocation needed.
#
# Precision policy: blocking is reserved for patterns that have very few false-positive
# triggers. Three earlier patterns (deferred follow-ups, listed-without-fixing, too-many-
# issues excuse) were removed after blocking on legitimate trade-off discussions and
# scope-boundary explanations. The kept patterns require very specific phrasing.

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

# Pattern A: Rationalising work as pre-existing (high precision).
# The pattern "X is pre-existing, not related to my change" is almost always a tell;
# legitimate discussion of inherited code rarely uses this exact framing.
if [[ "$LAST_MSG_LC" =~ (pre.?existing\ (issue|problem|bug)|was\ already\ (broken|there)|not\ related\ to\ (my|this|our)\ change) ]]; then
	ISSUES="${ISSUES}- Rationalised issues as pre-existing\n"
fi

# Pattern B: Success claim without verification evidence (high precision).
# Pairs an affirmation phrase with the *absence* of any verification keyword.
# Very tight check — claiming "all done" without saying "tested/built/ran/verified"
# is a strong signal of unverified success.
if [[ "$LAST_MSG_LC" =~ (all\ (done|set|good|fixed)|everything\ (works|is\ working|looks\ good)|should\ (work|be\ fine)\ now) ]] && \
   ! [[ "$LAST_MSG_LC" =~ (test|build|lint|verified|ran\ |pass|exit|output) ]]; then
	ISSUES="${ISSUES}- Declared success without verification evidence\n"
fi

if [ -n "$ISSUES" ]; then
	touch "$FLAG"
	REASON=$(printf "QUALITY CHECK — potential shortcuts detected:\n%b\nAddress these before finishing, or explain why they're acceptable." "$ISSUES")
	jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
fi

exit 0
