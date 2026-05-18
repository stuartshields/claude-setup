<!-- Last updated: 2026-04-06T01:25+11:00 -->

# Dependencies

## Hallucinated Reference Prevention
- **Verify before referencing.** For any URL, package, CLI tool, or API endpoint not already in the codebase, verify it exists BEFORE writing it.
- **Confirm the exact name, version, and import path.** A name that "sounds right" is the #1 source of hallucinated references.
- Ask the user if you don't know the real URL.
- **Check for slopsquatting.** Verify registry publish date, download count, and maintainer history — 34% of AI-suggested deps don't exist. Attackers publish packages under hallucinated names.

## Dependency Hygiene
- **Ask before suggesting any new dependency.**
- Respect lock file constraints.
