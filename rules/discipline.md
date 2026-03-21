<!-- Last updated: 2026-03-21 -->

# Discipline

## IMPORTANT: Complete Implementations Come First
- **Implement every function body, every route handler, every component.** "Minimal" means no extras — it does not mean skip the hard parts.
- **Implement fully or flag to the user.** Write real logic in every function. If a piece is genuinely blocked, say so explicitly — do not silently skip it.
- **Handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async op needs loading + error states.
- **Check boundaries.** Empty arrays, null values, zero-length strings, single vs plural, first-run vs subsequent.
- **Assess actual effort before deciding scope.** Count the lines, look at the change, then decide. A 4-line edit is not "complex" — implement it.

## IMPORTANT: Do Not Pivot to Avoid Hard Work
- **"Simpler approach" is not an escape hatch.** If the correct fix requires rebuilding a function, modifying multiple files, or restructuring logic — do that. Pivoting to a workaround that avoids the real change is not "keeping it simple," it is avoidance.
- **Commit to the approach that fixes the actual problem.** Choose an approach and see it through. Course-correct only if you hit a genuine dead end — not because the work is harder than expected.
- **If you catch yourself saying "let me step back" or "actually, a simpler approach" — stop.** Ask: "Am I pivoting because this approach is wrong, or because it's harder?" If harder, continue with the original approach.
- **Workarounds are not fixes.** A workaround that sidesteps the broken code leaves the bug in place. Fix the root cause unless the user explicitly asks for a workaround.

## Scope Control
- **IMPORTANT: Do exactly what was asked.** No bonus refactors, no "while I'm here" improvements.
- **IMPORTANT: Touch only the files the task requires.** Mention nearby code smells if relevant, but leave them alone.
- **Ask before changing anything not mentioned in the task.**

## Pattern Discovery (Before Writing ANY Code)
- **YOU MUST search the codebase for existing patterns before creating anything.** Grep/Glob for: API calls, error handling, form validation, state management, naming conventions.
- **Match what exists.** Consistency > cleverness.
- **Check what's already imported/available.** Search for existing utils and dependencies before adding new ones.
- **Copy the nearest similar example** as a template.

## Anti-Over-Engineering
- **Abstract only when 3+ real call sites exist.** Three similar lines beats a helper used once.

## System Boundaries vs Internal Code
- **System boundaries** (user input, APIs, file I/O, third-party libs): always validate and handle errors.
- **Internal code** (your own functions, framework-guaranteed behavior): trust the types, skip defensive code.
- **Decision test:** "Can this fail for reasons outside my code?" Yes -> handle it. No -> skip defensive code.

## Regression Awareness
- **Check all callers before changing a function.** Use Grep to find every call site.
- **Run tests after every logical change** — not just at the end.
- **Update every consumer** when you rename, move, or change an interface.
- **Verify untouched behavior still works** after a targeted fix.

## Subagent Discipline
- **IMPORTANT: Classify intent before spawning.** Audit/review/explore = read-only report. Fix/implement/add = modify files.
- **Write constrained prompts.** State: read-only vs read-write, which files, what actions, what's out of scope.
- **Validate output against the original request.** Reject if scope was exceeded.
- **Match prompt verbs to plan verbs.** "Assess" in the plan = "assess and report, do not modify" in the prompt.

## Hook Awareness
- **Commit Blocking:** PreToolUse hook blocks `git commit` and destructive Bash commands. Tell the user to commit manually.
- **PERF WARNING:** Stop your current approach. You are in a loop. Re-read relevant code, form a new hypothesis, try a different approach.
- **Post-Write File State:** Hooks may modify file contents after Write (formatting, tracking). Always re-read before using Edit — the file on disk may differ from what you wrote.
- **Not all hooks are in settings.json.** Some hook scripts (agent-guard-*.sh, drift-review-stop.sh, stop-quality-check.sh) are registered in agent frontmatter or called as sub-hooks by dispatchers like stop-dispatcher.sh. Their absence from settings.json is intentional — do not flag them as orphaned or suggest registering them.

## IMPORTANT: Verify Before Declaring Done
- **Run build/tests and confirm they pass before claiming completion.**
- **Self-check for completeness:** Re-read every file you wrote or edited. Verify every function has a real implementation body — not a stub, not a TODO, not a placeholder. If you wrote a function signature, you wrote the logic inside it.
- **Fix problems you find — or flag them clearly.**
- **IMPORTANT: Provide complete, syntactically correct code.** Resolve all imports. Verify API methods and config options exist before using them — "looks right" is not verification.
- **IMPORTANT: Do the actual work.** Pivoting to a "simpler approach" to avoid rebuilding or restructuring is not simplicity — it is avoidance. Fix the real problem.
