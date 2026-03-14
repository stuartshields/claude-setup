---
title: Core Guide
nav_order: 3
---

## CLAUDE.md

### What it does

Without a CLAUDE.md, Claude loses your explicit standing instructions. Auto memory can still retain learned patterns, but it doesn't replace clear project rules like "use tabs not spaces", "never use var", "always write tests first".

A CLAUDE.md file fixes this. It's a markdown file that loads automatically at the start of every session. Whatever you put in it, Claude reads it before responding to anything. Think of it as your standing instructions - the baseline expectations for how Claude behaves whenever you use it.

The CLAUDE.md in this repo is my global one. Open it - that's the actual file. It covers my workflow rules (plan before coding, write tests first), style defaults (tabs, ES6+, no console.log), and CLAUDE.md features like `@import` syntax and loading order.

Here's the section I rely on most - the workflow rules:

```markdown
## 1. MANDATORY WORKFLOW
- **Plan First**: If the user asks to investigate, review, or explore — report findings
  and wait for direction. If the user asks to fix, implement, add, or update — execute
  directly. Only gate on a `<plan>` when the scope is genuinely unclear.
- **Test First**: If the project has tests, write or update a failing test BEFORE implementing.
- **Context Pruning**: Read ONLY files strictly necessary for the current task.
- **No Yapping**: Skip introductions/conclusions. Output code or direct answers only.
- **Verify**: After implementing, run the project's build/test/lint command.
- **Scope Lock**: Do NOT modify files or add features beyond what the user asked for.
```

Without these rules, Claude will frequently write speculative code, skip tests, and add "helpful" extras you didn't ask for. With them, it behaves predictably.

**Tip:** Run `/init` in any project to generate a starting CLAUDE.md based on your project structure.

