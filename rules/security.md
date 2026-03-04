# Security (Always-On)

These rules apply to ALL coding, not just security audits. The `security` agent does deep audits on demand — these are the baseline patterns to follow in every session.

## Input Validation
- **Never trust external input** (`req.query`, `req.body`, `params`, headers, cookies).
- Validate: presence (not null/undefined), type (string/number/boolean), bounds (length, range, enum).
- Sanitize before database or display.

## SQL Injection Prevention
- **ALWAYS use parameterized queries.** No exceptions, in any language or ORM.
	- D1/SQLite: `db.prepare("SELECT * FROM cafes WHERE city = ?").bind(city).all()`
	- WordPress: `$wpdb->prepare("SELECT * FROM %i WHERE city = %s", $table, $city)`
	- Any other stack: use the equivalent parameterized query API — never interpolate user input into SQL strings.
- Never construct SQL via string concatenation or template literals with user input.

## XSS Prevention
- **General principle:** Never insert unsanitized user content into HTML. Use the framework's default escaping mechanism.
	- Vue: `v-text` or `{{ variable }}`. Never `v-html` unless sanitized with DOMPurify.
	- PHP/WordPress: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses()` — every output, every time.
	- Any other stack: use the equivalent auto-escaping or sanitisation API.
- Validate URLs: only allow `/`, `http://`, `https://`, `mailto:`. Never allow `javascript:` URLs.

## Secrets
- Never log secrets (`API_KEY`, `SECRET`, `TOKEN`, `PASSCODE`, `PASSWORD`).
- Never hardcode secrets in source — use environment bindings.
- If a session accidentally exposes a secret, warn the user to rotate it immediately.
