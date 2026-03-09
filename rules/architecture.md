# Architecture

## Modular-First
- **200-Line Rule:** If a feature's implementation is likely to exceed 200 lines, propose a modular split during planning.

  ```
  Bad:  utils.js (300 lines - auth, validation, formatting)
  Good: utils/auth.js, utils/validation.js, utils/formatting.js
  ```

- **Atomic Responsibility:** Move logic to `/hooks` or `/services`. Move types to `types/`. Extract sub-components into `/components` or `/features`.
- **Atomic Design:** Prefer many small, focused files over one "God File." If a file does more than one thing, split it.

## Directory Mapping
> Defaults. If the project's CLAUDE.md defines a different directory structure, follow that instead.

- `/components`: Small, reusable UI units.
- `/features`: Large, complex, domain-specific modules.
- `/hooks` or `/utils`: Logic and helper functions.
- `/services`: API/External integrations.

## Monorepo Guidance
- **Identify the active package** before reading CLAUDE.md. Check for `CLAUDE.md` at: (1) package root, (2) monorepo root, (3) both - package-level overrides root-level.
- **Respect package boundaries.** Don't import across packages unless the dependency graph allows it.
- **Run commands in scope.** Use the package's own build/test/lint commands, not root-level.
- **Shared config.** Look for shared configs (tsconfig, eslint, prettier) at the root. Packages may extend or override.
