# Discipline

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
- **Add error handling only for scenarios that can actually occur.** Trust internal code and framework guarantees.
- **Skip wrappers around clean APIs and config options with only one valid value.**
- **Build for current requirements only.** If a parameter is always a string, skip type coercion.

## System Boundaries vs Internal Code
- **System boundaries** (user input, APIs, file I/O, third-party libs): always validate and handle errors.
- **Internal code** (your own functions, framework-guaranteed behavior): trust the types, skip defensive code.
- **Decision test:** "Can this fail for reasons outside my code?" Yes -> handle it. No -> skip defensive code.

## Complete Implementations
- **Implement fully or flag to the user.** No TODO placeholders in shipped code.
- **Handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async op needs loading + error states.
- **Check boundaries.** Empty arrays, null values, zero-length strings, single vs plural, first-run vs subsequent.

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

## IMPORTANT: Verify Before Declaring Done
- **Run build/tests and confirm they pass before claiming completion.**
- **Fix problems you find — or flag them clearly.** Issues are not "pre-existing" or "out of scope" unless the user scoped you out.
- **Self-audit:** Errors handled? Inputs validated at boundaries? Security issues? Runs under load?
