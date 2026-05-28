# Dependency categories

When proposing a deepened module, classify its dependencies. The category determines the consolidation shape, the seam placement, and the testing strategy. Skipping this step produces "just merge them" recommendations with no answer for how the result is tested.

Uses the vocabulary from @language.md — **module**, **interface**, **seam**, **adapter**, **port**.

## The four categories

### 1. In-process

Pure computation and in-memory state. No I/O, no clock, no randomness, no network, no disk.

**Examples:**
- A parser turning a string into a structured value
- A pricing calculation over an in-memory cart
- A state machine over a JS object

**Consolidation shape:**
Always deepenable. Merge the modules and test through the new interface directly. No adapter needed — the module *is* its implementation.

**Testing strategy:**
Direct calls. Arrange-act-assert. No mocks, no fakes, no DI. The interface is the test surface.

### 2. Local-substitutable

Dependencies that have a local stand-in fast enough to run inside the test suite. The stand-in implements the same wire protocol as the real dependency — you're not mocking, you're running a real instance.

**Examples:**
- **Postgres:** PGLite, an embedded Postgres
- **Redis:** ioredis-mock, or a real Redis in a test container
- **Filesystem:** memfs, or `os.tmpdir()` with cleanup
- **HTTP server:** an in-process server bound to `127.0.0.1:0`
- **Time:** a frozen clock injected at the edge

**Consolidation shape:**
Deepenable if the stand-in exists. Merge the modules; the test seam is internal (private to the deepened module's tests), not part of the public interface. The production code runs against the real dependency; the tests run against the stand-in.

**Testing strategy:**
Bring the stand-in up in a test fixture. Tests assert through the public interface. No mocking — the stand-in *is* the real protocol, just embedded.

**Key distinction from category 3:**
The dependency is local-substitutable when there's a high-fidelity stand-in. If the stand-in diverges from the real behaviour (mocks pretending to be Stripe), you're in category 4, not category 2.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary — internal microservices, internal APIs, your own queue topics. You control the protocol and the implementation, but it runs out-of-process.

**Examples:**
- Internal HTTP/gRPC services in the same org
- A queue you publish to and consume from
- A separate database service owned by another team

**Consolidation shape:**
The deepened module owns the *logic*. The transport is a **port** at the seam — an interface the module depends on. Production provides an HTTP/gRPC/queue **adapter**; tests provide an in-memory adapter.

**Recommendation phrasing:**
> "Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."

**Testing strategy:**
Tests inject the in-memory adapter. The module's logic is exercised through its public interface; the adapter is a test-time substitute, not a mock that pretends to be the protocol.

**Seam discipline check:**
Does the port have at least two adapters justified (production + test)? If yes → real seam, port is earned. If only one adapter exists → hypothetical seam, just write the code directly without the port.

### 4. True external (Mock)

Third-party services you don't control: Stripe, Twilio, SendGrid, Anthropic, AWS S3 (when not substituting with LocalStack), etc. You can't run them locally with fidelity; the protocol or behaviour is too rich.

**Examples:**
- Payment processors (Stripe, Adyen)
- Email/SMS providers (SendGrid, Twilio)
- LLM APIs (Anthropic, OpenAI)
- OAuth providers (Google, GitHub)

**Consolidation shape:**
Same as category 3 — port at the seam, production adapter calls the real service, test adapter is a mock. The difference is that you have less confidence the mock matches reality, so integration tests against the real service (sandbox/test mode) become more important.

**Testing strategy:**
Unit tests inject a mock adapter. Add a small set of integration tests against the real service's sandbox/test mode to validate the production adapter. The mock adapter must mirror the real response shape completely (see `testing-anti-patterns.md` in the TDD skill — incomplete mocks anti-pattern).

## Seam discipline

These rules apply across categories 3 and 4. Categories 1 and 2 don't have external seams to worry about.

### One adapter is hypothetical. Two is real.

Don't introduce a port unless at least two adapter implementations are justified. The textbook split is production + test. The test-only seam alone isn't enough — see if the test can use the production adapter against a local stand-in (which would push it into category 2) before introducing a port.

A port with one adapter is just indirection. It adds an interface to learn without earning anything.

### Internal seams vs external seams

A deep module can have **internal seams** — private to its implementation, used by its own tests — as well as the **external seam** at its public interface.

Don't expose internal seams through the public interface just because tests use them. If a caller doesn't need to swap an adapter, it doesn't go in the public interface.

### The interface is the test surface

Callers and tests cross the same seam. If you want to test *past* the public interface, either:

- The module is the wrong shape — the thing you want to test should be its own module, or
- The test is testing implementation, not behaviour — rewrite it to assert through the interface.

If neither applies and you still need to test past the interface, the consolidation proposal is wrong. Revise it.

## Testing strategy: replace, don't layer

When deepening a cluster of shallow modules, the old tests don't survive intact. Plan for replacement, not addition.

**Replace:**
- Old unit tests asserting against individual shallow modules' interfaces. Once tests exist at the deepened module's interface, the old tests are waste — they test seams that no longer exist publicly. Delete them.

**Write new:**
- Tests at the deepened module's public interface.
- Tests assert on observable outcomes through the interface, not on internal state or internal-seam interactions.
- Tests should survive internal refactors. If a test breaks when the implementation changes but the behaviour doesn't, it's testing past the interface.

**Don't:**
- Keep the old tests "as a safety net" alongside the new ones. They calcify the old shape and discourage the very consolidation you just did.
- Add new tests at internal seams unless they're testing genuinely hard-to-reach behaviour that the public interface can't exercise.

## Quick lookup

| Category | Production | Test | Port at seam? |
|---|---|---|---|
| 1. In-process | direct calls | direct calls | no |
| 2. Local-substitutable | real dependency | local stand-in | no (internal seam only) |
| 3. Remote but owned | HTTP/gRPC adapter | in-memory adapter | yes (≥2 adapters) |
| 4. True external | real-service adapter | mock adapter + sandbox integration | yes (≥2 adapters) |

When in doubt about category, ask: "Is there a local stand-in I'd trust to behave like the real thing?" Yes → category 2. No, but I own the protocol → category 3. No, and I don't own it → category 4.
