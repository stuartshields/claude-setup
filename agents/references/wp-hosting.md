# WordPress Hosting Detection & Platform Reference

## Hosting Detection

Check CLAUDE.md first for an explicit `Hosting:` declaration — this is the **authoritative source** and overrides any auto-detection. Projects that have migrated between hosts (e.g., WP Engine → Kinsta) will have stale markers in their codebase (old mu-plugins, constants, config files). Only fall back to auto-detection if CLAUDE.md doesn't specify:

| Platform | Detection Markers |
|---|---|
| **Altis (HM Cloud)** | `altis/altis` or `altis/*` in `composer.json`, `.config/` directory with Altis YAML configs, `wp-content/mu-plugins/altis-*` |
| **WordPress VIP** | `automattic/vip-*` in `composer.json`, `vip-config/` directory, `wpcom-vip-*` mu-plugins, `VIP_GO_APP_ENVIRONMENT` constant |
| **WP Engine** | `mu-plugins/wpengine-common/` or `mu-plugins/wpe-wp-sign-on-plugin/`, `WPE_APIKEY` constant, `.wpe-push` config |
| **Kinsta** | `KINSTA_CACHE_ZONE` constant, `kinsta-mu-plugins/` |
| **Pantheon** | `PANTHEON_ENVIRONMENT` constant, `pantheon-systems/*` in composer |
| **Generic / Self-hosted** | None of the above markers found |

**If markers conflict** (e.g., WP Engine mu-plugins present but CLAUDE.md says Kinsta), trust CLAUDE.md and flag the stale hosting artifacts as cleanup candidates.

## Caching Stack by Platform

| Platform | Object Cache | Page Cache | CDN |
|---|---|---|---|
| **Altis** | Memcached (built-in) | Batcache (built-in) | CloudFront (built-in) |
| **VIP** | Memcached (built-in) | Edge cache (built-in) | Built-in |
| **WP Engine** | Memcached or Redis (plan-dependent) | EverCache (proprietary) | Optional CDN add-on |
| **Kinsta** | Redis (activate via dashboard) | Nginx full-page cache | Cloudflare (built-in) |
| **Pantheon** | Redis (built-in) | Varnish + Global CDN | Built-in |
| **Generic** | Check `object-cache.php` drop-in | Check for caching plugin | Check for CDN plugin/headers |

## Platform Security Features

| Platform | Built-in Security | Additional Attack Surface |
|---|---|---|
| **Altis** | `DISALLOW_FILE_MODS` enforced, XML-RPC restricted, `altis/security` module (login rate limiting, 2FA, headers), WAF at CDN layer | Altis-specific REST endpoints, `.config/` YAML misconfigs, Elasticsearch query injection if using raw ES queries |
| **VIP** | Code review before deploy, restricted filesystem, restricted functions, WAF, `DISALLOW_FILE_MODS` enforced | VIP-specific hooks, `vip-config/` secrets management, custom `wpcom_vip_*` function misuse |
| **WP Engine** | Managed updates, WAF, brute-force protection | No enforced `DISALLOW_FILE_MODS` by default — verify. SFTP access means broader attack surface than git-only deploy. |
| **Kinsta** | DDoS protection (Cloudflare), malware scanning, automatic backups | Redis connection security if exposed. SSH access means broader attack surface. |
| **Generic** | None assumed — check everything. | Full server-level audit may be needed. All configuration checks are relevant. |

## Platform-Specific Hosting Considerations

### Altis (HM Cloud)
- Built-in Elasticsearch via `altis/search` — prefer `Altis\Enhanced_Search` over raw `WP_Query` for complex search
- Object cache: **Memcached** (built-in, no config needed). Use `wp_cache_*` directly.
- Page cache: **Batcache** (built-in). Personalisation must be client-side JS.
- Built-in CDN (CloudFront). No need for external CDN plugins.
- Use Altis modules (`altis/cms`, `altis/media`, `altis/security`) — don't duplicate their functionality
- `DISALLOW_FILE_MODS` is always `true`
- Local dev via `composer serve` (Docker-based)
- Config in `.config/` YAML files, not `wp-config.php` constants

### WordPress VIP
- **Strict code review requirements.** VIP reviews all code before deploy.
- **Disallowed functions:** `query_posts()`, `wp_reset_query()`, `get_posts()` (use `WP_Query`), `wp_remote_get()` without caching, `$wpdb->prepare()` without proper usage, `switch_to_blog()` in loops
- Object cache: **Memcached** (built-in). Mandatory for production performance.
- Page cache: built-in edge caching. Cannot be bypassed selectively — design around it.
- No direct filesystem writes. Use VIP Files service for uploads.
- No `eval()`, `create_function()`, `extract()`, `file_put_contents()`, `file_get_contents()` for remote URLs
- Use `wpcom_vip_*` helper functions where available
- `wp_cache_get()` / `wp_cache_set()` — always use, especially for repeated queries
- No cron jobs that run longer than 60 seconds

### WP Engine
- Object cache: **Memcached** (built-in on most plans) or **Redis** (on higher plans). Check plan level.
- Page cache: **EverCache** (proprietary). Cleared per page or full-site via admin or API.
- No server config access (no `.htaccess` for Apache rules on their infrastructure)
- Git push deploys or SFTP — no Composer-based deploys by default
- Multisite supported but with caveats
- No custom PHP extensions

### Kinsta
- Object cache: **Redis** (built-in, activate via Kinsta dashboard). Use `wp_cache_*`.
- Page cache: **Nginx-based** full-page cache. Kinsta provides cache-purge plugin.
- CDN built-in via Cloudflare (Kinsta CDN). No external CDN plugin needed.
- SSH access available. WP-CLI available.
- Staging environments with push/pull. Be aware of environment-specific configs.
- PHP workers configurable per plan

### Generic / Self-hosted
- Verify what caching is in place (may be none). Suggest object cache + page cache if missing.
- Check server (Apache vs Nginx) for config-level optimisations.
- May need manual CDN setup, security hardening, etc.
