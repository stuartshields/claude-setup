---
name: qa-check
description: Auto-detects the project's tech stack, then audits for Accessibility, Performance, and Code Quality. Works across WordPress/PHP, Python, Node/JS, and static web projects.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

# Skill: qa-check (Global)

## When to Use

Run `/qa-check` on any web project to audit for Accessibility (WCAG 2.1 AA), Performance, and Code Quality issues. This skill auto-detects the tech stack and adapts its checks accordingly.

Do NOT fix issues — only report them. Present findings as structured Markdown tables.

## Procedure

### Phase 0: Stack Detection

Before running any checks, detect the project's tech stack by scanning the working directory for marker files. Report what was detected before proceeding.

#### Detection Rules

Scan in this order. A project can match **multiple** stacks (e.g., WordPress with Node build tools).

| Stack | Marker Files |
|---|---|
| **WordPress / PHP** | `wp-config.php`, `composer.json` with `"wordpress"`, `style.css` containing `Theme Name:`, `functions.php`, `wp-content/` directory |
| **Python** | `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`, `Pipfile`, `manage.py` (Django), `app.py` or `wsgi.py` (Flask) |
| **Node / JS** | `package.json` — then inspect for framework indicators: `next` (Next.js), `express` (Express), `nuxt` (Nuxt), `@angular/core` (Angular), `react` (React), `vue` (Vue), `svelte` (Svelte) |
| **Static Web** | `*.html` files in root or `src/`, `*.css` files, no backend markers detected |

#### Detection Output

Print a summary before running checks:

```
## Stack Detection

| Stack | Detected | Markers Found |
|---|---|---|
| WordPress/PHP | Yes/No | wp-config.php, style.css (Theme Name: ...) |
| Python | Yes/No | requirements.txt, manage.py |
| Node/JS | Yes/No | package.json (express, react) |
| Static Web | Yes/No | index.html, styles.css |
```

Then determine which template/view files to scan:

- **WordPress:** `*.php` in theme directory, `template-parts/`, `templates/`, `inc/`
- **Python (Flask):** `templates/**/*.html`, `app/templates/**/*.html`
- **Python (Django):** `**/templates/**/*.html`, `**/templatetags/*.py`
- **Node (Next.js):** `pages/**/*.{js,jsx,tsx}`, `app/**/*.{js,jsx,tsx}`, `components/**/*.{js,jsx,tsx}`
- **Node (Express):** `views/**/*.{ejs,pug,hbs,html}`, `public/**/*.html`
- **Node (React/Vue/Svelte):** `src/**/*.{jsx,tsx,vue,svelte}`
- **Static Web:** `*.html`, `src/**/*.html`

Also scan: all `*.css` files, all `*.js` or `*.ts` files in source directories, config files (`.env*`, `*.config.*`).

---

### Pillar 1: Accessibility (WCAG 2.1 AA)

**Goal:** Confirm output pages meet WCAG 2.1 AA requirements. These checks apply to all stacks — scan every file that produces HTML output.

| # | Check | What to Look For |
|---|---|---|
| 1 | **Semantic HTML** | `<header>`, `<main>`, `<footer>`, `<nav>` used correctly. Flag pages that use only `<div>` for major layout sections. |
| 2 | **Image alt text** | Every `<img>` must have an `alt` attribute. Empty `alt=""` is valid for decorative images. Flag any `<img>` with no `alt` at all. In PHP: check `<?php echo` img tags. In JSX: check `<img` components. |
| 3 | **Form labels** | Every `<input>`, `<select>`, `<textarea>` must have an associated `<label>` (via `for`/`id` pairing) or `aria-label`/`aria-labelledby`. Flag orphaned inputs. |
| 4 | **Link accessible names** | Every `<a>` must have visible text content, `aria-label`, or `aria-labelledby`. Flag empty links (icon-only without aria-label). Flag `<a>` with only an `<img>` child that lacks `alt`. |
| 5 | **Heading hierarchy** | No skipped heading levels (e.g., `<h1>` directly to `<h3>` without `<h2>`). Check across all templates that compose a full page. |
| 6 | **Focus styles** | Check CSS for `:focus-visible` or `:focus` rules. Flag any `outline: none` or `outline: 0` that lacks a replacement visible focus indicator. |
| 7 | **ARIA usage** | Flag misuse patterns: `role="button"` on `<a>` without `tabindex` and keyboard handler, `aria-hidden="true"` on focusable elements, invalid ARIA roles, redundant ARIA (e.g., `role="button"` on `<button>`). |
| 8 | **Colour contrast** | Flag hardcoded colour combos that appear low-contrast. Check text colour against background colour where both are set in the same rule or element. This is heuristic — flag suspicious combos for manual review. |
| 9 | **Language attribute** | `<html lang="...">` must be present in the root document. Flag if missing. |
| 10 | **Viewport meta** | `<meta name="viewport">` must be present. Flag if it contains `maximum-scale=1`, `user-scalable=no`, or `user-scalable=0` (these disable zoom). |

