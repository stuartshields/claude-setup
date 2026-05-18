<!-- Last updated: 2026-05-19T14:30+10:00 -->

# REVIEW.md — Audit/review calibration for project-claude-setup

> **This file overrides the default audit/review calibration for this repository.** It's an educational mirror of `~/.claude/`, not a product codebase. Findings should reflect that. Pairs with the `audit-vs-fix-discipline` skill (see "Per-project override" section).

## What "Important" means here

**P0 / Critical** — broken before reaching the reader. Examples:

- Hook script with bash syntax error (fails to load when adopted)
- `settings.json` invalid JSON (Claude Code refuses to start)
- A documented hook path that doesn't exist (ghost reference flagged by drift-review)
- A documented skill/agent/rule that doesn't exist in this repo or `~/.claude/`
- A code example in a README that doesn't match the actual file it documents
- Memory rule that contradicts current behaviour and would mislead the next session

**P1 / Quality** — would mislead the educational reader. Examples:

- Hook count / category count in a README doesn't match the actual directory
- A rule references a file that's been renamed or removed
- TL;DR claims behaviour that no longer matches the live config
- Documentation drift between this repo and `~/.claude/` where global is source of truth (per `MEMORY.md`)
- Cross-reference to a skill/rule/hook path that resolves nowhere

**P2 / Nit** — minor inconsistencies. Examples:

- Inconsistent timestamp format across files (ISO 8601 datetime is the standard per `~/.claude/rules/staleness.md`)
- TL;DR sentence count doesn't match category count
- Markdown formatting variance (heading levels, list style)

## Pre-filtered — do NOT flag

- **Shell-hook style.** These are demonstrations, not production scripts. Don't flag "use shellcheck-clean", "wrap jq calls in retry", "add error handling for failed `head`" unless the demo would actually misbehave in the demonstrated scenario.
- **"Magic numbers" in hook scripts** — context thresholds (30%, 35%, 25%), debounce counts (5), line caps (50, 200) — these are deliberate calibration values explained in the surrounding rule or `CLAUDE.md`. Not findings.
- **Missing docblocks in shell hooks** — shell scripts use leading line comments, not docblocks. The top-of-file comment is the documentation.
- **References to skills/rules/hooks in `~/.claude/`** — that's the user's working set. Not "broken links" because they resolve when the reader adopts the setup.
- **"Missing test coverage" / "no CI"** — by design. The repo is config/docs, not application code. Don't flag.
- **Intentional divergences from `~/.claude/`** documented in `MEMORY.md`:
  - `@RTK.md` import in global `CLAUDE.md` but not in mirror — personal-only.
  - Some `gsd-*` historical references in `CHANGELOG.md` — historical record, not active behaviour.

## Documentation calibration

The repo's docs aim to **teach** rather than reference. The question for any doc finding is: *would a developer learning Claude Code be misled by this?*

- Misleading: yes → P1
- Inconsistent but recoverable: P2
- Stylistic only: not a finding

Tone rules from `.claude/CLAUDE.md` (no em-dashes, no AI filler phrases, educational not prescriptive) are not nit fodder — they're project-level conventions and warrant P1 if violated.

## Source of truth

`~/.claude/` is canonical. This repo mirrors it. When they diverge, global is correct unless the divergence is documented as intentional in `MEMORY.md`. Use `diff` between matching files when in doubt — pre-existing intentional divergences should not be reported as findings.

## Scope for audits

When the user asks to audit *this repo*, the scope is:

- Documentation accuracy (READMEs, `core-guide.md`, `governance-workflow.md`)
- Mirror parity with `~/.claude/` (modulo documented divergences)
- Internal cross-reference integrity
- Hook/rule/skill catalog correctness
- Markdown frontmatter (paths, last-updated timestamps)

It is *not* about:

- Refactoring shell hook style
- Adding TypeScript types to hook scripts
- Adding tests
- Generalising the demonstration code
