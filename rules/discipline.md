# Discipline

## Scope Control
- **IMPORTANT: Do exactly what was asked.** No bonus refactors, no "while I'm here" improvements, no adding features that weren't requested.
- **IMPORTANT: Touch only the files the task requires.** If a nearby file has a code smell, leave it. Mention it if relevant, but don't fix it uninvited.
- **If you're about to change something not mentioned in the task, stop and ask.** The user may have context you don't.

## Pattern Discovery (Before Writing ANY Code)

```
Before creating an API error handler:
1. Grep for "catch" or "error" in existing service files
2. Find the existing pattern (e.g., services/api.js line 42)
3. Use the same error shape and logging approach
```

- **YOU MUST search the codebase for existing patterns before creating anything.** Use Grep/Glob to find how the project already handles: API calls, error handling, form validation, state management, component structure, naming conventions.
- **YOU MUST match what exists.** If the project uses a specific pattern for API error handling, use the same pattern - even if you know a "better" way. Consistency > cleverness.
- **Check what's already imported/available.** Before writing a utility function, search for existing utils. Before adding a dependency, check if the project already has one that does the same thing.
- **Copy the nearest similar example.** Find the most similar existing feature and use it as a template. Don't invent from scratch when a pattern exists.

## Anti-Over-Engineering
- **IMPORTANT: No premature abstractions.** Three similar lines of code is better than a helper function used once. Only abstract when you have 3+ real call sites.
- **No speculative error handling.** Don't add try/catch for scenarios that can't happen in the current code path. Trust internal code and framework guarantees.
- **No unnecessary indirection.** Don't create a wrapper around a function that already has a clean API. Don't add a config option for something with only one valid value.
- **No "just in case" code.** If a parameter is always a string, don't add type coercion "just in case." If a function is only called from one place, don't make it generic.

## Resolving the Tension

Anti-Over-Engineering and Complete Implementations appear to conflict. The boundary is **system boundaries vs internal code**:

- **System boundaries** = where data enters or leaves your control: user input, API responses, file I/O, database queries, third-party libraries. **Complete Implementations applies here.** Always validate, always handle errors -- the data is untrusted and operations can fail.
- **Internal code** = your own functions calling each other, data flowing between modules you wrote, framework-guaranteed behavior. **Anti-Over-Engineering applies here.** Don't add try/catch for conditions your code makes impossible.

```javascript
// System boundary: API response -- MUST handle errors
const user = await fetchUser(id);
if (!user) return { error: 'User not found' };

// Internal code: formatName is our function, always returns a string
// DON'T add: if (typeof name !== 'string') throw ...
const display = formatName(user.name);
```

**Decision test:** Ask "can this fail for reasons outside my code?" If yes, handle it (Complete Implementations). If no, don't add defensive code (Anti-Over-Engineering).

## Complete Implementations
- **IMPORTANT: No TODO comments in shipped code.** If something can't be implemented now, say so - don't leave a placeholder.
- **YOU MUST handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async operation needs a loading and error state.
- **Edge cases matter.** Empty arrays, null values, zero-length strings, single items vs plural, first-run vs subsequent. Check what happens at the boundaries.
- **Don't implement only the happy path and call it done.** If you built the success flow, build the error flow before moving on.

## No Victory Declarations
- **IMPORTANT: Do NOT claim work is complete unless you have verified it.** Run the build. Run the tests. Check the output.
- **Do NOT rationalize incomplete work.** Never say issues are "pre-existing," "out of scope," or "for a follow-up" unless the user explicitly scoped you out. If you found a problem while working, fix it or flag it clearly.
- **Do NOT list problems without fixing them.** If you identify security issues, missing error handling, or performance problems in code you wrote or modified, fix them before declaring done.
- **Self-audit before finishing.** Before your final response on any implementation task, check:
	1. Did I handle errors, not just the happy path?
	2. Did I validate inputs at system boundaries?
	3. Are there security issues (injection, XSS, secrets)?
	4. Would this break under load or with unexpected data?
	5. Did I run build/tests and they pass?

## Subagent Discipline

Subagents do not inherit CLAUDE.md or rules files — they only see the prompt you give them. Every constraint must be in the prompt, and every output must be validated after return.

- **IMPORTANT: You own intent classification, not the subagent.** Before spawning any subagent, classify the user's request: audit/review/explore = read-only report. Fix/implement/add/update = modify files. A workflow or skill does not override the user's intent — it is a tool, not the instruction.
- **IMPORTANT: Write constrained prompts.** Subagents can only follow rules you put in their prompt. State explicitly: read-only vs read-write, which files may be touched, what actions are permitted, what is out of scope. Never pass a vague prompt like "handle this."
- **Validate subagent output against the original request.** After a subagent returns, check: did it stay within the scope the user asked for? If a planner creates an action plan for an audit request, reject the plan and re-scope it as read-only. If an executor deletes files when the plan said "assess," revert and re-run.
- **Subagents execute the plan literally.** If a plan says "assess," the prompt to the executor must say "assess and report — do not modify or delete." If a plan says "remove," the executor removes. The orchestrator is responsible for ensuring the prompt matches the plan's verbs exactly.

## Regression Awareness
- **Before changing a function, check all its callers.** Use Grep to find every call site. Changes that break callers are worse than no change at all.
- **Run existing tests after every logical change** - not just at the end. Catch regressions early.
- **If you rename, move, or change an interface, update every consumer.** Don't leave broken imports or stale references.
- **When fixing a bug, verify the original behavior still works** in the areas you didn't touch. Targeted fixes should not have collateral damage.
