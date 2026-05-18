---
title: Rules
---
<!-- Last updated: 2026-05-19T12:00+10:00 -->

## Rules

> **TL;DR:** 16 rule files across 2 loading modes:
>
> - **Always-on** (7 files, ~55 bullets) - `discipline`, `communication`, `dependencies`, `security`, `style`, `input-validation`, `code-quality`. The baseline constraints that apply to every session.
> - **Scoped** (9 files) - `architecture`, `testing`, `ui-ux`, `php-wordpress`, `environment`, `harness-maintenance`, `research-and-decisions`, `staleness`, `swift-testing`. Load only when working with matching file types.
>
> Rules Claude already follows without instruction are deleted. Rules it keeps breaking get moved to hooks instead. Conditional procedures (debugging, tool-failure recovery) were moved to skills so they lazy-load only when needed.

### The problem

Without rules, you repeat the same corrections every conversation. "Use tabs." "Don't add features I didn't ask for." "Always parameterize SQL." "Don't skip the unhappy path." Every session starts from zero.

Rules fix that. Files in `~/.claude/rules/` load automatically - Claude reads them before doing anything else. But there's a catch: **more rules doesn't mean better behaviour.** At 152 always-on bullet points, Claude was ignoring rules. Compliance degrades as instruction count rises. The system prompt already adds ~50 instructions, so your rules are competing for the same attention.

### How I use rules

**The instruction budget.** The single most important lesson: keep always-on rules under ~70 bullet points. Currently at ~55 across 7 files. This took deliberate trimming - the original setup had 142 always-on bullets across 10 files. Cutting ~60% improved adherence more than any rewrite of the rules themselves. The latest cut moved `debugging` and `tool-usage` out of rules entirely - both were conditional procedures ("when debugging...", "when Edit fails...") that don't belong in always-on context. They're skills now.

**Always-on vs scoped.** Rules that only matter for specific file types use `paths:` frontmatter so they don't load during irrelevant sessions. 9 of 16 files are scoped. `research-and-decisions.md` was always-on for months, loading 20 bullets every session even when no research was happening. Scoping it removed those bullets from sessions where they were noise.

**Hooks over prose.** Some rules kept getting ignored no matter how they were worded. "After 5 file reads without a code change, stop" was a rule in `context-management.md`. It didn't work. Now it's `context-drift-guard.sh` - a hook that counts reads and fires a warning mechanically. The rule file was deleted entirely, with its 3 strongest points merged into `discipline.md`. If Claude ignores a rule 2-3 times, the answer isn't better wording - it's converting to a hook.

**Deduplication with the system prompt.** Claude's system prompt already says "read files before editing" and "use dedicated tools over Bash." Rules that repeated this were wasting slots. Every rule should be specific and additive - something Claude wouldn't do without the instruction.

### One pattern worth stealing

**Scope aggressively, trim ruthlessly.** Most setups load everything always-on and wonder why compliance drops. Start with every rule scoped, then promote to always-on only if it genuinely applies to every session regardless of file type. Count your bullets. If you're over 70 always-on, you're in the zone where adding rules makes behaviour worse, not better.

### What's in here

**Always-on** (load every session):

- `discipline.md` - complete implementations, anti-pivot, pattern discovery, regression awareness, verification, context discipline
- `communication.md` - classify-before-acting, question-is-the-task, surface problems, stop at task boundaries
- `dependencies.md` - hallucination prevention (verify packages exist before referencing), dependency hygiene
- `security.md` - injection prevention, URL validation, secret handling
- `style.md` - tabs, clean code
- `input-validation.md` - validate at trust boundaries (peer frames, webhooks, IPC), authenticated vs payload identity
- `code-quality.md` - DRY, single responsibility, no defensive scaffolding, no commented-out code, named constants

**Scoped** (load when matching files are in play):

- `architecture.md` - modular-first structure, monorepo guidance
- `testing.md` - TDD, test quality, mock discipline
- `ui-ux.md` - design quality, accessibility, visual/CSS bug protocol
- `php-wordpress.md` - WordPress/PHP security, i18n, query patterns
- `environment.md` - Node version (pin 22), HTTPS, build tooling, agent routing
- `harness-maintenance.md` - instruction budget, rule quality checks, hooks-over-prose strategy
- `research-and-decisions.md` - source tracking, Architecture Decision Records
- `staleness.md` - 30-day freshness checks on guidance files
- `swift-testing.md` - no force-unwraps, no Task.sleep for absence assertions, TestClock over wall clock

---

[Previous: Core Guide](../docs/core-guide.md) | [Next: Hooks](../hooks/README.md)
