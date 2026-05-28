# Language

Shared vocabulary for every finding this skill produces. Use these terms exactly. Substituting "component", "service", "API", or "boundary" defeats the analysis — those words are too overloaded to think in.

## Terms

### Module

Anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice can all be modules.

*Avoid:* unit, component, service. They imply a specific scale or runtime shape that this lens doesn't care about.

### Interface

Everything a caller must know to use the module correctly. Includes:

- Type signatures (the obvious part)
- Invariants the caller can rely on
- Ordering constraints (call X before Y)
- Error modes (what can fail and how)
- Required configuration (what must be set up to use this)
- Performance characteristics (when they matter to callers)

*Avoid:* API, signature. Those refer only to the type-level surface, which is a strict subset of interface.

### Implementation

What's inside a module — its body of code. Distinct from **adapter**: a thing can be a small adapter with a large implementation (a Postgres repository) or a large adapter with a small implementation (an in-memory fake).

Use "adapter" when the seam is the topic; "implementation" otherwise.

### Depth

Leverage at the interface. The amount of behaviour a caller (or test) can exercise per unit of interface they must learn.

- **Deep module:** large amount of behaviour behind a small interface.
- **Shallow module:** interface nearly as complex as the implementation.

Depth is a property of the **interface**, not the **implementation**. A deep module can be internally composed of small swappable parts — they just aren't part of its public interface.

### Seam (Michael Feathers)

A place where you can alter behaviour without editing in that place. The **location** at which a module's interface lives. Choosing where to put the seam is its own design decision, distinct from what sits behind it.

*Avoid:* boundary. That word is overloaded with DDD's bounded context. Say **seam** or **interface**.

### Adapter

A concrete thing that satisfies an interface at a seam. Describes *role* (what slot it fills), not substance (what's inside).

### Leverage

What callers get from depth: more capability per unit of interface they have to learn. One implementation pays back across N call sites and M tests.

### Locality

What maintainers get from depth: change, bugs, knowledge, and verification concentrate at one place rather than spreading across callers. Fix once, fixed everywhere.

## Principles

**Depth is a property of the interface, not the implementation.**
A deep module can be internally composed of small, mockable, swappable parts — they just aren't part of its public interface. The implementation can have **internal seams** (private to its own tests) as well as the **external seam** at its public interface. Don't expose internal seams just because tests use them.

**The deletion test.**
Imagine deleting the module and inlining it at its call sites. If complexity vanishes, the module wasn't hiding anything — it was a pass-through. If complexity reappears across N callers, the module was earning its keep.

**The interface is the test surface.**
Callers and tests cross the same seam. If you want to test *past* the interface, the module is probably the wrong shape — either the interface is wrong, or the test is testing implementation.

**One adapter is a hypothetical seam. Two adapters is a real one.**
Don't introduce a port unless something actually varies across it. The textbook split is production adapter + test adapter; the test-only seam isn't enough on its own to justify the indirection — see if the test can use the production adapter against a local stand-in instead.

## Relationships

- A **Module** has exactly one **Interface** (the surface it presents to callers and tests).
- **Depth** is a property of a **Module**, measured against its **Interface**.
- A **Seam** is where a **Module**'s **Interface** lives.
- An **Adapter** sits at a **Seam** and satisfies an **Interface**.
- **Depth** produces **Leverage** for callers and **Locality** for maintainers.

## Rejected framings

**Depth as ratio of implementation-lines to interface-lines (Ousterhout's original framing).**
Rewards padding the implementation to look "deep". We use depth-as-leverage instead — the question is how much *behaviour* sits behind the interface, not how many *lines*.

**"Interface" meaning the TypeScript `interface` keyword, or a class's public methods.**
Too narrow. Interface here includes every fact a caller must know — invariants, ordering, error modes, perf characteristics — not just type-level structure.

**"Boundary."**
Overloaded with DDD's bounded context. When you mean the location of an interface, say **seam** or **interface**. When you mean a domain edge, say **bounded context**.

**"Service" / "component" / "module" used interchangeably.**
These words have different meanings on different teams. This skill uses **module** as the umbrella term and reaches for **adapter** or **port** when the seam is the topic. Don't drift back to fuzzier words mid-analysis.
