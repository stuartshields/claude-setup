<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Debugging & Investigation

## 4-Step Framework: Reproduce → Isolate → Fix → Validate
- **Never skip to Fix.** Most wrong fixes come from jumping straight to code changes.
- **Reproduce:** Run the faulty scenario. Note the exact error and conditions.
- **Isolate:** Narrow down the failing component. 80% of bugs live in recently modified code — start there.
- **Validate:** Run the full test suite. Confirm the error is gone AND no regressions introduced.

## Validate Before Fixing
- **Confirm root cause before proposing code changes.** One hypothesis at a time — test the most likely first.
- **Test means run code, not reason in your head.** Execute a command, write a failing test, or check real output.
- **Read the user's evidence first.** Study screenshots/errors before forming hypotheses. The answer is usually visible.
- **Add `console.error` to trace actual behavior** when reasoning about what code "should" do isn't working. Reading code is not observing behavior.

## Anti-Loop Protocol
- **Each attempt MUST use a different diagnosis.** If attempt 1 failed, don't vary the fix — vary the diagnosis.
- **After 2 failed fix attempts, STOP.** State what you tried, what each ruled out, and ask the user for context. If the user says "still broken" twice, you've failed twice.
- **Watch for oscillation.** Fixing A breaks B and vice versa = contradictory constraints. Stop and surface the conflict.