#### Stack-Specific A11y Checks

- **WordPress:** Check that `wp_nav_menu()` outputs use `<nav>` wrapper. Check `the_post_thumbnail()` calls for alt text support. Check `get_template_part()` partials for orphaned interactive elements.
- **React/JSX:** Check for `<img>` without `alt` prop. Check `onClick` on non-interactive elements (`<div onClick>`) without `role`, `tabIndex`, and `onKeyDown`. Check for `autoFocus` usage.
- **Vue:** Check `v-html` usage (potential a11y bypass — content may lack proper semantics). Check `:alt` bindings on images.

Report: **PASS** / **WARN** / **FAIL** per check.

---

### Pillar 2: Performance

**Goal:** Identify performance issues. Checks are adapted per detected stack.

| # | Check | What to Look For |
|---|---|---|
| 1 | **Image optimization** | `<img>` tags should have `width` and `height` attributes (CLS prevention). Below-fold images should have `loading="lazy"`. Flag large images without modern format alternatives (webp/avif). |
| 2 | **Asset loading** | Scripts should use `defer`, `async`, or `type="module"`. Flag render-blocking `<script>` tags in `<head>` without these attributes. Flag render-blocking CSS that could be deferred. |
| 3 | **Bundle size** | Check for large vendor files in public/static directories. Flag unminified JS/CSS in production paths (files > 50KB without `.min` in the name). |
| 4 | **N+1 queries** | Flag loops that contain database queries — this is a heuristic check. Look for query calls (`query`, `execute`, `cursor`, `fetchall`, `$wpdb->`, `Model.objects`, `select`, `find`) inside `for`/`foreach`/`while`/`map` blocks. |
| 5 | **Caching** | Check for cache-control patterns in server config, middleware, or headers. Flag if no caching strategy is apparent. |
| 6 | **External requests** | Scan templates for third-party URLs (`https://` to external domains) that could block rendering. Flag font services, analytics, and tracking pixels loaded synchronously. |
| 7 | **DNS prefetch / preconnect** | If external resources are used, check for `<link rel="dns-prefetch">` or `<link rel="preconnect">` hints. |

#### Stack-Specific Performance Checks

**WordPress:**
- Check for `wp_enqueue_script()` / `wp_enqueue_style()` usage vs raw `<script>` / `<link>` tags (should use enqueue system).
- Flag `query_posts()` usage — should use `WP_Query` or `get_posts()` instead.
- Flag missing `wp_cache_get()` / `wp_cache_set()` on expensive queries.
- Check if `wp_deregister_script('jquery')` is used properly (common source of breakage).
- Flag `get_posts()` / `WP_Query` calls without `'no_found_rows' => true` when pagination isn't needed.

**Python (Flask/Django):**
- Check for `select_related()` / `prefetch_related()` usage in Django views with related model access.
- Flag Flask routes that open database connections without connection pooling.
- Check for missing `@cache` decorators on expensive view functions.

**Node/JS:**
- Flag synchronous file operations (`readFileSync`, `writeFileSync`) in request handlers.
- Check for `node_modules` files accidentally served to the client.
- Flag missing `compression` middleware in Express.

Report: **PASS** / **WARN** / **FAIL** per check.

---

### Pillar 3: Code Quality

**Goal:** Identify security issues, code smells, and quality problems. Checks are adapted per detected stack.

#### Security (All Stacks)

| # | Check | What to Look For |
|---|---|---|
| 1 | **SQL injection** | String concatenation or f-strings in SQL queries. Must use parameterized queries / prepared statements. |
| 2 | **XSS (Cross-Site Scripting)** | Unescaped user output in templates. Check for raw output: `\|safe` (Jinja2), `{!! !!}` (Blade), `dangerouslySetInnerHTML` (React), `v-html` (Vue), `echo $var` without `esc_html()` (WP). |
| 3 | **CSRF** | State-changing routes (POST/PUT/DELETE) without CSRF token validation. Check for token presence in forms. |
| 4 | **Hardcoded secrets** | API keys, passwords, tokens, connection strings in source files. Regex scan for patterns: `password\s*=\s*['"]`, `api_key\s*=\s*['"]`, `secret\s*=\s*['"]`, `sk_live_`, `AKIA`, `ghp_`, `Bearer\s+[A-Za-z0-9]`. |
| 5 | **Environment files** | Check `.gitignore` for `.env` patterns. Flag if `.env` files are not gitignored. Flag `.env` files that exist in the repo (committed secrets). |

#### Stack-Specific Security

**WordPress / PHP:**
- `$wpdb->prepare()` must be used for all `$wpdb->query()` / `$wpdb->get_results()` calls with variables.
- All output must use `esc_html()`, `esc_attr()`, `esc_url()`, or `wp_kses()` as appropriate.
- Forms must include `wp_nonce_field()` and handlers must verify with `wp_verify_nonce()` or `check_admin_referer()`.
- User input must use `sanitize_text_field()`, `absint()`, `sanitize_email()`, etc.
- Flag `extract()` usage (variable injection risk).
- Flag `eval()`, `assert()`, `preg_replace()` with `e` modifier.

