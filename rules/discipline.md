# Discipline

## Scope Control
- **IMPORTANT: Do exactly what was asked.** No bonus refactors, no "while I'm here" improvements, no adding features that weren't requested.
- **IMPORTANT: Touch only the files the task requires.** If a nearby file has a code smell, leave it. Mention it if relevant, but don't fix it uninvited.
- **If you're about to change something not mentioned in the task, stop and ask.** The user may have context you don't.

## Pattern Discovery (Before Writing ANY Code)
- **YOU MUST search the codebase for existing patterns before creating anything.** Use Grep/Glob to find how the project already handles: API calls, error handling, form validation, state management, component structure, naming conventions.
- **YOU MUST match what exists.** If the project uses a specific pattern for API error handling, use the same pattern — even if you know a "better" way. Consistency > cleverness.
- **Check what's already imported/available.** Before writing a utility function, search for existing utils. Before adding a dependency, check if the project already has one that does the same thing.
- **Copy the nearest similar example.** Find the most similar existing feature and use it as a template. Don't invent from scratch when a pattern exists.

## Anti-Over-Engineering
- **IMPORTANT: No premature abstractions.** Three similar lines of code is better than a helper function used once. Only abstract when you have 3+ real call sites.
- **No speculative error handling.** Don't add try/catch for scenarios that can't happen in the current code path. Trust internal code and framework guarantees.
- **No unnecessary indirection.** Don't create a wrapper around a function that already has a clean API. Don't add a config option for something with only one valid value.
- **No "just in case" code.** If a parameter is always a string, don't add type coercion "just in case." If a function is only called from one place, don't make it generic.

## Complete Implementations
- **IMPORTANT: No TODO comments in shipped code.** If something can't be implemented now, say so — don't leave a placeholder.
- **YOU MUST handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async operation needs a loading and error state.
- **Edge cases matter.** Empty arrays, null values, zero-length strings, single items vs plural, first-run vs subsequent. Check what happens at the boundaries.
- **Don't implement only the happy path and call it done.** If you built the success flow, build the error flow before moving on.

## Regression Awareness
- **Before changing a function, check all its callers.** Use Grep to find every call site. Changes that break callers are worse than no change at all.
- **Run existing tests after every logical change** — not just at the end. Catch regressions early.
- **If you rename, move, or change an interface, update every consumer.** Don't leave broken imports or stale references.
- **When fixing a bug, verify the original behavior still works** in the areas you didn't touch. Targeted fixes should not have collateral damage.
