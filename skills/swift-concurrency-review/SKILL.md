---
name: swift-concurrency-review
description: Use when reviewing Swift 5.5+ code containing `await`, `actor`, `Task { }`, `@MainActor`, `@unchecked Sendable`, cancellable timer/deadline handles, or long-lived `for await` AsyncStream consumers — especially diffs extending existing actors with new methods. Catches post-`await` state-overwrite races, TOCTOU around Task spawn, cancellation-not-honoured, terminal-state clobber, and consumer-Task-ownership bugs that hang Swift Testing at exit.
---

<!-- Last updated: 2026-05-10T20:55+10:00 -->

# Swift Concurrency Review

## Overview
Swift 6 strict concurrency catches data races at compile time but lets a class of semantic bugs through: state-overwrite races, TOCTOU around `Task { }`, and cancellation that doesn't actually prevent firing. This is a reviewer's checklist for those bug classes. Apply on any diff touching `actor`, `@MainActor`, `await`, `Task {`, lock-protected state, or deadline timers.

## The Five Questions

### 1. After every `await`, is **state** re-checked — not just the index?
When an actor method suspends at `await`, any other method on the actor can run to completion before it resumes. Re-finding a record by id ≠ verifying its state is still what you expected.

```swift
// BAD
try await transport.send(message)
guard let idx = outbound.firstIndex(where: { $0.id == id }) else { return }
outbound[idx].direction = .delivered   // overwrites .cancelled / .deadlineMissed

// GOOD
try await transport.send(message)
guard let idx = outbound.firstIndex(where: { $0.id == id }),
      outbound[idx].direction == .sending else { return }
outbound[idx].direction = .delivered
```

**Invariant: terminal states are sticky.** Once a record is `.cancelled` / `.expired` / `.deadlineMissed`, no later success path may overwrite it. The guard encodes this invariant.

### 2. Is `Task { }` body reading mutable state, or is it snapshotted at spawn?
A `Task { }` body runs later, on some executor. Reading `clock.now`, `self.count`, or any mutable state *inside* the closure is a TOCTOU — the value is read at an arbitrary later moment, not at spawn.

```swift
// BAD — clock.now read inside the Task
task = Task { [weak self] in
    let seconds = max(0, deadline.timeIntervalSince(clock.now))
    try? await clock.sleep(for: seconds)
}

// GOOD — clock.now read before Task exists, captured as constant
let seconds = max(0, deadline.timeIntervalSince(clock.now))
task = Task { [weak self] in
    try? await clock.sleep(for: seconds)
}
```

### 3. If cancellable, does `cancel()` actually prevent firing?
`Task.cancel()` signals cancellation; it does not stop a running task. `try? await clock.sleep(for:)` swallows `CancellationError` and falls through. A handle that looks cancellable can still fire after `cancel()`.

**Fix options** (at least one must exist and have a test):
- Flip a `fired: Bool` / `cancelled: Bool` under the lock in `cancel()`, check it after sleep
- Check `Task.isCancelled` explicitly after the sleep
- Use `try await` (not `try?`) and let `CancellationError` propagate

### 4. Does fire-and-forget `Task { }` manage the lifetime of what it captures?
A detached `Task { }` that captures `self` strongly or `any SomeProtocol` and runs after the owner tears down is a leak or a crash. Use `[weak self]` + early return, or await on a parent task that's guaranteed to complete.

### 5. Is a long-lived `for await` consumer Task owned by something whose `deinit` finishes the source?
A `Task { for await event in stream { ... } }` stored on an actor does NOT die deterministically when the actor goes out of scope. `[weak self]` only nils the reference *inside* the loop body — not while the task is suspended at `for await`, which is most of the task's life. AsyncStream's auto-finish-on-continuation-dealloc is non-deterministic, and Swift Testing waits for all background Tasks before exiting — symptom: `swift test` prints all "passed" lines, then **hangs at exit** before the run summary.

The fix is structural: park the Task on a non-actor class that the actor strong-references. When the actor deinits, the class deinits, and the class's `deinit` runs synchronously on the deallocating thread — finishing the stream (so the `for await` returns nil) and cancelling the Task (belt-and-suspenders for a body that's mid-event).