**Python:**
- Parameterized queries required for all database calls (no string formatting in SQL).
- No `eval()`, `exec()`, or `__import__()` with user-controlled input.
- No bare `except:` — must catch specific exceptions.
- Check for `pickle.loads()` on untrusted data.
- Check for `DEBUG = True` in production config.
- Check for `SECRET_KEY` hardcoded in settings.

**Node / JS:**
- No `eval()`, `Function()`, or `child_process.exec()` with user input.
- Check for `helmet` or manual security headers in Express apps.
- Check for `cors` configuration (not `origin: '*'` in production).
- Check for `--unhandled-rejections=none` or missing error handlers.
- Check `package.json` for `"engines"` field (Node version pinning).
- Flag `npm audit` issues if `package-lock.json` is present.

#### General Code Quality

| # | Check | What to Look For |
|---|---|---|
| 6 | **Error handling** | Empty `catch` / `except` blocks that swallow errors silently. Bare `try/except` in Python. `catch (e) {}` in JS. `catch (Exception $e) {}` in PHP without logging. |
| 7 | **Dead code** | Unused imports (heuristic — check if imported name is used in the file). Unreachable code after `return` / `break` / `continue` / `exit`. Commented-out code blocks (> 5 consecutive commented lines). |
| 8 | **Formatting consistency** | Mixed tabs and spaces for indentation within the same file. Inconsistent naming (camelCase mixed with snake_case in the same file, not counting external API names). |
| 9 | **Dependencies** | Check lockfile age (if `package-lock.json` or `Pipfile.lock` or `composer.lock` is > 6 months old based on git log, warn). Flag deprecated packages if detectable from lockfile metadata. |
| 10 | **TODO / FIXME / HACK** | Scan for `TODO`, `FIXME`, `HACK`, `XXX`, `TEMP` comments. Report count and locations — these indicate known technical debt. |

Report: **PASS** / **WARN** / **FAIL** per check.

---

### Output Format

Present results as Markdown tables. Use this exact structure:

```
## QA Audit — <date>

### Stack Detection

| Stack | Detected | Markers Found |
|---|---|---|
| WordPress/PHP | Yes/No | ... |
| Python | Yes/No | ... |
| Node/JS | Yes/No | ... |
| Static Web | Yes/No | ... |

**Files scanned:** <count> files across <directories>

---

### Summary

| Pillar | Status | Pass | Warn | Fail |
|---|---|---|---|---|
| Accessibility | PASS/WARN/FAIL | <n> | <n> | <n> |
| Performance | PASS/WARN/FAIL | <n> | <n> | <n> |
| Code Quality | PASS/WARN/FAIL | <n> | <n> | <n> |

Overall pillar status: FAIL if any check is FAIL, WARN if any check is WARN, PASS otherwise.

---

### Findings

#### Pillar 1: Accessibility

| # | Check | Status | Detail |
|---|---|---|---|
| 1 | Semantic HTML | PASS/WARN/FAIL | ... |
| 2 | Image alt text | PASS/WARN/FAIL | ... |
| ... | | | |

#### Pillar 2: Performance

| # | Check | Status | Detail |
|---|---|---|---|
| 1 | Image optimization | PASS/WARN/FAIL | ... |
| 2 | Asset loading | PASS/WARN/FAIL | ... |
| ... | | | |

#### Pillar 3: Code Quality

| # | Check | Status | Detail |
|---|---|---|---|
| 1 | SQL injection | PASS/WARN/FAIL | ... |
| 2 | XSS | PASS/WARN/FAIL | ... |
| ... | | | |

---

### Action Items

Numbered list of issues requiring attention, ordered by severity:

1. **[FAIL]** <description> — `<file>:<line>`
2. **[FAIL]** <description> — `<file>:<line>`
3. **[WARN]** <description> — `<file>:<line>`
...
```

---

## Rules

- **Do NOT fix issues.** Report only. The user decides what to fix.
- **Do NOT skip checks.** Run every applicable check for every detected stack. If a check is not applicable to the detected stack, mark it **N/A** in the table.
- **Be specific.** Include file paths and line numbers in findings where possible.
- **Avoid false positives.** If you're uncertain whether something is an issue, mark it **WARN** with an explanation, not **FAIL**.
- **Respect project conventions.** If a `CLAUDE.md` or equivalent project config exists, use its rules for formatting/naming checks instead of generic defaults.
- **Stack-specific checks are additive.** Always run the generic checks. Stack-specific checks are additional — they don't replace the generic ones.
- **Scan depth.** Scan all source files relevant to the detected stack. Do not scan `node_modules/`, `vendor/`, `venv/`, `.venv/`, `__pycache__/`, `dist/`, `build/`, `.git/`, or other dependency/build/cache directories.
