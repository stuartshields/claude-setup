<!-- Last updated: 2026-03-23T10:30+11:00 -->

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
- **Test means run code, not reason in your head.** "Testing" a hypothesis means executing a command, writing a failing test, or checking real output. Ruling something out by thinking about it is not testing — it's guessing.
- **Every hypothesis must be followed by a tool call or a question to the user.** If you cannot test a hypothesis with a tool (grep, test, console.error, browser), ask the user to verify it instead. Reasoning through a second hypothesis without validating the first is speculation, not investigation.
- **Read the user's evidence first.** When the user provides a screenshot, error message, or reproduction — study it before forming any hypothesis. The answer is usually visible in what they showed you.
- **If you can't reproduce the issue in tests, say so.** Don't keep writing more test infrastructure hoping to catch it. Tell the user what you've verified works and ask them to confirm what they're seeing. Two rounds of failed reproduction means you're missing context — ask, don't guess.
- **Every hypothesis needs a validation step.** State: (1) what you suspect, (2) how to confirm it, (3) expected output, (4) what it means if output differs.
- **Replace "maybe" and "possibly" with testable instrumentation.** Uncertainty means you need more data.
- **Add logging to trace actual behavior.** When reasoning about what code "should" do isn't working, add temporary `console.error` instrumentation to see what it actually does at runtime (never `console.log` — blocked by hook). Reading code is not observing behavior.
- **Assume your initial diagnosis is wrong.** Define what would falsify your hypothesis before testing it. An incorrect first hypothesis biases you against correct solutions found later — you'll dismiss them as "the same thing again."
- **GUI bugs need visible error reporting.** When fixing bugs in a GUI app where you can't run the UI interactively, add visible error reporting (error banners, console.error) so the user can report what they see. Don't assume a fix works without observable verification.
- **Search before assuming.** If a file path, variable, or architectural detail is not in context, use Glob/Grep to find it. Ask the user only if search fails.

## Deep-Trace Debugging
- **Trace the full data flow.** Use Grep to find parent components, context providers, and service layers. Explain the flow (e.g., `API -> Service -> Hook -> Component`) before proposing a fix.
- **Check ancestry.** The bug may not be in the file the user mentioned. Agents default to fixing the file they're pointed at, but the root cause is often in a parent component, service layer, or config that feeds into it.

## Anti-Loop Protocol
- **Each attempt MUST use a different approach.** If attempt 1 failed, your diagnosis was wrong — don't vary the fix, vary the diagnosis. Re-trace the data flow from scratch.
- **After 2 failed fix attempts, STOP.** Do not try a third variation. Instead: state what you've tried, what each attempt ruled out, and ask the user for more context or suggest a fundamentally different angle. Count by user feedback, not by your internal reasoning — if the user says "still broken" twice, you've failed twice regardless of whether each fix felt different to you.
- **Consider rebuilding instead of patching.** If the approach feels fundamentally broken — not just hard — recommend starting fresh on a clean worktree. After 2 failed attempts with an unclear root cause, rebuilding is faster than continuing to patch.
- **Watch for oscillation.** If fixing A breaks B and fixing B breaks A, the problem is contradictory constraints or a wrong mental model — not a code issue. Stop, identify the conflict, and surface it to the user.
- **Context pollution is real.** After 2 failed corrections in the same conversation, the context is polluted with wrong approaches. Recommend `/clear` and restate with lessons learned.
- **Watch for write-delete-rewrite.** If you write code, delete or revert it, then write substantially the same code again — you are oscillating, not iterating. The context contains contradictory constraints. Stop, identify which constraints conflict, and surface the conflict to the user.
- **Reverting your own change is a failed attempt.** Count it toward the 2-attempt limit even if no test ran. Writing code and undoing it means the approach was wrong — varying the same idea will not fix it.

## Visual / CSS Bugs
- **You cannot see rendered output.** Do not trace rendering pipelines in your head — you will always be guessing.
- **One-round proposal.** For visual bugs: (1) identify the most likely CSS/DOM cause from the code, (2) propose the fix with your reasoning, (3) ask the user to verify. If wrong, ask what they see — don't theorize further.
- **Screenshots are your only ground truth.** Study what the screenshot shows before reading code. The visual symptom narrows the search space more than tracing call chains.
- **Prefer CSS-level fixes over widget/DOM workarounds.** CSS properties (border, padding, background) apply uniformly across lines and states. Widget-level fixes (character rendering, inline spans) are fragile across fonts, line heights, and empty lines.

## Time-Box Root Cause Analysis
- **Check memory files and prior notes FIRST.** Start with documented untried approaches.
- **Skip root-cause isolation only when you truly can't observe the runtime** (e.g., native app crash with no logs). Even then, prefer adding `console.error` instrumentation over guessing (never `console.log` — blocked by hook).
- **Only research hypotheses you can test locally.**
- **After 8+ tool calls trying to reproduce the issue**, step back and summarize what you know. Ask the user if the reproduction steps are correct before continuing.
