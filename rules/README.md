---
title: Rules
---
<!-- Last updated: 2026-03-23T16:30+11:00 -->

## Rules

> **TL;DR:** 15 rule files across 2 loading modes (plus 1 reference template):
>
> - **Always-on** (9 files) - `debugging.md` (4-step framework, anti-loop, rebuild-vs-patch), `discipline.md` (complete implementations, anti-pivot, scope control, spec challenge), `context-management.md` (context pruning, post-compaction discipline, 5-read limit, subagent delegation), `communication.md` (design discussion checkpoint, classify-before-acting, surface problems), `dependencies.md` (hallucination prevention, one-round verification), `security.md` (input validation, injection prevention, audit scoping), `research-and-decisions.md` (source tracking, ADRs), `staleness.md` (30-day freshness checks), `style.md` (tabs, clean code).
> - **Conditional** (6 files, scoped by file type) - `architecture.md`, `testing.md`, `ui-ux.md` (includes visual/CSS bug protocol), `php-wordpress.md`, `environment.md`, `harness-maintenance.md`. Load only when working with matching files, keeping the always-on count under the ~150 ceiling (including system prompt).
>
> Rules Claude already follows without instruction are deleted. Rules it keeps breaking get moved to hooks instead.

For what each rule does, why it exists, and how it compares to community patterns, see the [Component Reference](../docs/component-reference.md#rules).

Without rules, you repeat the same instructions every conversation. "Use tabs." "No console.log." "Always parameterize SQL." "Don't add unrequested features." Every. Single. Session.

Rules fix that. Files in `~/.claude/rules/` load automatically at the start of every session - Claude reads them before doing anything else.

How to use this folder in Claude:

1. Copy this `rules/` folder to `~/.claude/rules/`
2. Keep broad rules as always-loaded markdown files
3. Use frontmatter (`applyTo`/`paths`) on specialized rules so they only load for matching files

The current rules here are split into always-loaded and conditional files. That keeps enforcement strict without wasting context on irrelevant stacks.

### Design principles (v2026.4)

These rules follow community-validated patterns for instruction compliance:

- **Instruction budget awareness.** Always-loaded rules total ~89 bullet points (down from ~128 in v2026.3, ~310 originally). The system prompt adds ~50 more. Total stays under the ~150 ceiling where compliance degrades. Research: [Jaroslawicz et al.](https://dev.to/minatoplanb/i-wrote-200-lines-of-rules-for-claude-code-it-ignored-them-all-4639) - "double instructions, halve compliance."
- **Positive framing.** Rules tell Claude what TO do, not what to avoid. Flipping negative rules to positive equivalents cuts violations by roughly half.
- **Deduplication.** Each rule lives in exactly one file. Rules that duplicate system prompt directives are deleted - they waste instruction slots. Cross-cutting concepts are not repeated across files.
- **Primacy/recency ordering.** Most-violated rules sit at the top and bottom of each file to exploit attention bias.
- **Aggressive scoping.** Rules that only apply to specific file types use `paths:` frontmatter so they don't load during irrelevant sessions. 5 of 10 rule files are now scoped.

### Files in this folder

| File | What it does |
|------|--------------|
| `architecture.md` | Modular-first structure guidance (200-line rule, atomic responsibility, monorepo boundaries). |
| `debugging.md` | Root-cause-first debugging protocol: validate one hypothesis at a time, trace full data flow, no speculative fixes. |
| `dependencies.md` | Blocks hallucinated packages/URLs and enforces dependency hygiene before adding or referencing anything external. |
| `context-management.md` | Context pruning (5-read limit, subagent delegation, stay-where-user-points-you) and post-compaction discipline (trust summaries, don't re-read loop). |
| `discipline.md` | Scope control, anti-overengineering rules, complete implementation checks, and regression awareness guardrails. |
| `environment.md` | Configuration-file handling rules for build/tooling/env files (`tsconfig`, `.env`, Docker, bundler configs, etc.). |
| `php-wordpress.md` | WordPress/PHP-specific development standards and conventions for WP projects. |
| `security.md` | Always-on security baseline: input validation, SQL injection prevention, XSS prevention, secret handling. |
| `style.md` | Code style guardrails (tabs-only, clean code). |
| `testing.md` | Test-first workflow and test quality rules (failing test first, behavior-focused assertions, mock skepticism). Now scoped to code files. |
| `ui-ux.md` | Frontend UI/UX quality rules with WCAG 2.2 AA accessibility, W3C ARIA-first guidance. Includes visual/CSS bug protocol (moved from debugging.md). |
| `harness-maintenance.md` | Scoped to `~/.claude/` files only. Enforces external research, instruction budget (~100 always-on bullet ceiling), rule quality checks (positive framing, rationale for non-obvious rules, primacy/recency anchoring), and source tracking when modifying the harness. |
| `research-and-decisions.md` | Research source tracking (`.planning/SOURCES.md`) and Architecture Decision Records (`.planning/adr/`) for structured project decisions. |
| `staleness.md` | Tracks last-updated dates on all guidance files. Flags files older than 30 days so AI best practices stay current as models evolve. |
| `communication.md` | When to ask vs act, design discussion checkpoint, responding to the user, surfacing problems, progress and status. |

### Always-loaded rules

These 9 files load every session:

- `context-management.md` - context pruning (5-read limit, subagent delegation, cross-project leash), post-compaction discipline
- `debugging.md` - 4-step framework, anti-loop protocol, hypothesis-driven investigation, rebuild-vs-patch guidance
- `dependencies.md` - hallucinated package prevention, one-round verification, dependency hygiene
- `discipline.md` - complete implementations, anti-pivot rules, scope control, spec challenge, verification
- `communication.md` - design discussion checkpoint, classify-before-acting, question-is-the-task, interview-first, surface-problems
- `research-and-decisions.md` - research source tracking, Architecture Decision Records
- `security.md` - input validation, injection prevention, secrets handling
- `staleness.md` - 30-day freshness check on all guidance files, auto-updates dates on edit
- `style.md` - tabs, clean code

### Conditional rules

These 6 files are scoped by `paths:` frontmatter and only load when relevant files are in play.

**Note:** User-level rules (`~/.claude/rules/`) require CSV format for `paths:` due to a [known bug](https://github.com/anthropics/claude-code/issues/21858). Use `paths: "**/*.vue,**/*.tsx"` not YAML arrays. Run `/debug-rules` to verify loading.

- `architecture.md` - modular-first structure, monorepo guidance (loads for code files)
- `environment.md` - HTTPS, build tooling, agent routing (loads for config files)
- `harness-maintenance.md` - research-first protocol for harness changes (loads for `~/.claude/` files only)
- `php-wordpress.md` - WordPress/PHP standards (loads for `.php`, `composer.json`)
- `testing.md` - TDD, test quality, mock discipline (loads for code and test files)
- `ui-ux.md` - design quality, accessibility (loads for component/view/template files)

---

## Continue Reading

[Previous: Governance Workflow](../docs/governance-workflow.md) | [Next: Hooks](../hooks/README.md)

## Quick Links

- [Home](../index.md)
- [Start Here](../docs/start-here.md)
- [Core Guide](../docs/core-guide.md)
- [Governance Workflow](../docs/governance-workflow.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)
- [Skills & Memory](../skills/README.md)
