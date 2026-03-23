<!-- Last updated: 2026-03-23T10:30+11:00 -->

# Dependencies

## Hallucinated Reference Prevention
- **Verify before referencing.** For any URL, package, CLI tool, or API endpoint not already in the codebase, verify it exists (WebSearch, `npm search`, or ask the user) BEFORE writing it.
- **Confirm the exact name, version, and import path.** Check `package.json`, the package registry, or official docs. A name that "sounds right" is the #1 source of hallucinated references.
- Ask the user if you don't know the real URL.
- **Verification has one round.** Search once for the package/API. If it doesn't exist, tell the user — do not try name variations or alternative packages without asking first.

## Dependency Hygiene
- **Ask before suggesting any new dependency.**
- Follow the project's dependency style (loose, tight, pinned).
- Respect lock file constraints.
- Run `npm audit` / `pnpm audit` before deployment. For each finding:
	1. Check if the affected code path is actually used.
	2. If yes, upgrade or find alternative. If no, document why it's acceptable.
