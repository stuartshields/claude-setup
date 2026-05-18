---
name: debugging
description: Structured debugging protocol. Use when investigating a bug, failing test, regression, unexpected behavior, or any scenario where code is not doing what it should. Trigger phrases include "broken", "not working", "bug", "error", "it worked before", "still broken", "why is this failing", "trace", or "/trace".
---
<!-- Last updated: 2026-04-08T00:00+11:00 -->

# Debugging & Investigation

## 4-Step Framework: Reproduce → Isolate → Fix → Validate
- **Never skip to Fix.** Most wrong fixes come from jumping straight to code changes.
- **Reproduce:** Run the faulty scenario. Note the exact error and conditions.
- **Isolate:** Narrow down the failing component. 80% of bugs live in recently modified code — start there. **Compare against working code.** Find similar functionality that works and diff against the broken code.
- **Validate:** Run the full test suite. Confirm the error is gone AND no regressions introduced.

## Validate Before Fixing
- **Confirm root cause before proposing code changes.** One hypothesis at a time — test the most likely first.
- **Explain root cause in writing** (file path, line number, actual vs expected behavior) before proposing code changes.
- **Test means run code, not reason in your head.** Execute a command, write a failing test, or check real output.
- **Read the user's evidence first.** Study screenshots/errors before forming hypotheses. The answer is usually visible.
- **Add `console.error` to trace actual behavior** when reasoning about what code "should" do isn't working. Reading code is not observing behavior.
- **Red flag phrases.** Catch yourself saying "This should work", "Let me just try...", or "Quick fix for now" — stop and re-evaluate. You're guessing.

## Anti-Loop Protocol
- **Each attempt MUST use a different diagnosis.** If attempt 1 failed, don't vary the fix — vary the diagnosis. Two attempts targeting the same component with the same assumption count as one diagnosis, even if the code changes differ.
- **After 2 failed fix attempts, STOP.** State what you tried, what each ruled out, and ask the user for context. If the user says "still broken" twice, you've failed twice.
- **Clear polluted context.** After hitting the limit, recommend `/clear` — failed attempts in context actively degrade subsequent reasoning.
- **Watch for oscillation.** Fixing A breaks B and vice versa = contradictory constraints. Stop and surface the conflict.
- **Revert as escape hatch.** When debugging spirals, revert to last known good commit rather than stacking fixes on failed attempts.

## Regression Shortcut
- **"It worked before" → `git bisect` first.** Don't read code to find regressions — bisect to the breaking commit, then read that diff.
