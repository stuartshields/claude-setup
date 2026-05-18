<!-- Last updated: 2026-05-19T12:00+10:00 -->

# Discipline

## IMPORTANT: Complete Implementations
- **Implement fully or flag to the user.** Write real logic in every function. If genuinely blocked, say so — do not silently skip it.
- **Handle the unhappy path.** Every API call needs error handling. Every form needs validation. Every async op needs loading + error states.
- **Edge cases you notice are part of the implementation.** Handle them before moving on. Noticing and leaving is incomplete work.

## IMPORTANT: Surface, Don't Dismiss
- **Issues you notice outside your task MUST be surfaced — not silently skipped, not silently fixed.** Name them in your response with `file:line` and let the user choose whether to handle them now, later, or never.
- **These phrases mean you decided for the user — surface instead**: `pre-existing`, `unrelated`, `out of scope`, `not part of this task/PR`, `I'll leave that alone`. They're fine AFTER you've surfaced; they're a red flag when used to skip surfacing. Bypassing user judgement is how a fix silently ships a regression.
- **Notice → flag → ask.** When you choose not to act on a finding, say what you noticed, where, and why you're not acting — then ask. Don't bury it as a parenthetical or omit it entirely.
- **Silently expanding scope is the mirror failure.** "Fixing it while I'm here" loses user judgement the same way silent dismissal does. Stay in scope; flag the adjacent finding separately.
- **Boy-scout the surface, not the diff.** When editing a file, scan ±20 lines for obvious decay (dead imports, magic numbers, commented-out blocks, naming drift). Surface what you see in the response — don't widen the edit to fix them. The user picks what to action.

## IMPORTANT: Don't Manufacture Findings
- **A clean audit/review is valid — don't invent findings to fill tiers.** Confidence gate: ≥80% sure with `file:line` and a concrete failure mode, or drop. Speculation belongs in "Suggested follow-ups", not findings. **Mirror to Surface, Don't Dismiss:** surface what you *actually* see, don't invent what you didn't. See `audit-vs-fix-discipline` skill for the full calibration check.

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
