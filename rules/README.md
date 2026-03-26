---
title: Rules
---
<!-- Last updated: 2026-03-26T12:00+11:00 -->

## Rules

> **TL;DR:** 15 rule files across 2 loading modes:
>
> - **Always-on** (7 files, ~59 bullets) - `discipline.md` (complete implementations, anti-pivot, pattern discovery, regression awareness, verification, context discipline), `debugging.md` (4-step framework, hypothesis validation, anti-loop protocol), `communication.md` (classify-before-acting, question-is-the-task, surface problems), `dependencies.md` (hallucination prevention, dependency hygiene), `security.md` (injection prevention, secrets), `style.md` (tabs, clean code), `tool-usage.md` (Edit retry limit, search budget).
> - **Conditional** (8 files, scoped by file type) - `architecture.md`, `testing.md`, `ui-ux.md`, `php-wordpress.md`, `environment.md`, `harness-maintenance.md`, `research-and-decisions.md`, `staleness.md`. Load only when working with matching files.
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

### Design principles (v2026.5)

These rules follow community-validated patterns for instruction compliance:

- **Instruction budget awareness.** Always-loaded rules total ~59 bullet points (down from ~95 in v2026.4, ~142 in v2026.3). The system prompt adds ~50 more. Total stays well under the ~150 ceiling where compliance degrades. Research: [Jaroslawicz et al.](https://dev.to/minatoplanb/i-wrote-200-lines-of-rules-for-claude-code-it-ignored-them-all-4639) - "double instructions, halve compliance."
- **Hooks over prose for enforcement.** Rules that Claude repeatedly violated have been converted to hooks (`context-drift-guard.sh`, `repeated-approach-guard.sh`, `repeated-bash-guard.sh`). Prose rules are suggestions; hooks are laws.
- **Positive framing.** Rules tell Claude what TO do, not what to avoid. Flipping negative rules to positive equivalents cuts violations by roughly half.
- **Deduplication.** Each rule lives in exactly one file. Rules that duplicate system prompt directives are deleted - they waste instruction slots.
- **Primacy/recency ordering.** Most-violated rules sit at the top and bottom of each file to exploit attention bias.
- **Aggressive scoping.** Rules that only apply to specific file types use `paths:` frontmatter so they don't load during irrelevant sessions. 8 of 15 rule files are now scoped.

### Files in this folder

| File | What it does |
|------|--------------|
| `architecture.md` | Modular-first structure guidance (200-line rule, atomic responsibility, monorepo boundaries). |
| `communication.md` | When to ask vs act, question-is-the-task, surface problems, stop at task boundaries. |
| `debugging.md` | 4-step debugging framework (reproduce/isolate/fix/validate), hypothesis validation, anti-loop protocol. |
| `dependencies.md` | Blocks hallucinated packages/URLs and enforces dependency hygiene. |
| `discipline.md` | Complete implementations, anti-pivot rules, pattern discovery, regression awareness, verification, and context discipline (merged from former context-management.md). |
| `environment.md` | HTTPS by default, agent/plugin routing guidance (loads for config files). |
| `harness-maintenance.md` | Research-first protocol for harness changes, instruction budget ceiling, rule quality checks (loads for `~/.claude/` files only). |
| `php-wordpress.md` | WordPress/PHP security, i18n, query patterns, and PHP standards (loads for `.php`, `composer.json`). |
| `research-and-decisions.md` | Research source tracking (`.planning/SOURCES.md`) and Architecture Decision Records (loads near `.planning/` files). |
| `security.md` | Always-on security baseline: injection prevention, URL validation, secret handling. |
| `staleness.md` | 30-day freshness checks on guidance files, auto-updates timestamps on edit (loads near `.claude/` files). |
| `style.md` | Code style guardrails (tabs-only, clean code). |
| `testing.md` | TDD, test quality, mock discipline (loads for code and test files). |
| `tool-usage.md` | Edit retry limit, search budget. |
| `ui-ux.md` | Design quality, accessibility, visual/CSS bug protocol (loads for component/view/template files). |

### Always-loaded rules

These 7 files load every session (~59 bullets total):

- `communication.md` - classify-before-acting, question-is-the-task, surface problems, stop at boundaries
- `debugging.md` - 4-step framework, hypothesis validation, anti-loop protocol
- `dependencies.md` - hallucinated package prevention, dependency hygiene
- `discipline.md` - complete implementations, anti-pivot, pattern discovery, regression awareness, verification, context discipline
- `security.md` - injection prevention, secrets handling
- `style.md` - tabs, clean code
- `tool-usage.md` - Edit retry limit, search budget

### Conditional rules

These 8 files are scoped by `paths:` frontmatter and only load when relevant files are in play.

**Note:** User-level rules (`~/.claude/rules/`) require CSV format for `paths:` due to a [known bug](https://github.com/anthropics/claude-code/issues/21858). Use `paths: "**/*.vue,**/*.tsx"` not YAML arrays. Run `/debug-rules` to verify loading.

- `architecture.md` - modular-first structure, monorepo guidance (loads for code files)
- `environment.md` - HTTPS, build tooling, agent routing (loads for config files)
- `harness-maintenance.md` - research-first protocol for harness changes (loads for `~/.claude/` files only)
- `php-wordpress.md` - WordPress/PHP standards (loads for `.php`, `composer.json`)
- `research-and-decisions.md` - source tracking, ADRs (loads near `.planning/` files)
- `staleness.md` - freshness checks (loads near `.claude/` files)
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
