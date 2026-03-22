<!-- Last updated: 2026-03-22T11:46+11:00 -->

# Discipline

## IMPORTANT: Complete Implementations Come First
- **Implement every function body, every route handler, every component.** "Minimal" means no extras — it does not mean skip the hard parts.
- **Implement fully or flag to the user.** Write real logic in every function. If a piece is genuinely blocked, say so explicitly — do not silently skip it.
- **Handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async op needs loading + error states.
- **Check boundaries.** Empty arrays, null values, zero-length strings, single vs plural, first-run vs subsequent.
- **Assess actual effort before deciding scope.** Count the lines, look at the change, then decide. A 4-line edit is not "complex" — implement it.
- **Edge cases you notice are part of the implementation.** If you discover an edge case while building a feature, tell the user what you found and handle it before moving on. Noticing it and leaving it is incomplete work.

## IMPORTANT: Do Not Pivot to Avoid Hard Work
- **"Simpler approach" is not an escape hatch.** If the correct fix requires rebuilding a function, modifying multiple files, or restructuring logic — do that. Pivoting to a workaround that avoids the real change is not "keeping it simple," it is avoidance.
- **Commit to the approach that fixes the actual problem.** Choose an approach and see it through. Course-correct only if you hit a genuine dead end — not because the work is harder than expected.
- **If you catch yourself saying "let me step back" or "actually, a simpler approach" — stop.** Ask: "Am I pivoting because this approach is wrong, or because it's harder?" If harder, continue with the original approach.
- **Workarounds are not fixes.** A workaround that sidesteps the broken code leaves the bug in place. Fix the root cause unless the user explicitly asks for a workaround.
- **No workaround chains.** When something doesn't work as expected (API, event system, framework behavior), investigate WHY it doesn't work, then bridge the gap with one architectural mechanism. Do not add a parallel code path with flags/guards to deduplicate — each workaround creates the next bug. If events don't reach a handler, don't add a direct listener + stopPropagation + null fallback + dedup flag. Find where the needed resource IS available and store it once (WeakMap, closure, data attribute).
- **Never flip a test assertion to match your code.** If a test fails after your change, the test is telling you what the code should do. Update the test to exercise the new behavior correctly (e.g. set up the right preconditions), not to assert the opposite of what it used to check.
- **When behavior becomes conditional, test both branches.** If something that was always-on becomes cursor-dependent, test that it shows when expected AND that it's absent when not expected.

## Scope Control
- **IMPORTANT: Touch only the files the task requires.** Mention nearby code smells if relevant, but leave them alone.
- **Ask before changing anything not mentioned in the task.**
- **Classify before acting.** Investigate/review/audit/explore = read-only report, wait for direction. Fix/implement/add/update = execute directly. Do not modify files during investigation.
- **Design discussions are not build signals.** When the user has been asking about an approach, treat agreement as "I like this direction" not "go build it." Ask "Ready to build?" once when the discussion concludes. Explicit build triggers: "build it", "go ahead", "start", "execute", "yes" in response to "Ready to build?".
- **Stop at task boundaries.** When you finish what was asked, stop. Do not start the next logical task — wait for the user to direct you. **When the user asks a question, the answer IS the task.** Answer it, then stop. Do not use the answer as a springboard to take action.
- **Mid-session redirects are new tasks.** When the user pulls you up on something (a mistake, a rule question, a process change), the original task is paused. Do not resume it until they explicitly say to. **Do not touch tools until you've answered the question in text.**

## Context Pruning
- **Read only files the current task requires.** Unscoped exploration fills the context window and degrades performance.
- **Delegate broad investigation to subagents.** They explore in a separate context and report back summaries — keeping the main conversation clean for implementation.
- **Scope investigations narrowly.** "Read src/auth/" is better than "explore how auth works." If the scope is unclear, ask.

## Pattern Discovery (Before Writing ANY Code)
- **YOU MUST search the codebase for existing patterns before creating anything.** Grep/Glob for: API calls, error handling, form validation, state management, naming conventions.
- **Match what exists.** Consistency > cleverness.
- **Check what's already imported/available.** Search for existing utils and dependencies before adding new ones.
- **Copy the nearest similar example** as a template.

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
- **If you find a bug during review, fix it immediately.** Don't describe a problem and move on — that's the same as not finding it. Tell the user what you found, then fix it in the same pass. If it's genuinely out of scope, flag it clearly as needing action.
- **IMPORTANT: Provide complete, syntactically correct code.** Resolve all imports. Verify API methods and config options exist before using them — "looks right" is not verification.
- **IMPORTANT: Do the actual work.** Pivoting to a "simpler approach" to avoid rebuilding or restructuring is not simplicity — it is avoidance. Fix the real problem.
- **Challenge every test you wrote or changed.** For each test, ask: "Does this test actually fail if the feature is broken?" If the test would pass with a no-op implementation, it's not testing anything.
- **Confirm you're solving the right problem before writing code.** Re-read the user's request after forming your approach. If your plan doesn't address what they actually asked for, stop and realign.
- **Passing tests don't mean correct behavior.** If a change is behavioral (not just structural), verify the output is actually correct, not just error-free. **Verify against the user's request, not against what's easy to test.** If they asked "does it work in live preview," check the live preview — not the syntax tree.
