<!-- Last updated: 2026-03-23T16:30+11:00 -->

# Research Sources & Decision Records

## Research Sources (`.planning/SOURCES.md`)

### Before Searching
- **Check existing sources first.** Before any WebSearch/WebFetch, check if `.planning/SOURCES.md` exists in the project root. Read it — the answer may already be documented from a prior session.

### During Research
- **Track external research per project.** When WebSearch/WebFetch informs a decision (library choice, architecture pattern, bug fix, API usage, bug report workaround), append the source to `.planning/SOURCES.md` in the project root. This includes research done during debugging - if a GitHub issue or community post changes your approach, log it immediately, not after the fix.
- **Create `.planning/SOURCES.md` on first use.** Group entries by topic.
- **Entry format:** `- [Title](URL) - what decision/file it influenced (YYYY-MM-DD)`
	- The date is when the source was last verified, not when the decision was made.
	- Link to the code or config the research drove, e.g. `→ src/auth/middleware.ts` or `→ CLAUDE.md Section 3`.
- **Not every lookup is research.** Only log sources that informed a decision. Skip syntax checks, package existence verification, and quick doc lookups.

## Architecture Decision Records (`.planning/adr/`)

### When to Write an ADR
- Choosing between competing libraries, frameworks, or approaches
- Deciding on a pattern that will be used project-wide (state management, auth strategy, API design)
- Rejecting an obvious approach in favour of a less obvious one
- Any decision where a future session might ask "why didn't we just...?"
- **Do not write ADRs for:** style preferences, trivial choices, or decisions already explained in CLAUDE.md

### Before Deciding
- **Check existing ADRs first.** Before making an architectural choice, check if `.planning/adr/` exists and read relevant records. A previous session may have already evaluated the same options.

### File Format
- **Filename:** `NNNN-short-title.md` (e.g. `0001-use-css-first-tailwind.md`)
- **Number sequentially.** Check the highest existing number and increment.
- **Template:** Copy `~/.claude/templates/adr-template.md` as your starting point.

### Maintaining ADRs
- **Never edit an accepted ADR.** If a decision changes, write a new ADR that supersedes it and update the old one's status.
- **Link ADRs to CLAUDE.md rules.** If an ADR drives a rule in CLAUDE.md, reference the ADR number in a comment: `<!-- ADR-0003 -->`.
- **Link ADRs to SOURCES.md.** If research informed the decision, reference the relevant SOURCES.md entries rather than duplicating URLs.
