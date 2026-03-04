---
paths:
  # JS/Node/React
  - "**/package.json"
  - "**/tsconfig.*"
  - "**/vite.config.*"
  - "**/next.config.*"
  - "**/webpack.config.*"
  - "**/babel.config.*"
  - "**/tailwind.config.*"
  - "**/.eslintrc*"
  - "**/.prettierrc*"
  # PHP/WordPress
  - "**/composer.json"
  - "**/wp-config.php"
  - "**/phpunit.xml*"
  - "**/.php-cs-fixer*"
  # Cloudflare/Infra
  - "**/wrangler.*"
  - "**/Dockerfile*"
  - "**/docker-compose*"
  # Environment
  - "**/.env*"
---

# Environment & Tooling

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
