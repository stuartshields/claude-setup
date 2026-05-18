---
paths: "**/vite.config.*,**/next.config.*,**/webpack.config.*,**/babel.config.*,**/tailwind.config.*,**/.eslintrc*,**/.prettierrc*,**/tsconfig.*,**/wp-config.php,**/phpunit.xml*,**/.php-cs-fixer*,**/wrangler.*,**/Dockerfile*,**/docker-compose*,**/.env*"
---
<!-- Last updated: 2026-05-17T09:41+10:00 -->

# Environment & Tooling

## Node Version
- **Default to Node 22 in the active shell.** Before any `install`, `dev`, or build command: check `node --version`. If the major isn't 22 AND the project has no pin (`.nvmrc`, `engines.node`, `.tool-versions`, `volta.node`), run `nvm use 22`. Skip the switch if already on 22.
- **New Node projects pin to 22.** Write `.nvmrc` containing `22` and set `"engines": { "node": ">=22" }` in `package.json` so the contract is recorded for future sessions.
- **Existing pins win.** If a pin specifies a different major, honour it (`nvm use <version>`) and surface the divergence to the user — don't silently switch to 22.
- **Stop if the required major isn't installed.** Surface "Node X not installed — run `nvm install X` (needs your consent)" and wait. Don't auto-install.

## HTTPS by Default
- All new projects must use HTTPS for local development.
- **Why:** PWA features (Service Workers, Geolocation, Clipboard API, Web Push) require a secure context. HTTP-only dev hides bugs that only surface in production.
- **Vite:** Use `vite-plugin-basic-ssl` or `@vitejs/plugin-basic-ssl`.
- **Next.js:** Use `next dev --experimental-https` (v13.5+).
- **Cloudflare/Wrangler:** `wrangler dev` already uses HTTPS by default.
- **Exception:** Backend-only APIs or CLI tools that never touch browser APIs.

## Agents & Plugins
- **Worktree isolation:** Use `isolation: "worktree"` when launching builder agents (frontend-builder, backend-builder) in parallel. Not needed for read-only agents (explore, architect, code-reviewer).
- **Agent teams:** For changes touching 3+ domains (e.g., API + UI + tests), launch parallel agents with worktree isolation.
- **Model routing:** Haiku for pattern-matching (cleanup, simplify, explore). Sonnet for implementation (builders, test-writer). Opus for deep reasoning (architect, security audit).
