## Rules

Without rules, you repeat the same instructions every conversation. "Use tabs." "No console.log." "Always parameterize SQL." "Don't add unrequested features." Every. Single. Session.

Rules fix that. Files in `~/.claude/rules/` load automatically at the start of every session - Claude reads them before doing anything else.

How to use this folder in Claude:

1. Copy this `rules/` folder to `~/.claude/rules/`
2. Keep broad rules as always-loaded markdown files
3. Use frontmatter (`applyTo`/`paths`) on specialized rules so they only load for matching files

The current rules here are split into always-loaded and conditional files. That keeps enforcement strict without wasting context on irrelevant stacks.

### Files in this folder

| File | What it does |
|------|--------------|
| `architecture.md` | Modular-first structure guidance (200-line rule, atomic responsibility, monorepo boundaries). |
| `debugging.md` | Root-cause-first debugging protocol: validate one hypothesis at a time, trace full data flow, no speculative fixes. |
| `dependencies.md` | Blocks hallucinated packages/URLs and enforces dependency hygiene before adding or referencing anything external. |
| `discipline.md` | Scope control, anti-overengineering rules, complete implementation checks, and regression awareness guardrails. |
| `environment.md` | Configuration-file handling rules for build/tooling/env files (`tsconfig`, `.env`, Docker, bundler configs, etc.). |
| `php-wordpress.md` | WordPress/PHP-specific development standards and conventions for WP projects. |
| `security.md` | Always-on security baseline: input validation, SQL injection prevention, XSS prevention, secret handling. |
| `style.md` | Output fidelity and code style guardrails (tabs-only, no placeholders, no hallucinated APIs). |
| `testing.md` | Test-first workflow and test quality rules (failing test first, behavior-focused assertions, mock skepticism). |
| `ui-ux.md` | Frontend UI/UX quality rules for component/page/template styling and interaction work. |
| `verification.md` | Verification and failure-recovery loop: run build/test/lint, fix, re-run, and respect hook behavior. |

### Always-loaded rules

These are broad baseline rules that apply across all tasks:

- `architecture.md`
- `debugging.md`
- `dependencies.md`
- `discipline.md`
- `security.md`
- `style.md`
- `testing.md`
- `verification.md`

### Conditional rules

These are scoped by frontmatter so Claude only loads them when relevant files are in play:

- `environment.md`
- `php-wordpress.md`
- `ui-ux.md`