**What about [AGENTS.md](https://agents.md/)?** AGENTS.md is an open standard (under the Linux Foundation) that does the same job as CLAUDE.md but works across multiple AI coding tools - Codex, Cursor, Copilot, Gemini CLI, and others. Claude Code doesn't read AGENTS.md natively yet ([feature request](https://github.com/anthropics/claude-code/issues/6235)). If you use other AI tools alongside Claude Code and want a single source of truth, you can symlink them: `ln -s CLAUDE.md AGENTS.md`. Or reference it from CLAUDE.md with `@AGENTS.md`. If you only use Claude Code, you don't need AGENTS.md at all - CLAUDE.md already covers everything it does, plus Claude-specific features like `@import`, loading order, and `CLAUDE.local.md`.

One pattern worth stealing: notice the `> Last verified: 2026-03-08` line in section 4. Claude Code features evolve quickly. When you state facts about tool features (loading order, settings keys, hook events), date them and link docs. That gives you a clear freshness signal and makes stale guidance obvious.

<details markdown="1">
<summary>Full CLAUDE.md content</summary>

```markdown
# GLOBAL PROTOCOL (v2026.2)

## 0. SHORTCUTS & TRIGGERS
- **Bootstrap Trigger**: If the current directory lacks a `CLAUDE.md`, immediately perform **DYNAMIC PROJECT INITIALIZATION**.
- **"Trace"** or **"/trace"**: Perform a deep-trace audit per the debugging rules in `~/.claude/rules/debugging.md`.

## 1. MANDATORY WORKFLOW
- **Plan First**: If the user asks to **investigate, review, or explore** — report findings and wait for direction. If the user asks to **fix, implement, add, or update** — execute directly. Only gate on a `<plan>` when the scope is genuinely unclear (not when you've already identified the changes). See Complexity Routing below for file-count thresholds.
- **Test First**: If the project has tests, write or update a failing test BEFORE implementing. Run the test to confirm it fails, then implement, then run again to confirm it passes.
- **Context Pruning**: Read ONLY files strictly necessary for the current task.
- **No Yapping**: Skip introductions/conclusions. Output code or direct answers only.
- **Verify**: After implementing, run the project's build/test/lint command. If it fails, diagnose and fix before moving on. Never mark work as done without verifying it runs.
- **Scope Lock**: Do NOT modify files or add features beyond what the user asked for. No unrequested refactors, no bonus improvements, no "while I'm here" changes.
- **On Compaction**: Always preserve in the summary: all modified file paths, the current task and acceptance criteria, test commands and results, key decisions and reasoning.
- **CLAUDE.md is the Source of Truth**: Before making changes, read the project's `CLAUDE.md`. If your changes diverge from what it specifies, ask the user: "This differs from the project CLAUDE.md - should I update it first?" Update CLAUDE.md **early** - when you discover a new convention, make an architecture decision, or establish a pattern, propose the update immediately. Do not wait until the end of the task. Sessions can crash, compact, or be interrupted - anything not written to CLAUDE.md is lost.
- **Complexity Routing**: For changes touching 6+ files or requiring architectural decisions, ask: "This is complex enough to warrant structured planning. Want me to handle it ad-hoc or write a formal plan?" For 3-5 files, write the plan to `.planning/PLAN.md` instead of an ephemeral `<plan>` tag. For 6+ files, use [GSD](https://github.com/gsd-build/get-shit-done) if installed, or create a `.planning/` structure manually.

## 2. DYNAMIC PROJECT INITIALIZATION / MIGRATION
- **Condition: No local CLAUDE.md**:
	1. Scan configs (`package.json`, `requirements.txt`, etc.).
	2. Identify stack & commands (build/test/lint).
	3. Create local `CLAUDE.md` with project-specific conventions.
- **Condition: Local CLAUDE.md exists but is legacy**:
	1. Strip redundant rules (global rules in `~/.claude/rules/` are auto-loaded).
	2. Keep only project-specific conventions.
	3. Standardize indents to Tabs.

## 3. STYLE DEFAULTS
- **Indents**: Tabs.
- **JavaScript**: ES6+ only. Use ES Modules (`import`/`export`), arrow functions, `const`/`let` (never `var`), template literals, destructuring, async/await. No CommonJS (`require`/`module.exports`).
- **CSS**: TailwindCSS v4 with the TailwindCSS CLI (`@tailwindcss/cli`). CSS-first config (`@theme` in `input.css`), no `tailwind.config.js`.
- **Cleanliness**: No trailing whitespace, no `console.log`, no "just-in-case" try/catch.
- **Simplicity**: Prefer the fewest lines of code. No new dependencies without asking.

## 4. CLAUDE.MD FEATURES
> Last verified: 2026-03-09. Official docs: https://code.claude.com/docs/en/memory

- **Loading order** (highest priority first): Managed policy > Local (`CLAUDE.local.md`) > Project (`./CLAUDE.md` or `./.claude/CLAUDE.md`) > User (`~/.claude/CLAUDE.md`)
- **`CLAUDE.local.md`**: Project-local, gitignored. Use for personal notes that shouldn't be committed.
- **`@path/to/import`**: Import other files into CLAUDE.md (up to 5 hops).
- **`claudeMdExcludes`**: Settings key to skip specific CLAUDE.md files (useful for monorepos).
- **Rules with `paths` frontmatter**: Only loaded when working with matching files. Rules without `paths` load every session.

## 5. EXTENDED RULES
Rules auto-loaded from `~/.claude/rules/`:
- **Always loaded**: architecture, style, security, verification, testing, debugging, dependencies, discipline
- **Conditional** (loaded when working with matching files): ui-ux, environment, php-wordpress
```

*Last synced with CLAUDE.md: 2026-03-13*

</details>

### CLAUDE.local.md

There's a second file worth knowing: `CLAUDE.local.md`. It lives alongside `CLAUDE.md` but is gitignored. Use it for personal notes that shouldn't be committed - your API keys, reminders about a local dev setup, project context that's specific to your machine. It loads at the same scope as `CLAUDE.md` but stays out of version control.

### @import syntax

CLAUDE.md supports `@path/to/file` imports. Instead of one giant file, you can split instructions across focused files and import them. That's what the `rules/` directory in this repo is for - each rule file covers one concern (security, testing, debugging, etc.), and they're loaded via `@import` references in CLAUDE.md.

The import system supports up to 5 hops. First time Claude encounters an `@import`, it asks for approval. If you decline, that import stays disabled permanently for that file.

See [Rules](#rules) for how this works in practice.

---

## Loading Order

Claude Code loads CLAUDE.md files from multiple locations. The priority order, highest to lowest:

| Priority | Scope | Path | Notes |
|----------|-------|------|-------|
| 1 | Managed policy | System-managed | Can't be overridden by anything |
| 2 | Local | `CLAUDE.local.md` | Gitignored personal notes |
| 3 | Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Project-specific instructions |
| 4 | User (global) | `~/.claude/CLAUDE.md` | Your baseline - this repo |

More specific locations take precedence over broader ones. If your project's `CLAUDE.md` says "use 2-space indentation" but your global says "use tabs", the project wins.

One exception: array settings like `permissions.allow` **merge** across scopes rather than override. Add an allow rule at project level and it stacks on top of your global allows.

A few other loading behaviors worth knowing:

- CLAUDE.md files in **parent directories** above your working directory are also loaded (walking up the tree)
- **Subdirectory** CLAUDE.md files load on demand when Claude reads files in those directories
- The `claudeMdExcludes` setting in `settings.json` lets you skip specific CLAUDE.md files - useful in monorepos where you want to suppress a package's CLAUDE.md

**This repo demonstrates the user-global scope** (`~/.claude/`). Individual projects can also have `./CLAUDE.md` or `./.claude/CLAUDE.md` files that layer on top. The global rules here form the baseline; project files add or override for specific codebases.

---

## Rules

Without rules, you repeat the same instructions every conversation. "Use tabs." "No console.log." "Always parameterize SQL." "Don't add unrequested features." Every. Single. Session.

Rules fix that. Files in `~/.claude/rules/` load automatically at the start of every session - Claude reads them before doing anything else. Each file covers one concern. When a file gets too long, split it. Single responsibility applies to rules files the same way it applies to code.

The rules in this repo import automatically because the [CLAUDE.md](#claudemd) `@import` syntax pulls them in. But the `~/.claude/rules/` directory also has a special property: files there load unconditionally without any explicit `@import` (unless you have `paths:` frontmatter - more on that below).

### Always-loaded rules

These 8 files load every session, regardless of what project you're working on:

| File | What problem it solves |
|------|----------------------|
| `architecture.md` | Prevents God Files - enforces the 200-line rule, atomic responsibility, and directory mapping |
| `debugging.md` | Stops guessing - requires tracing data flow before proposing any fix |
| `dependencies.md` | Blocks hallucinated packages and unvetted dependencies from entering the codebase |
| `discipline.md` | Prevents scope creep, bonus refactors, TODO placeholders, and over-engineered abstractions |
| `security.md` | Enforces parameterized queries, input validation, and XSS prevention on every coding task |
| `style.md` | Enforces tabs, clean code, no truncated snippets - no "// ... rest of code" shortcuts |
| `testing.md` | Enforces test-first workflow with failing tests before implementation, AAA pattern |
| `verification.md` | Requires running build/test after every change - never assume success from a clean write |

Here's a taste of what a rule file looks like - this is the SQL injection section from `security.md`:

```markdown
## SQL Injection Prevention
- **ALWAYS use parameterized queries.** No exceptions, in any language or ORM.
	- D1/SQLite: `db.prepare("SELECT * FROM cafes WHERE city = ?").bind(city).all()`
	- WordPress: `$wpdb->prepare("SELECT * FROM %i WHERE city = %s", $table, $city)`
	- Any other stack: use the equivalent parameterized query API.
- Never construct SQL via string concatenation or template literals with user input.
```

This is the pattern across all rules: specific, actionable, no ambiguity. Claude can't reinterpret "never construct SQL via string concatenation" to mean something convenient. The full content of each rule file is in the `rules/` directory.

### Conditional rules

Some rules only matter for certain file types. Loading PHP rules when you're writing JavaScript wastes context - those tokens could be used for something relevant.

The `paths:` frontmatter mechanism handles this. Add a YAML block at the top of a rule file, and Claude only loads that file when it reads a file matching one of the listed glob patterns. Here's what it looks like in `environment.md`:

```yaml
---
paths:
  # JS/Node/React
  - "**/package.json"
  - "**/tsconfig.*"
  - "**/vite.config.*"
  # PHP/WordPress
  - "**/composer.json"
  - "**/wp-config.php"
  # Cloudflare/Infra
  - "**/wrangler.*"
  - "**/Dockerfile*"
  # Environment
  - "**/.env*"
---
```

The five conditional rules in this repo and what triggers each:

| File | Triggers on |
|------|------------|
| `environment.md` | `.env`, Docker, deployment config, `package.json`, `tsconfig`, `wrangler` |
| `figma.md` | CSS, SCSS, HTML, JSX, TSX, Vue, PHP, component/block/template directories |
| `playwright.md` | CSS, SCSS, HTML, JSX, TSX, Vue, test/spec/e2e files, component/page/view directories |
| `php-wordpress.md` | `.php` files, `wp-config.php`, `composer.json`, `phpunit.xml` |
| `ui-ux.md` | Component files, CSS, layout files |

The Figma rule enforces using Figma MCP tools (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`) instead of guessing at design specs. When Claude reads a CSS or component file while a Figma URL is in context, this rule requires it to call the actual Figma API for measurements, colors, spacing, and visual verification before writing any code. The rule exists because without it, Claude tends to assume what a design looks like rather than fetching the actual specs, which leads to subtle but persistent visual bugs.

The Playwright rule enforces proper usage of the Playwright MCP's browser automation tools. It establishes that `browser_snapshot` (accessibility tree) should be the default for understanding page state and planning actions, while `browser_take_screenshot` is reserved for visual verification. The rule includes a Figma comparison workflow: capture the Figma design screenshot, navigate to the implementation, resize the viewport to match, take a browser screenshot, and compare until visual parity is achieved. It also covers form interaction patterns, debugging with console/network tools, and token efficiency for large pages.

Key insight from testing: conditional rules trigger on **file-read, not tool-use**. Claude reads a `.php` file → PHP rules load. Claude hasn't read any `.php` files in the session → PHP rules stay unloaded. If you're debugging why a conditional rule isn't firing, check whether Claude has actually read a matching file yet.

See [Hooks](../hooks/README.md) for lifecycle automation that complements these persistent instructions.

---


## Settings

The `settings.json` in this repo is a template. **Copy it to `~/.claude/settings.json`** - that's where Claude Code looks for it. A `settings.json` at the repo root is not a recognized Claude Code path and will be silently ignored.

```bash
cp settings.json ~/.claude/settings.json
```

### Permissions

The permissions system uses `allow` and `deny` rules with a `Tool(pattern)` syntax. Claude asks for approval on anything not explicitly allowed or denied; explicit rules skip the prompt.

```json
"permissions": {
  "allow": [
    "Read(package.json)",
    "Read(CLAUDE.md)",
    "Read(wrangler.toml)"
  ],
  "deny": [
    "Read(.env)",
    "Read(.env.*)",
    "Read(**/node_modules/**)"
  ]
}
```

Pattern wildcards: `*` matches within a single directory level. `**` matches across directories.

Why the deny rules? The `.env` deny prevents Claude from reading secrets that don't need to be in context. The `node_modules` deny prevents it from indexing thousands of dependency files when it does a broad search. Same logic for `dist/`, `build/`, lock files - noise that adds tokens without value.

The `allow` rules pre-approve commonly-needed config files so Claude doesn't prompt every time it wants to read `package.json` or `CLAUDE.md`.

### Hook registration

Hooks connect to lifecycle events in `settings.json`. Each event takes an array of hook objects with an optional `matcher` field and a list of `hooks`:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/check-code-quality.sh"
        }
      ]
    }
  ]
}

---

## Continue Reading

- Governance checklist: [Governance Review Template](governance-review-template.md)
- Hook lifecycle and examples: [Hooks README](../hooks/README.md)
- Agent frontmatter and usage: [Agents README](../agents/README.md)
- Skills and memory guide: [Skills README](../skills/README.md)
```

The `matcher` field filters by tool name - only fires the hook when the matched tool is called. Omit `matcher` to fire on every tool call for that event. See [Hooks](../hooks/README.md) for the exit code contract and what these hooks do.

### Hook scoping and teams

Hooks from all settings files **merge - they don't override**. If your global `~/.claude/settings.json` registers a `PreToolUse` hook and a project's `.claude/settings.json` registers another, both run. Identical commands are deduplicated, but different hooks all fire.

This matters in teams. Settings files and what they're for:

| File | Scope | In git? | Who sees it |
|------|-------|---------|-------------|
| `~/.claude/settings.json` | Global (your machine) | No | Just you |
| `.claude/settings.json` | Project (shared) | Yes | Everyone on the team |
| `.claude/settings.local.json` | Project (personal) | No | Just you |

**You cannot disable a specific global hook from a project file.** There's no blacklist. Your options:

1. **`"disableAllHooks": true`** - nuclear option. Put it in `.claude/settings.json` or `.claude/settings.local.json` to kill all hooks for that project. Managed policy hooks (enterprise) are exempt.
2. **Don't register personal hooks at project level.** If a hook is personal preference (like notification sounds), keep it in `~/.claude/settings.json` - not in the project's `.claude/settings.json`.
3. **Use `/hooks` menu** - toggle all hooks on/off for the current session.

**Example: the Bronson problem.** You add `notification-alert.sh` to the team's `.claude/settings.json` because you want everyone to hear when Claude needs input. Bronson hates it. But Bronson can't disable just that one hook - hooks merge, not override. His only escape is `"disableAllHooks": true` in `.claude/settings.local.json`, which kills *all* hooks including the code quality gates he actually wants.

The fix: don't put notification hooks in project settings. Keep them in personal `~/.claude/settings.json`. Each teammate chooses their own alert style (or none). Reserve `.claude/settings.json` for hooks the whole team needs - quality gates, security checks, project-specific linting.

```
~/.claude/settings.json          ← Your notification hooks, personal preferences
.claude/settings.json             ← Team hooks: quality gates, security, linting
.claude/settings.local.json       ← Personal project overrides (gitignored)
```

Settings also control `claudeMdExcludes` (skip specific CLAUDE.md files) and settings precedence: Managed policy > CLI args > Local > Project > User. Array settings like `permissions.allow` merge across scopes rather than override - project-level allow rules stack on top of global ones.

<details markdown="1">
<summary>Full settings.json</summary>

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Read(package.json)",
      "Read(tsconfig.json)",
      "Read(pyproject.toml)",
      "Read(README.md)",
      "Read(.eslintrc*)",
      "Read(CLAUDE.md)",
      "Read(.claude/CLAUDE.md)",
      "Read(wrangler.toml)",
      "Read(vite.config.*)",
      "Read(next.config.*)",
      "Read(composer.json)",
      "Read(phpunit.xml*)",
      "Read(.php-cs-fixer*)"
    ],
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(.dev.vars)",
      "Read(.dev.vars.*)",
      "Read(./secrets/**)",
      "Read(**/node_modules/**)",
      "Read(**/*.lock)",
      "Read(**/dist/**)",
      "Read(**/build/**)",
      "Read(**/tests/fixtures/**)",
      "Read(**/.git/**)",
      "Read(**/coverage/**)",
      "Read(**/.next/**)",
      "Read(**/*.map)",
      "Read(**/*.chunk.*)",
      "Read(**/package-lock.json)",
      "Read(**/wp-config.php)",
      "Read(**/auth.json)",
      "Read(**/.npmrc)",
      "Read(**/.htpasswd)",
      "Read(**/*.pem)",
      "Read(**/credentials.json)",
      "Read(**/.wrangler/**)",
      "Read(**/*.sqlite*)",
      "Read(**/*.db)",
      "Read(**/vendor/**)",
      "Read(**/__pycache__/**)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|resume",
        "hooks": [{ "type": "command", "command": "rm -f /tmp/claude-remind-* 2>/dev/null; exit 0" }]
      },
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/compact-restore.sh" }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/block-git-commit.sh" }]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/check-code-quality.sh" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/stop-dispatcher.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/track-modified-files.sh" }]
      },
      {
        "matcher": "TaskCreate|TaskUpdate",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/track-tasks.sh" }]
      },
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/detect-perf-degradation.sh" }]
      }
    ],
    "PostToolUseFailure": [
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/detect-perf-degradation.sh" }]
      }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/remind-project-claude.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/check-unfinished-tasks.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/verify-before-stop.sh" }] }
    ],
    "PreCompact": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/pre-compaction-preserve.sh" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/session-cleanup.sh" }] }
    ],
    "PermissionRequest": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/permission-notify.sh" }] }
    ],
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notification-alert.sh" }] }
    ]
  },
  "enabledPlugins": {
    "frontend-design@claude-code-plugins": true,
    "claude-hud@claude-hud": true,
    "swift-lsp@claude-plugins-official": true,
    "figma@claude-plugins-official": true
  }
}
```

</details>

> **Note:** The `enabledPlugins` block lists plugins specific to this setup - remove or replace with your own.

---


## Beyond Default Claude

Out of the box, Claude Code reads your CLAUDE.md, runs tools, and follows instructions. This setup goes further - enforcing behaviours that Claude won't do on its own, and catching failure modes that instructions alone can't prevent.

Everything below is implemented through the rules, hooks, and agents in this repo. None of it requires external tools or plugins (except GSD, which is optional).

### Test-Driven Development

Claude's default behaviour is implementation-first: write the code, then write tests that confirm it works. This is backwards - tests written after seeing the implementation tend to test what the code *does*, not what it *should do*. The result: tests pass, but the code has bugs.

This setup enforces a strict TDD cycle through `rules/testing.md`:

1. **Write a failing test first** - from the requirement, not the code
2. **Verify it fails for the right reason** - "module not found" doesn't count; the assertion itself must fail
3. **Implement minimally** to make it pass
4. **Run the full suite** to catch regressions
5. **Mutation check** - mentally break the implementation (swap `>` for `>=`, remove a guard). If tests still pass, they're not testing what they claim

The rule also addresses the most common AI testing failure: **over-mocking**. Every mock is an assumption about how the real dependency behaves. If the assumption is wrong, the test passes and production breaks. The rule limits mocks to things you genuinely can't control (network, time, third-party APIs) and flags any test with more than 3 mocks as a design smell.

When users report bugs despite passing tests, the rule explicitly states: *the tests are wrong, not the user.* Claude is instructed to stop re-running the same tests and instead write a new test that reproduces the exact reported scenario.

### Deterministic Code Quality Gates

CLAUDE.md rules are advisory - Claude can ignore them under pressure, especially as context fills up. Hooks are deterministic. This setup uses `PreToolUse` hooks on `Edit|Write` that catch violations, plus a `PostToolUse` hook that auto-fixes indentation:

- **Tab enforcement** - spaces trigger a non-blocking warning (PreToolUse), then `fix-indentation.sh` auto-converts to tabs (PostToolUse). This replaced a blocking approach that caused 29 wasted API round-trips across 12 sessions and led Claude to bypass the hook via `python3`.
- **No console.log** - blocked in JS/TS files (exit 2)
- **No placeholder comments** - `// ...` and `// rest of...` are rejected with "write real code" (exit 2)
- **Security-sensitive file detection** - when editing auth, session, or crypto files, injects a security reminder into context
- **Dependency verification** - checks imported packages exist in `package.json`

