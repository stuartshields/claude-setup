# Dependencies

## Hallucinated Reference Prevention
- **Verify before referencing.** For any URL, package, CLI tool, or API endpoint not already in the codebase, verify it exists (WebSearch, `npm search`, or ask the user) BEFORE writing it.
- Never trust names or URLs that "sound right" - validate they exist.
- If you don't know the real URL, ask the user. Never invent a plausible-looking link.
- If a package doesn't exist, ask the user instead of inventing alternatives.

## Dependency Hygiene
- Never suggest new dependencies without asking first.
- Follow the project's dependency style (loose, tight, pinned).
- Respect lock file constraints - don't suggest conflicting versions.
- Run `npm audit` / `pnpm audit` before deployment. For each finding:
	1. Check if the affected code path is actually used.
	2. If yes, upgrade or find alternative. If no, document why it's acceptable.
