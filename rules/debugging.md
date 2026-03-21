<!-- Last updated: 2026-03-21 -->

# Debugging & Investigation

## 4-Step Framework: Reproduce → Isolate → Fix → Validate
- **Never skip to Fix.** Follow the sequence every time. Most wrong fixes come from jumping straight to code changes.
- **Reproduce:** Run the faulty scenario. Note the exact error, context, and conditions.
- **Isolate:** Use diagnostic commands to narrow down the failing component. 80% of bugs live in the 20% of code recently modified — start there.
- **Fix:** Apply the targeted change. Touch only the files the bug is in — but touch all of them. Broad corrections mask problems, but avoiding necessary files is avoidance.
- **Validate:** Run the full test suite. Confirm the original error is gone AND no regressions introduced.

## Validate Before Fixing
- **Confirm root cause before proposing code changes.** Isolation first, fix second — no exceptions.
- **One hypothesis at a time.** Rank possibilities and test the most likely first.
- **Every hypothesis needs a validation step.** State: (1) what you suspect, (2) how to confirm it, (3) expected output, (4) what it means if output differs.
- **Replace "maybe" and "possibly" with testable instrumentation.** Uncertainty means you need more data.
- **Assume your initial diagnosis is wrong.** Define what would falsify your hypothesis before testing it.

## Investigation Over Assumption
- **Search before assuming.** If a file path, variable, or architectural detail is not in context, use Glob/Grep to find it. Ask the user only if search fails.
- **Interview first when ambiguous.** If the request is vague (e.g., "Fix the login"), ask 2-3 targeted questions before proposing a plan.
- **State hypotheses explicitly.** "I suspect X, verifying by reading [File Z]."

## Deep-Trace Debugging
- **Trace the full data flow.** Use Grep to find parent components, context providers, and service layers. Explain the flow (e.g., `API -> Service -> Hook -> Component`) before proposing a fix.
- **Check ancestry.** The bug may not be in the file the user mentioned.

## Anti-Loop Protocol
- **Each attempt MUST use a different approach.** If attempt 1 failed, your diagnosis was wrong — don't vary the fix, vary the diagnosis. Re-trace the data flow from scratch.
- **After 2 failed fix attempts, STOP.** Do not try a third variation. Instead: state what you've tried, what each attempt ruled out, and ask the user for more context or suggest a fundamentally different angle.
- **Watch for oscillation.** If fixing A breaks B and fixing B breaks A, the problem is contradictory constraints or a wrong mental model — not a code issue. Stop, identify the conflict, and surface it to the user.
- **Context pollution is real.** After 2 failed corrections in the same conversation, the context is polluted with wrong approaches. Recommend `/clear` and restate with lessons learned.

## Time-Box Root Cause Analysis
- **Check memory files and prior notes FIRST.** Start with documented untried approaches.
- **Skip root-cause isolation only when you truly can't observe the runtime** (e.g., native app crash with no logs). Even then, prefer adding instrumentation over guessing.
- **Only research hypotheses you can test locally.**
- **After 8+ tool calls without reproducing the issue**, step back and summarize what you know. Ask the user if the reproduction steps are correct before continuing.