Hard violations (console.log, placeholders) block the write. Soft violations (indentation) get auto-corrected so no tokens are wasted.

### Build and Test Verification on Stop

The `verify-before-stop.sh` logic now runs on `UserPromptSubmit` rather than `Stop`. Instead of running build/test at finish time, it emits a compact advisory reminder before prompts when there are uncommitted changes. The reminder is state-aware and only re-emits on state changes (or sparse intervals), so Claude gets a verification nudge without repeated prompt noise.

Stop itself stays block-only through `stop-dispatcher.sh`, which keeps finish-time decisions deterministic. Advisory guidance now belongs to prompt-time hooks; blocking remains reserved for true stop conditions.

### Shortcut Detection on Stop

The `stop-quality-check.sh` Stop hook catches a different failure mode: Claude declaring victory without actually finishing. It scans Claude's final message for patterns like deferred follow-ups ("in a separate PR"), rationalised pre-existing issues ("was already broken"), unverified success claims ("all done" with no test output), and listed-but-unfixed problems. When triggered, it blocks and feeds the issues back so Claude addresses them before finishing.

Stop checks now run through `stop-dispatcher.sh`, which emits one final Stop decision after evaluating the configured stop checks. This keeps Stop output stable and avoids per-hook output handling drift.

### Reasoning Loop and Error Spike Detection