```swift
// BAD — Task stored on actor, not deterministically torn down
actor MyActor {
    private var consumerTask: Task<Void, Never>?
    init(stream: AsyncStream<RawEvent>) {
        consumerTask = Task { [weak self] in
            for await event in stream {
                guard let self else { return }
                await self.process(event)
            }
        }
    }
}

// GOOD — Task owned by a non-actor class with synchronous deinit
final class ConsumerBox: @unchecked Sendable {
    let stream: AsyncStream<RawEvent>
    private let cont: AsyncStream<RawEvent>.Continuation
    private var consumerTask: Task<Void, Never>?

    init() {
        var captured: AsyncStream<RawEvent>.Continuation!
        self.stream = AsyncStream { captured = $0 }
        self.cont = captured
    }

    deinit {
        cont.finish()             // 1. wake the consumer, return nil from `for await`
        consumerTask?.cancel()    // 2. belt-and-suspenders for mid-await body
    }

    func bind(to actor: MyActor) {
        let s = stream
        consumerTask = Task { [weak actor] in
            for await event in s {
                guard let actor else { return }
                await actor.process(event)
            }
        }
    }
}

actor MyActor {
    private let box = ConsumerBox()
    init() { box.bind(to: self) }
}
```

The non-actor class wrapper is load-bearing — actor `deinit` runs in a separate isolation context and doesn't synchronously tear down the Task chain.

## Review Checklist

Flag any violation as at least a Major:

- [ ] Every `await` is followed by a state re-check before mutating — not just a re-find by id
- [ ] Terminal-state guards are **mirrored** across methods that can transition the same record (if `send` guards against `.cancelled`, `cancel` must also guard against `.delivered`)
- [ ] Values used inside `Task { }` closures are captured at spawn time, not read inside
- [ ] Every `cancel()` / `teardown()` has a test proving the handle does not fire after cancellation
- [ ] `try?` around `await` is deliberate and justified — not a paper over a cancellation bug
- [ ] `[weak self]` or explicit lifecycle management on every fire-and-forget `Task { }` that outlives the caller
- [ ] Long-lived `for await` consumer Tasks are owned by a non-actor class whose `deinit` finishes the source stream and cancels the Task — NOT stored as a property on the actor itself
- [ ] `@unchecked Sendable` has a code comment naming the synchronisation primitive that makes it safe

## Common Mistakes

| Pattern | Why it's wrong | Fix |
|---|---|---|
| Re-find by id after `await` without checking state | Actor may have transitioned the record mid-await | Check state == expected before mutating |
| `clock.now` / mutable state inside `Task { }` closure | Read happens at arbitrary future moment | Compute outside Task, capture as constant |
| `try? await sleep(...)` with no post-sleep cancel check | Task continues to fire after `cancel()` | `Task.isCancelled` check or `fired` flag |
| `Task { foo() }` without `[weak self]` | Strong self capture outlives owner | `[weak self]` + early return |
| `Task { for await event in stream { ... } }` stored on an actor | Actor `deinit` doesn't synchronously tear down the Task; Swift Testing hangs at exit | Move the consumer to a non-actor class whose `deinit` finishes the source + cancels the Task |
| `@unchecked Sendable` with no explanation | The escape hatch is load-bearing; nobody can verify | Add comment naming the lock / invariant |

## Red Flags

These patterns in a diff mean **stop and apply the four questions**:

- `guard let idx = X.firstIndex(...)` followed directly by a mutation, *after* an `await`
- `Task { [weak self] in` or `Task { in` with a body that reads `.now` / `.count` / any stored prop
- `try?` before `await` on a Clock/Sleep call
- `@unchecked Sendable` with no comment
- A `cancel()` that only calls `task?.cancel()` with no state flag
- An actor with a stored `Task<Void, Never>?` property that runs `for await` over an AsyncStream — especially if the surrounding test suite hangs at exit

## Real-World Impact

Applied to bt-note's `NoteStore.send`: caught a terminal-state clobber where `.deadlineMissed` was overwritten by `.delivered` when the deadline fired during the transport's `await`. Applied to `DeliveryTimerHandle.start`: caught a `clock.now` TOCTOU that made the `TestClock`-based tests racy. Applied to `BLETransport`'s consumer Task: caught the actor-stored `for await` Task that hung Swift Testing at exit — fix was to move it onto a non-actor `DelegateBox` class with a synchronous `deinit`.
