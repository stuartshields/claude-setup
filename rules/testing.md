# Testing

## Test-First Mandate
- **Write a FAILING test before implementing.** Run it to confirm the assertion itself fails — "module not found" proves nothing.
- After implementation, run the full test suite to catch regressions.

## Test Against the Spec
- **Write tests from the requirement, not the code.** Test behavior and observable state — not private methods or internal data structures.
- **Mutation check:** After tests pass, mentally break the implementation (flip `>` to `>=`, remove a guard). If tests still pass, they're weak.

## When Tests Pass But Code Has Bugs
- **Trust the user over the tests.** Passing tests prove the tests pass, not that the code works.
- **Re-examine test assumptions.** Are mocks hiding real behavior? Testing at the wrong layer? Asserting the wrong thing?
- **Reproduce the user's exact scenario in a new test** before attempting another fix. If you can't reproduce it, you don't understand the bug.
- **Try a different fix each time.** If the first approach failed, the root cause differs from your assumption. Re-trace the data flow.

## Mock Discipline
- **Prefer real dependencies.** Every mock is an assumption — if wrong, the test passes and the code breaks.
- **Mock only:** external APIs (network), time/dates, randomness, third-party services.
- **If a test needs 3+ mocks, the design needs refactoring.**

## Test Quality
- **AAA pattern:** Arrange -> Act -> Assert.
- **One assertion per test** (exceptions: related invariants).
- **Test names are documentation.** Bad: "should work". Good: "returns cafes sorted by distance ascending".

## Stack-Specific Defaults
> Match the project's existing patterns. These are overridden by project conventions.

- **Vue composables:** Test the return object and side effects.
- **API routes:** Test success, errors, and edge cases (empty input, malformed, auth failure).
- **WordPress/PHP:** WP_UnitTestCase, `$this->factory()` for test data, assert filters/actions fire.
- **CLI:** Assert exit codes, stdout, and side effects.
- Ship with zero `it.skip` or `it.todo` unless tracked with a comment.
