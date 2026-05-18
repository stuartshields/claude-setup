<!-- Last updated: 2026-05-17T09:41+10:00 -->

# Code Quality

Principles that fire at write-time. For systematic passes, summon `simplify` or `code-reviewer`. Sources: Robert C. Martin's *Clean Code* (via [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills)) + the discipline already established in `discipline.md`.

## Shape
- **One concern per function, one domain per file.** If a function does X *and then* Y, split it. If a file exports unrelated helpers, split it. The 200-line file rule lives in `architecture.md`; this is the function-level analogue.
- **DRY when duplication is exact and load-bearing.** Three similar lines is fine; three *identical* blocks across files → extract a named helper. Don't pre-abstract for hypothetical reuse — premature abstraction is harder to undo than duplication.

## Dead Code & Defensive Scaffolding
- **Delete dead code, don't comment it out.** Git history is the archive. Commented-out code rots; deleted code stays gone or comes back via revert. Applies to unused exports, unreachable branches, and `// old version` blocks.
- **No defensive scaffolding.** Don't validate inputs from trusted internal callers, don't catch errors you can't handle, don't add fallbacks for cases that can't happen. Validate at trust boundaries only (`input-validation.md`). Defensive code hides real bugs and adds noise to reviews.

## Intent
- **Names declare what, not how, and surface side effects.** `saveUser` over `processUser`. Constants over magic numbers: `MAX_RETRIES = 3` over `if (attempt < 3)`. Single-letter names only for short loops and well-known math.
