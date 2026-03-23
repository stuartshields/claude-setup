---
paths: "**/*.test.*,**/*.spec.*,**/__tests__/**,**/test/**,**/tests/**,**/*.js,**/*.ts,**/*.tsx,**/*.jsx,**/*.py,**/*.php,**/*.go,**/*.rs"
---
<!-- Last updated: 2026-03-23T10:30+11:00 -->

# Testing

## Test-First Mandate
- **Write a FAILING test before implementing.** Run it to confirm the assertion itself fails — "module not found" proves nothing.
- **Test the core user-facing behavior first.** The primary feature gets tested before edge cases, error paths, or peripheral features. If the app's purpose is posting, test posting first.
- After implementation, run the full test suite to catch regressions.

## Test Against the Spec
- **Write tests from the requirement, not the code.** Test behavior and observable state — not private methods or internal data structures.
- **Mutation check:** After tests pass, mentally break the implementation (flip `>` to `>=`, remove a guard). If tests still pass, they're weak.

## When Tests Pass But Code Has Bugs
- **Trust the user over the tests.** Passing tests prove the tests pass, not that the code works.
- **Re-examine test assumptions.** Are mocks hiding real behavior? Testing at the wrong layer? Asserting the wrong thing?
- **Reproduce the user's exact scenario in a new test** before attempting another fix. If you can't reproduce it, you don't understand the bug.

## Mock Discipline
- **Prefer real dependencies.** Every mock is an assumption — if wrong, the test passes and the code breaks.
- **Mock only:** external APIs (network), time/dates, randomness, third-party services.
- **If a test needs 3+ mocks, consider whether the design needs refactoring** — but don't block on it.

## Test Loops
- **A test that fails after your change is a signal, not an obstacle.** Read what the test asserts. Understand what the code should do. Fix the code or update the test preconditions — never flip the assertion to match your code.
- **Do not retry failing tests hoping they pass.** A failing test is information. Diagnose why it fails — do not re-run it, adjust the assertion, or add a retry. If a test is flaky, fix the flakiness, don't suppress it.
- **Do not write test infrastructure to catch a bug you can't reproduce.** Two rounds of failed reproduction means you're missing context. Ask the user — don't keep building scaffolding.
- **Run tests after every logical change** — not just at the end.
- **When behavior becomes conditional, test both branches.** If something that was always-on becomes cursor-dependent, test that it shows when expected AND that it's absent when not expected.

## Test Quality
- **AAA pattern:** Arrange -> Act -> Assert.
- **One behavior per test.** Multiple assertions are fine if they verify the same behavior.
- **Test names are documentation.** Bad: "should work". Good: "returns cafes sorted by distance ascending".

## Stack-Specific Defaults
> Match the project's existing patterns. These are overridden by project conventions.

- **Vue composables:** Test the return object and side effects.
- **API routes:** Test success, errors, and edge cases (empty input, malformed, auth failure).
- **WordPress/PHP:** WP_UnitTestCase, `$this->factory()` for test data, assert filters/actions fire.
- **CLI:** Assert exit codes, stdout, and side effects.
- Ship with zero `it.skip` or `it.todo` unless tracked with a comment.
