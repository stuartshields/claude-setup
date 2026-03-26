<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Discipline

## IMPORTANT: Complete Implementations
- **Implement fully or flag to the user.** Write real logic in every function. If genuinely blocked, say so — do not silently skip it.
- **Handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async op needs loading + error states.
- **Edge cases you notice are part of the implementation.** Handle them before moving on. Noticing and leaving is incomplete work.

## IMPORTANT: Do Not Pivot to Avoid Hard Work
- **"Simpler approach" is not an escape hatch.** If the correct fix requires rebuilding a function or restructuring logic — do that. Pivoting to a workaround is avoidance, not simplicity.
- **Workarounds are not fixes.** Fix the root cause unless the user explicitly asks for a workaround. No workaround chains — each one creates the next bug.

## Pattern Discovery
- **Search the codebase for existing patterns before creating anything.** Grep/Glob for: API calls, error handling, naming conventions.
- **Copy the nearest similar example** as a template. Existing files carry non-obvious conventions that grep won't surface.

## Regression Awareness
- **Check all callers before changing a function.** Use Grep to find every call site. Update every consumer when you rename, move, or change an interface.

## IMPORTANT: Verify Before Declaring Done
- **Run build/tests and confirm they pass before claiming completion.**
- **Provide complete, syntactically correct code.** Resolve all imports. Verify API methods exist before using them.
- **Challenge the spec if it doesn't add up.** Flag contradictory or ambiguous requirements before building.

## Context Discipline
- **Read only files the current task requires.** Delegate broad investigation to subagents.
- **Trust the compaction summary.** Do not re-read files that were summarised. Read only the specific detail you need.
- **Re-read the user's request after gathering context.** Understanding drifts during investigation.
