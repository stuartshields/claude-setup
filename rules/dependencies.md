<!-- Last updated: 2026-03-21 -->

# Dependencies

## Hallucinated Reference Prevention
- **Verify before referencing.** For any URL, package, CLI tool, or API endpoint not already in the codebase, verify it exists (WebSearch, `npm search`, or ask the user) BEFORE writing it.
- Validate names and URLs exist — "sounds right" is not verification.
- Ask the user if you don't know the real URL.

## Dependency Hygiene
- **Ask before suggesting any new dependency.**
- Follow the project's dependency style (loose, tight, pinned).
- Respect lock file constraints.
- Run `npm audit` / `pnpm audit` before deployment. For each finding:
	1. Check if the affected code path is actually used.
	2. If yes, upgrade or find alternative. If no, document why it's acceptable.