The `detect-perf-degradation.sh` hook runs after every tool call (success and failure) and watches for two signals: the same tool called with identical input 3+ times (reasoning loop), or 5+ failures in the last 10 calls (degraded session). Warnings appear as system reminders so Claude can self-correct - try a different approach instead of repeating a broken one.

### Opinionated UI/UX Design

Claude produces generic-looking UI by default - centered layouts, default shadows, #000/#FFF, no micro-interactions. The conditional rule `rules/ui-ux.md` (loaded only when touching component/view/template files) enforces:

- **8pt grid** - all spacing in multiples of 8px (4px for tight spots)
- **Anti-AI polish** - empty states instead of blank screens, loading skeletons, toast notifications
- **Rich grays** - no pure black or white; use slate-900 and similar
- **Accessibility baseline** - semantic HTML, aria-labels, AA contrast, keyboard navigation
- **Micro-interactions** - hover/active states, transitions using whatever animation library is installed

### Manual Commit Control and Destructive Command Blocking

By default, Claude will `git commit` whenever it feels appropriate and can run any Bash command. The `block-git-commit.sh` PreToolUse hook blocks:

- **Git commits** - both `git commit` and GSD's `gsd-tools commit`
- **Destructive commands** - `rm -rf`, filesystem destruction patterns, recursive `chmod`/`chown` on broad paths
- **Data exfiltration** - `curl`/`wget` with POST data, upload flags, or data flags

