# Debugging & Investigation

## Deep-Trace Debugging
- **Step Through the Code:** Never debug a file in isolation.
- **Ancestry Check:** Use Grep to find parent components, context providers, or service layers that feed data to the affected file.
- **Verification:** Before proposing a fix, explain the data flow (e.g., `API -> Service -> Hook -> Component`).
- **No Guessing:** If unsure of a dependency, use Glob or Grep to find it. Do not assume the bug is only in the file the user mentioned.

## Investigation Over Assumption
- **No Guessing Rule:** If a file path, variable name, or architectural detail is not in your current context, you MUST NOT assume its state.
- **Interview Protocol:** If the user's request is ambiguous (e.g., "Fix the login"), ask 2-3 targeted questions before proposing a plan.
- **Search First Mandate:** Before stating something "doesn't exist," use Glob (file search) or Grep (content search). If still not found, ask the user.
- **Hypothesis Testing:** When debugging, state your hypothesis first: "I suspect X, but I need to verify Y by reading [File Z]."

## Tests Pass ≠ Bug Fixed
- **If the user says it's not fixed, the tests are wrong — not the user.** Passing tests only prove the tests pass, not that the bug is resolved.
- **Widen the investigation:** The existing tests likely don't cover the actual reproduction path. Ask the user for exact steps to reproduce, then trace that specific path through the code.
- **Check test assumptions:** Are the tests mocking something that behaves differently in real usage? Are they testing the right input/state? Are they testing at the wrong layer (unit test passes but integration is broken)?
- **Never repeat the same fix.** If your first approach didn't work, the root cause is different from what you assumed. Go back to Phase 1 — re-read the code, re-trace the data flow, form a new hypothesis.
- **Write a new test that reproduces the user's exact scenario** before attempting another fix. If you can't reproduce it in a test, you don't understand the bug yet.
