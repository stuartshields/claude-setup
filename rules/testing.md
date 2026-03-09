# Testing

## Test-First Mandate
- **Before implementing:** Write a FAILING test that documents the expected behavior.
- Run the test to confirm it fails. This proves the test is real, not vacuous.
- **Verify it fails for the right reason.** A test that fails with "module not found" proves nothing. The assertion itself must fail - meaning the test runs, reaches the assertion, and the expected value doesn't match.
- After implementation, run the full test suite to catch regressions.

## Test Against the Spec, Not the Implementation
- **Write tests from the requirement, not from the code.** If you've already read the implementation, you'll unconsciously write tests that mirror it - testing that the code does what it does, not what it should do.
- **Test behavior, not internals.** Assert on outputs, side effects, and observable state. Don't assert on private methods, internal data structures, or implementation details that could change without affecting correctness.
- **Mutation check:** After tests pass, mentally (or actually) break the implementation - change a `>` to `>=`, remove an edge case guard, swap an AND for an OR. If the tests still pass, they're not testing what they claim.

```
Bad:  assert(result.internalCache.size === 3)  // testing internals
Good: assert(getItems().length === 3)           // testing behavior
```

## When Tests Pass But Code Has Bugs
- **If the user says it's broken, the tests are wrong - not the user.** Passing tests only prove the tests pass, not that the code works.
- **Stop and re-examine the tests.** Are they mocking something that behaves differently in production? Are they testing at the wrong layer? Are they asserting the wrong thing?
- **Write a new test that reproduces the user's exact scenario** before attempting another fix. If you can't reproduce it in a test, you don't understand the bug yet.
- **Never repeat the same fix.** If the first approach didn't work, the root cause is different from what you assumed. Re-read the code, re-trace the data flow, form a new hypothesis.

## Mock Skepticism
- **Prefer real dependencies over mocks.** Every mock is an assumption that the real thing behaves a certain way. If the assumption is wrong, the test passes and the code breaks.
- **Never mock what you're testing.** If you mock the database and the bug is in the query, the test can't catch it.
- **Mocks are acceptable for:** external APIs (network), time/dates, randomness, and third-party services you don't control. For everything else, use the real thing or an in-memory equivalent.
- **If a test requires more than 3 mocks, the design is wrong.** The code under test has too many dependencies - refactor before testing.

## Test Quality
- **AAA pattern:** Arrange (setup) → Act (call function) → Assert (verify result).
- **One assertion per test** when possible (exceptions: related invariants).
- **Naming:** Test names are documentation.
	- Bad: "should work", "returns data"
	- Good: "should validate email with correct format", "returns cafes sorted by distance ascending"

## Stack-Specific
> Match the project's existing test patterns. These are defaults - if the project does it differently, follow the project.

- **Vue composables:** Test the return object and side effects, not the component using it.
- **API routes:** Test success case, error cases, edge cases (empty input, malformed, auth failure).
- **WordPress/PHP:** Test with WP_UnitTestCase or PHPUnit. Use `$this->factory()` for test data. Assert filters/actions fire with expected args.
- **CLI scripts:** Test with real (or stubbed) I/O. Assert exit codes, stdout output, and side effects (files created, DB rows written).
- **No skipped tests:** Never ship with `it.skip` or `it.todo` without a tracking comment explaining why.