This keeps commits under your control and prevents accidental (or prompt-injection-driven) destruction. The hook uses `exit 2` to block and feed the reason back to Claude, so it adapts rather than retrying.

### Context Preservation

When Claude's context window fills up, compaction summarises the conversation and discards details. The `pre-compaction-preserve.sh` and `compact-restore.sh` hooks save and restore critical context (modified files, current task, decisions) across compaction events. The `track-modified-files.sh` hook maintains a running list of what changed during the session.

### Specialised Agents

Beyond the default Agent tool, this setup defines 14 custom agents for specific domains. Some notable ones that go beyond what Claude does on its own:

| Agent | What it adds |
|-------|-------------|
| `ui-review` | Reviews frontend for usability, accessibility, responsive design - not just code correctness |
| `simplify` | Finds over-engineering and suggests concrete simplifications |
| `perf` | Runtime bottlenecks, bundle bloat, unnecessary network requests |
| `wp` / `wp-perf` / `wp-security` | WordPress-specific expertise following Human Made and 10up standards |
| `code-reviewer` | Read-only (`permissionMode: plan`), persistent memory across sessions (`memory: user`) |
| `test-writer` | Persistent memory (`memory: user`) - learns your test patterns across projects |
| `frontend-builder` / `backend-builder` | Run in isolated worktrees for parallel execution |

