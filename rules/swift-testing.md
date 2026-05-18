---
paths: "**/*.swift"
---
<!-- Last updated: 2026-05-10T20:55+10:00 -->

# Swift Testing Hygiene

Swift-specific test rules. Apply when writing tests in the `Testing` framework
(`@Test`, `#expect`, `#require`, `Issue.record`) or XCTest. Sit on top of the
general rules in `testing.md`.

## No Force-Unwraps in Test Code
- **`Bundle.module.url(...)!`, `try!`, `as!` are forbidden.** A force-unwrap that traps gives the runner a SIGABRT and a stack — but no readable diagnostic explaining what was missing. Tests must fail with a message a human can act on.
- **Pattern:** `guard let url = Bundle.module.url(forResource: name, withExtension: nil) else { Issue.record("fixture '\(name)' missing"); return Data() }`.
- Same applies to any test setup that CAN fail: handle the nil case with `Issue.record(...)` + early return, even if "it's always true in practice".

## No `Task.sleep` for Absence Assertions
- **Anti-pattern:** `try? await Task.sleep(...); #expect(count == 0)`. The sleep is flake bait — slower CI shifts the timing and the assertion passes for the wrong reason.
- **For arrival assertions:** use a polled wait helper (project-specific — typically `waitUntilMain`, `eventually`, etc.) that resolves as soon as the condition holds.
- **For absence assertions:** assert on the **post-state that would have changed** if the thing under test had fired. If a peer disappearance should NOT be emitted, drive the next legitimate event after it and assert THAT was first — not "wait 100ms then assert nothing arrived".

## TestClock, Not Wall Clock
- **`TestClock` (or equivalent fake clock) for any timer-dependent test.** Drive time with `TestClock.advance(by:)` so the test runs in microseconds, not the real wait window.
- **Real-time tests are explicitly named.** If a test genuinely needs wall-clock time (e.g. an integration smoke test), name it explicitly (`…_integration_realClock`) and gate it on a slow-tests flag — never silently mix into the fast suite.

## Assert at Least One `#expect` per Test
- **Empty-implementation smell:** if deleting the code under test still passes the test, the test asserts nothing. Mentally remove the code under test before committing.
- **A test with only `try`s and no `#expect` is suspect** — it covers "no error thrown" implicitly but doesn't verify the behaviour. Add a positive assertion of the expected outcome.
