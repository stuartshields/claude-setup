---
name: debug-wp
description: Starts a structured interview to diagnose WordPress issues, then proposes a ranked list of solutions.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Skill: debug-wp

## When to Use

Use this skill when diagnosing any WordPress problem — white screen of death, plugin conflicts, 500 errors, broken layouts, admin lockouts, performance issues, migration failures, cron problems, or any "it was working yesterday" scenario.

Do NOT jump to solutions. Always complete the triage interview first.

## Procedure

### Phase 1: Triage Interview

Ask questions in this order. Use `AskUserQuestion` where possible for structured input. Stop early if the user provides enough context to confidently diagnose.

#### 1. Symptom

- What exactly is broken? (white screen, error message, wrong content, slow load, redirect loop, etc.)
- Is there a specific error message or error code? (copy/paste the exact text)
- Does it affect the frontend, the admin (`/wp-admin`), or both?

#### 2. Trigger

- When did this start? (after an update, migration, hosting change, new plugin, code edit)
- What was the last change made before the issue appeared?
- Was anything recently updated? (WordPress core, theme, plugin, PHP version, server config)

#### 3. Scope

- Does it affect all pages or specific pages/post types?
- Does it affect all users or only logged-in / logged-out users?
- Does it affect all browsers / devices or specific ones?
- Is this a single site or WordPress Multisite?

#### 4. Environment

- WordPress version
- PHP version
- Hosting type (shared, VPS, managed WP like WP Engine / Kinsta / Flywheel, local dev)
- Active theme (and whether it's a child theme)
- Recently activated or deactivated plugins
- Caching layers (page cache plugin, object cache like Redis/Memcached, CDN like Cloudflare)
- Is `WP_DEBUG` enabled?

#### 5. Logs & Evidence

- Ask for `wp-content/debug.log` or `content/debug.log` contents (if `WP_DEBUG_LOG` is enabled)
- Ask for server error log snippets (Apache `error_log`, Nginx `error.log`, or hosting panel logs)
- Ask for browser console errors (if frontend issue)
- Ask for relevant screenshots if the issue is visual

### Phase 2: Diagnosis

Based on the triage answers, work through the applicable fault trees below. Narrow down to the most likely root cause before proposing solutions.

#### Common Fault Trees

| Symptom | Investigation Path |
|---|---|
| **White Screen (WSOD)** | Check `debug.log` for fatal error. Common: PHP memory limit, fatal in theme `functions.php`, incompatible plugin after update. Try: `define('WP_MEMORY_LIMIT', '256M')`, rename active theme folder via FTP/SSH, rename `plugins/` folder to isolate. |
| **500 Internal Server Error** | Check server error log first. Common: corrupt `.htaccess`, PHP memory exhaustion, mod_security rule, broken `wp-config.php`. Try: rename `.htaccess` and regenerate via Settings > Permalinks, increase `memory_limit` in `php.ini`. |
| **Plugin Conflict** | Deactivate all plugins, reactivate one at a time. If admin is inaccessible, rename `wp-content/plugins/` or `content/plugins/` via FTP/SSH to force-deactivate all. Binary search: activate half, test, narrow down. |
| **Theme Issue** | Switch to a default theme (Twenty Twenty-Four). If admin is broken, rename the active theme folder to force fallback. Check `functions.php` for syntax errors. Check template file compatibility with current WP version. |
| **Database Corruption** | Check `wp-options` for `siteurl` and `home` values. Run `wp db repair` via WP-CLI. Check for transient bloat: `wp transient delete --all`. Look for `autoload=yes` on oversized options. |
| **Login / Admin Lockout** | Check if a security plugin is blocking access (rename its folder). Reset password via WP-CLI: `wp user update admin --user_pass=newpass`. Check `.htaccess` for IP restrictions. Check `wp-config.php` for `FORCE_SSL_ADMIN` issues. |
| **Redirect Loop** | Check `siteurl` and `home` in `wp_options` (HTTP vs HTTPS mismatch). Check `.htaccess` for conflicting rewrite rules. Check CDN/proxy settings (Cloudflare flexible SSL + force HTTPS plugin = loop). |
| **Slow Performance** | Check for unoptimized queries (install Query Monitor plugin). Check object cache status. Check if page cache is active. Look at `autoload` options size: `wp db query "SELECT SUM(LENGTH(option_value)) FROM wp_options WHERE autoload='yes'"`. Check for excessive external HTTP requests in `wp-cron`. |
| **Cron Issues** | Check if WP-Cron is disabled (`DISABLE_WP_CRON` in `wp-config.php`). If so, confirm a system cron is configured. Check for stuck cron events: `wp cron event list`. Test manually: `wp cron event run --due-now`. |
| **Migration / URL Issues** | Search-replace old URLs: `wp search-replace 'old-domain.com' 'new-domain.com' --dry-run` first. Check serialized data handling (WP-CLI handles this). Flush permalinks. Clear all caches. |

#### Diagnostic Commands (WP-CLI)

If the user has WP-CLI access, suggest these for quick diagnostics:

```bash
# Check WP and PHP versions
wp --info
wp core version

# List active plugins with update status
wp plugin list --status=active --format=table

# Check for plugin/theme errors
wp eval 'error_reporting(E_ALL); ini_set("display_errors", 1);'

# Check database tables
wp db check

# Check option sizes (bloat detection)
wp db query "SELECT option_name, LENGTH(option_value) AS size FROM wp_options WHERE autoload='yes' ORDER BY size DESC LIMIT 20"

# Check cron health
wp cron event list --format=table

# Verify checksums (detect modified core files)
wp core verify-checksums
wp plugin verify-checksums --all
```

### Phase 3: Ranked Solutions

After diagnosis, present solutions as a **numbered list ordered by**:

1. **Likelihood** — most probable fix first
2. **Reversibility** — safest / most easily undone fixes before destructive ones
3. **Effort** — quick wins before complex multi-step fixes

For each solution, include:

- **What to do** — specific steps, commands, or file edits
- **Why this fixes it** — brief explanation connecting back to the diagnosed root cause
- **Risk level** — Low (easily reversed), Medium (backup recommended), High (data loss possible)
- **Rollback plan** — how to undo if it makes things worse

Always recommend a **backup before any fix** that modifies files or database. Suggest `wp db export backup.sql` or the hosting provider's snapshot tool.

### Phase 4: Follow-Up

After the user applies a fix:

- Confirm whether the issue is resolved
- If not, move to the next ranked solution
- If the original diagnosis was wrong, return to Phase 1 with the new information
- Once resolved, suggest preventive measures (update schedule, monitoring, staging environment for testing updates)

## Rules

- **Never skip the interview.** Even if the symptom seems obvious, confirm the environment and trigger before proposing fixes.
- **Never suggest editing core WordPress files** (`wp-includes/`, `wp-admin/`) — changes will be overwritten on update.
- **Always recommend child themes** if the fix involves theme file edits.
- **Always recommend backups** before database changes or file modifications.
- **Prefer WP-CLI commands** when the user has shell access — they're more precise and scriptable than admin UI steps.
- **Prefer reversible fixes first** — renaming a folder is safer than deleting it.
