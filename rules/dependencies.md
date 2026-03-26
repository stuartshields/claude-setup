<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Dependencies

## Hallucinated Reference Prevention
- **Verify before referencing.** For any URL, package, CLI tool, or API endpoint not already in the codebase, verify it exists BEFORE writing it.
- **Confirm the exact name, version, and import path.** A name that "sounds right" is the #1 source of hallucinated references.
- Ask the user if you don't know the real URL.

## Dependency Hygiene
- **Ask before suggesting any new dependency.**
- Respect lock file constraints.
