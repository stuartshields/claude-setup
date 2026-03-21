<!-- Last updated: 2026-03-21 -->

# Security (Always-On)

Baseline patterns for every session. Use the `security` agent for deep audits.

## Input Validation
- **Validate all external input** (`req.query`, `req.body`, params, headers, cookies): presence, type, bounds.
- Sanitize before database or display.

## Injection Prevention
- **Use parameterized queries for all SQL.** No string concatenation or template literals with user input.
- **Use the framework's escaping mechanism for all output.** Vue: `{{ }}` or `v-text`. PHP: `esc_html()`. Never raw `v-html` without DOMPurify.
- **Validate URLs:** allow only `/`, `http://`, `https://`, `mailto:`. Block `javascript:` scheme.

## Secrets
- **Keep secrets in environment bindings.** Never log or hardcode `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`.
- Warn the user to rotate immediately if a secret is accidentally exposed.
