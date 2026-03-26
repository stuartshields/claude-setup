<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Security (Always-On)

Baseline patterns for every session. Use the `security` agent for deep audits.

## Injection Prevention
- **Use parameterized queries for all SQL.** No string concatenation with user input.
- **Use the framework's escaping mechanism for all output.** Never raw `v-html` without DOMPurify.
- **Validate URLs:** allow only `/`, `http://`, `https://`, `mailto:`. Block `javascript:` scheme.

## Secrets
- **Keep secrets in environment bindings.** Never log or hardcode `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`.
- Warn the user to rotate immediately if a secret is accidentally exposed.
