# Testing

## Test-First Mandate
- **Before implementing:** Write a FAILING test that documents the expected behavior.
- Run the test to confirm it fails. This proves the test is real, not vacuous.
- After implementation, run the full test suite to catch regressions.

## Test Quality
- **AAA pattern:** Arrange (setup) → Act (call function) → Assert (verify result).
- **One assertion per test** when possible (exceptions: related invariants).
- **Naming:** Test names are documentation.
	- Bad: "should work", "returns data"
	- Good: "should validate email with correct format", "returns cafes sorted by distance ascending"

## Stack-Specific
> Match the project's existing test patterns. These are defaults — if the project does it differently, follow the project.

- **Vue composables:** Test the return object and side effects, not the component using it.
- **API routes:** Test success case, error cases, edge cases (empty input, malformed, auth failure).
- **WordPress/PHP:** Test with WP_UnitTestCase or PHPUnit. Use `$this->factory()` for test data. Assert filters/actions fire with expected args.
- **CLI scripts:** Test with real (or stubbed) I/O. Assert exit codes, stdout output, and side effects (files created, DB rows written).
- **No skipped tests:** Never ship with `it.skip` or `it.todo` without a tracking comment explaining why.