### Hardening (Optional)

This setup is opinionated but not locked down. If you want to go further, here are adjustments worth considering:

**Block all outbound network access.** The `block-git-commit.sh` hook blocks `curl`/`wget` with POST data, but doesn't block GET requests or `WebFetch`. For stricter environments, add `WebFetch` and `Bash(curl *)` to the `permissions.deny` array in `settings.json`, or use `/sandbox` for OS-level network isolation. Trade-off: Claude can't fetch docs or check URLs.

**Prune CLAUDE.md aggressively.** Community consensus is that CLAUDE.md instructions are suggestions, not contracts - and instruction-following quality degrades as line count increases. This repo's CLAUDE.md is 47 lines (well under the ~100-line ceiling). If you extend it, regularly ask: "Would removing this line cause Claude to make mistakes?" If not, cut it. Anything you can enforce via a hook, enforce via a hook instead.

**Restrict MCP server access.** If you use MCP servers, explicitly allowlist trusted ones rather than enabling all project servers. In `settings.json`:

```json
{
  "enabledMcpjsonServers": ["github", "memory"],
  "disabledMcpjsonServers": ["filesystem"]
}
```

### MCP Server Context Overhead

Each MCP server adds its tool definitions to your context window, even when the tools are not being used. This overhead is invisible but measurable.

