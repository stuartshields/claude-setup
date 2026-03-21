---
paths:
  - "**/*.php"
  - "**/composer.json"
  - "**/phpunit.xml*"
---
<!-- Last updated: 2026-03-21 -->

# PHP & WordPress Backend

## Security (Non-Negotiable)

- **Output escaping**: Every echo/output MUST use the appropriate escape function:
	- `esc_html()` / `esc_html__()` - HTML content
	- `esc_attr()` / `esc_attr__()` - HTML attributes
	- `esc_url()` - URLs
	- `wp_kses()` / `wp_kses_post()` - rich HTML (allow-listed tags only)
	- Never `echo $var` without escaping
- **Prepared queries**: `$wpdb->prepare()` required for ALL `$wpdb->query()` / `$wpdb->get_results()` / `$wpdb->get_var()` calls with variables. No exceptions.
- **Nonces**: Forms must include `wp_nonce_field()`. Handlers must verify with `check_admin_referer()` or `wp_verify_nonce()`. AJAX must use `check_ajax_referer()`.
- **Input sanitisation**: All `$_GET`, `$_POST`, `$_REQUEST` must be sanitised: `sanitize_text_field()`, `absint()`, `sanitize_email()`, `sanitize_url()`, etc.
- **Never use**: `extract()`, `eval()`, `assert()`, `preg_replace()` with `e` modifier, `unserialize()` on user input.

## Internationalisation (i18n)

- **All user-facing strings MUST be translatable**. No hardcoded English in output.
- Use `__()` for returning, `_e()` for echoing, `esc_html__()` / `esc_attr__()` for escaped output.
- Plurals: `_n( 'singular', 'plural', $count, 'text-domain' )`
- Context: `_x( 'Post', 'noun', 'text-domain' )` when a word is ambiguous
- Text domain must match the plugin/theme slug. Never use a variable as text domain.
- `wp_set_script_translations()` for JS i18n (block editor, frontend scripts).
- Never concatenate translated strings - use `sprintf()`: `sprintf( __( 'Hello %s', 'td' ), $name )`

## WordPress Patterns

- **Queries**: Use `WP_Query` or `get_posts()` - never `query_posts()`. Add `'no_found_rows' => true` when pagination isn't needed.
- **Enqueue**: `wp_enqueue_script()` / `wp_enqueue_style()` only - never raw `<script>` / `<link>` tags. Declare dependencies array accurately.
- **Hooks**: `add_action()` / `add_filter()` - use named functions or class methods, not anonymous closures (makes unhooking impossible).
- **REST API**: `register_rest_route()` must include `permission_callback` (use `__return_true` explicitly for public). Include `sanitize_callback` and `validate_callback` on args.
- **Options**: Use `get_option()` with a default. Autoloaded options (`autoload=yes`) must be small - large data should use `autoload=no` or transients.
- **Transients**: `set_transient()` / `get_transient()` for cached external data. Always handle the `false` (expired/missing) case.

## PHP Standards

- `declare(strict_types=1)` at the top of new PHP files.
- Type hints on function parameters and return types.
- Namespaces for plugin/theme classes - PSR-4 autoloading via Composer.
- `match` over `switch` where appropriate (PHP 8.0+). Named arguments for readability on functions with many parameters.
