# Debugging & Investigation

## Validate Before Fixing
- **Confirm root cause before proposing code changes** — unless Time-Box limit (below) is reached. Isolation first, fix second.
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

## Time-Box Root Cause Analysis
- **After 3 tool calls without reproduction, try the next practical fix.** A working bypass beats a perfect diagnosis you can't confirm.
- **Check memory files and prior notes FIRST.** Start with documented untried approaches.
- **Skip root-cause isolation when you can't observe the runtime** (e.g., native app). Go straight to the most reliable fix.
- **Only research hypotheses you can test locally.**
