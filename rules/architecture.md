---
paths:
  - "**/*.js"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.vue"
  - "**/*.svelte"
  - "**/*.py"
  - "**/*.php"
  - "**/*.go"
  - "**/*.rs"
---
<!-- Last updated: 2026-03-21 -->

# Architecture

## Modular-First
- **200-Line Rule:** If a feature will exceed 200 lines, propose a modular split during planning.
- **Atomic Responsibility:** Logic -> `/hooks` or `/services`. Types -> `types/`. Sub-components -> `/components` or `/features`.

## Directory Mapping
> Defaults. Project CLAUDE.md overrides these.

- `/components`: Small, reusable UI units.
- `/features`: Large, domain-specific modules.
- `/hooks` or `/utils`: Logic and helpers.
- `/services`: API/External integrations.

## Monorepo Guidance
- **Identify the active package** before reading CLAUDE.md. Check: (1) package root, (2) monorepo root, (3) both — package-level overrides root.
- **Respect package boundaries.** Only import across packages if the dependency graph allows it.
- **Run commands in scope.** Use the package's build/test/lint, not root-level.
- **Check for shared configs** (tsconfig, eslint, prettier) at root. Packages may extend or override.