#### Measuring Overhead

Run `/context` in Claude Code to see a breakdown of what consumes your context budget. Look for:

- **Tool definitions** -- each MCP server contributes a block of tool schemas. The more servers enabled, the larger this block.
- **MCP server instructions** -- some servers (like Figma) inject their own behavioral instructions alongside tool definitions.

#### Reducing Overhead

| Lever | How | When to Use |
|-------|-----|-------------|
| **Per-project disable** | Set `enabledPlugins` to `false` for unused servers in the project's `.claude/settings.json` | When a project never uses certain servers (e.g., disable Figma MCP on a backend-only project) |
| **Tool search threshold** | Set `ENABLE_TOOL_SEARCH=auto:N` where N is the minimum tool count before search activates | When you have many MCP servers but rarely need most of them |
| **Global vs project** | Enable servers globally, disable per-project where not needed | When different projects need different server sets |

#### Example: Disabling a Server Per-Project

Create or edit `.claude/settings.json` in the project root:

```json
{
  "enabledPlugins": {
    "figma@claude-plugins-official": false,
    "swift-lsp@claude-plugins-official": false
  }
}
```

This overrides the global setting for this project only. The servers remain available in other projects where they are needed.

**Async test runner.** The `verify-before-stop.sh` hook runs tests synchronously (blocks Claude for up to 30 seconds). If your test suite is fast and you want feedback after every file edit instead of only at stop time, add an async PostToolUse hook:

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "/path/to/run-tests-async.sh",
          "async": true,
          "timeout": 120
        }
      ]
    }
  ]
}
```

Trade-off: fires on every file write (noisy for large refactors), and async hooks can't block - Claude sees results on the next turn, not immediately. The synchronous Stop hook is better for enforcement; async PostToolUse is better for fast feedback loops.

---

## GSD

GSD is a workflow framework I use on top of Claude Code. It's not required for any of this to work. Everything in this repo - the rules, hooks, agents, settings - functions without it.

What GSD adds: structured planning (breaking work into phases and plans), phased execution with per-task commits, and verification gates between phases. If you see references to `.planning/` directories or `/gsd:` commands in the CLAUDE.md, that's GSD. You can safely ignore or remove those sections if you don't use it.

GSD installs its own hooks during setup (`gsd-check-update.js` for version checks, `gsd-context-monitor.js` for context window tracking). These are not included in this repo's `settings.json` - GSD manages them separately. If you install GSD and see these hooks added to your settings, that's expected.

More at: [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)

---

## Next Steps

The fastest path: clone, copy, restart.

```bash
git clone https://github.com/shieldsstuart/project-claude-setup
cp -r project-claude-setup/. ~/.claude/
```

Then adapt it. The rules are opinionated - they reflect how I work. Read through each one in `rules/` and remove or modify anything that doesn't fit your style. If you don't work with WordPress, delete `php-wordpress.md`. If you prefer a different SQL library, update the parameterized query examples in `security.md`.

The official docs go deeper on everything here:
- Claude Code docs: [code.claude.com/docs](https://code.claude.com/docs)
- Hooks reference: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

And if you want structured workflow on top: [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)
