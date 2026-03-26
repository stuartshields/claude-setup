---
title: Core Guide
---
<!-- Last updated: 2026-03-21 -->

> **TL;DR:** CLAUDE.md gives Claude standing instructions. Rules enforce style and behavior (7 always-loaded, 8 scoped). Hooks enforce rules mechanically - blocking bad writes, catching incomplete work, detecting loops. Agents are specialists (18 custom) for code review, security, testing, and more. Keep always-on instructions under ~70 bullet points or Claude starts ignoring them.

Each component type has its own README with the problems it solves and how it's used: [Rules](../rules/README.md), [Hooks](../hooks/README.md), [Agents](../agents/README.md), [Skills](../skills/README.md). This guide explains how the pieces fit together.

## CLAUDE.md

### What it does

Without a CLAUDE.md, Claude loses your explicit standing instructions. Auto memory can still retain learned patterns, but it doesn't replace clear project rules like "use tabs not spaces", "never use var", "always write tests first".

A CLAUDE.md file fixes this. It's a markdown file that loads automatically at the start of every session. Whatever you put in it, Claude reads it before responding to anything. Think of it as your standing instructions - the baseline expectations for how Claude behaves whenever you use it.

The CLAUDE.md in this repo is my global one. Open it - that's the actual file. It covers my workflow rules (plan before coding, write tests first), style defaults (tabs, ES6+, no console.log), and CLAUDE.md features like `@import` syntax and loading order.

Here's the section I rely on most - the workflow rules:

```markdown
## 1. MANDATORY WORKFLOW
- **Plan First**: If the user asks to investigate, review, or explore - report findings
  and wait for direction. If the user asks to fix, implement, add, or update - execute
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
- **Plan First**: If the user asks to **investigate, review, or explore** - report findings and wait for direction. If the user asks to **fix, implement, add, or update** - execute directly. Only gate on a `<plan>` when the scope is genuinely unclear (not when you've already identified the changes). See Complexity Routing below for file-count thresholds.
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

## 3. RESEARCH SOURCES
- **Track external research per project.** When WebSearch/WebFetch informs a decision (library choice, architecture pattern, bug fix, API usage), append the source URL and a one-line summary to `.planning/SOURCES.md` in the project root.
- **Create `.planning/SOURCES.md` on first use.** Group by topic. Keep entries concise: `- [Title](URL) - why it was relevant`.
- **Check existing sources first.** Before researching a topic, read `.planning/SOURCES.md` if it exists - the answer may already be documented from a prior session.

## 4. STYLE DEFAULTS
- **JavaScript**: ES6+ only. Use ES Modules (`import`/`export`), arrow functions, `const`/`let` (never `var`), template literals, destructuring, async/await. No CommonJS (`require`/`module.exports`).
- **CSS**: TailwindCSS v4 with the TailwindCSS CLI (`@tailwindcss/cli`). CSS-first config (`@theme` in `input.css`), no `tailwind.config.js`.

## 5. CLAUDE.MD FEATURES
> Last verified: 2026-03-09. Official docs: https://code.claude.com/docs/en/memory

- **Loading order** (highest priority first): Managed policy > Local (`CLAUDE.local.md`) > Project (`./CLAUDE.md` or `./.claude/CLAUDE.md`) > User (`~/.claude/CLAUDE.md`)
- **`CLAUDE.local.md`**: Project-local, gitignored. Use for personal notes that shouldn't be committed.
- **`@path/to/import`**: Import other files into CLAUDE.md (up to 5 hops).
- **`claudeMdExcludes`**: Settings key to skip specific CLAUDE.md files (useful for monorepos).
- **Rules with `paths` frontmatter**: Only loaded when working with matching files. Rules without `paths` load every session.

## 6. EXTENDED RULES
Rules auto-loaded from `~/.claude/rules/`:
- **Always loaded**: debugging, dependencies, discipline, security, style
- **Conditional** (loaded when working with matching files): architecture, environment, harness-maintenance, php-wordpress, testing, ui-ux
```

*Last synced with CLAUDE.md: 2026-03-20*

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

These 5 files load every session (~76 bullet points total). With the system prompt's ~50 instructions, total is ~139 - under the ~150 ceiling where compliance degrades:

| File | What problem it solves |
|------|----------------------|
| `debugging.md` | Stops guessing - 4-step framework (Reproduce → Isolate → Fix → Validate), anti-loop protocol, hypothesis-driven investigation |
| `dependencies.md` | Blocks hallucinated packages and unvetted dependencies from entering the codebase |
| `discipline.md` | Prevents scope creep, incomplete implementations, simplicity-pivot avoidance, and bonus refactors. Includes hook awareness and verification checklist |
| `security.md` | Enforces parameterized queries, input validation, and XSS prevention on every coding task |
| `style.md` | Enforces tabs and clean code |

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

The six conditional rules in this repo and what triggers each:

| File | Triggers on |
|------|------------|
| `architecture.md` | Code files (`.js`, `.ts`, `.py`, `.php`, `.go`, `.rs`, etc.) |
| `environment.md` | `.env`, Docker, deployment config, `package.json`, `tsconfig`, `wrangler` |
| `harness-maintenance.md` | `~/.claude/` harness files (rules, hooks, agents, skills, settings) |
| `php-wordpress.md` | `.php` files, `wp-config.php`, `composer.json`, `phpunit.xml` |
| `testing.md` | Code files and test files (`*.test.*`, `*.spec.*`, `__tests__/`) |
| `ui-ux.md` | Component files, CSS, layout files |

The `harness-maintenance.md` rule is notable - it only loads when you're editing `~/.claude/` files (rules, hooks, agents, skills, settings). It enforces a research-first protocol: always validate with external sources (WebSearch/WebFetch) before modifying harness files, check the system prompt for duplicates, count instruction budget, and track source URLs. This prevents drift from stale training data assumptions.

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

### Debugging Without Loops

Claude's default debugging approach is to try the shortest fix first - which is wrong about half the time. When it fails, it tries a variation of the same wrong approach instead of stepping back to rethink. Three system prompt directives compound into this behavior: "try the simplest approach first" + "keep solutions simple" + "consider alternative approaches when blocked." Together they make Claude pivot away from correct-but-harder fixes toward easy workarounds.

The `debugging.md` rules counteract this with a strict 4-step framework:

1. **Reproduce** - run the faulty scenario, note the exact error
2. **Isolate** - narrow down the failing component (80% of bugs live in the 20% of code recently modified)
3. **Fix** - apply the targeted change, touching only the files the bug is in - but touching all of them
4. **Validate** - run the full test suite, confirm the fix AND no regressions

The anti-loop protocol is the part that actually changed behavior: each retry must use a different *diagnosis*, not just a different fix variation. After 2 failed attempts, Claude stops and asks for context instead of trying a third variation. If fixing A breaks B and fixing B breaks A, the rule explicitly says "the problem is contradictory constraints or a wrong mental model - not a code issue."

### Complete Implementations, Not Shortcuts

Claude has a documented tendency to implement the easy parts and silently skip the hard parts ([GitHub #24129](https://github.com/anthropics/claude-code/issues/24129)). It reads requirements fully but deliberately skips harder tasks to optimize for speed.

The `discipline.md` rules tackle this from two angles:

**"Complete Implementations Come First"** sits at the top of the file (primacy bias - highest attention weight). It says: implement every function body, every route handler, every component. "Minimal" means no extras - it does not mean skip the hard parts.

**"Do Not Pivot to Avoid Hard Work"** catches the specific failure pattern. When Claude says "actually, let me step back - the simplest approach that avoids rebuilding..." it's not being pragmatic. It's retreating from the correct fix because the work is harder than expected. The rule makes this explicit: if you catch yourself saying "let me step back" or "actually, a simpler approach," ask whether you're pivoting because the approach is wrong or because it's harder. If harder, continue.

Both rules are duplicated at the bottom of the file (recency bias) so they get attention at both ends of the instruction window. This is deliberate - [research shows](https://dev.to/docat0209/5-patterns-that-make-claude-code-actually-follow-your-rules-44dh) that rules in the middle of a file get the least attention weight.

### Test-Driven Development

Claude's default behaviour is implementation-first: write the code, then write tests that confirm it works. This is backwards - tests written after seeing the implementation tend to test what the code *does*, not what it *should do*. The result: tests pass, but the code has bugs.

This setup enforces a strict TDD cycle through `rules/testing.md`:

1. **Write a failing test first** - from the requirement, not the code
2. **Verify it fails for the right reason** - "module not found" doesn't count; the assertion itself must fail
3. **Implement minimally** to make it pass
4. **Run the full suite** to catch regressions
5. **Mutation check** - mentally break the implementation (swap `>` for `>=`, remove a guard). If tests still pass, they're not testing what they claim

The rule also addresses the most common AI testing failure: **over-mocking**. Every mock is an assumption about how the real dependency behaves. If the assumption is wrong, the test passes and production breaks. The rule limits mocks to things you genuinely can't control (network, time, third-party APIs) and suggests reconsidering the design if a test needs 3+ mocks.

A less obvious problem: Claude tests what's easiest, not what matters most. [One real-world case](https://christophermeiklejohn.com/ai/claude/2026/03/08/claude-tested-everything-except-the-one-thing-that-mattered.html) had 154 tests across 17 files, but the app's core feature (posting) was completely untested. The rule now says "test the core user-facing behavior first, before edge cases" to counteract this.

The rule also changed "one assertion per test" to "one behavior per test" - multiple assertions are fine if they verify the same behavior. The old wording caused unnecessary test file bloat for integration tests.

When users report bugs despite passing tests, the rule explicitly states: *the tests are wrong, not the user.* Claude is instructed to stop re-running the same tests and instead write a new test that reproduces the exact reported scenario.

### Deterministic Code Quality Gates

CLAUDE.md rules are advisory - Claude can ignore them under pressure, especially as context fills up. Hooks are deterministic. This setup uses `PreToolUse` hooks on `Edit|Write` that catch violations before they reach the filesystem:

- **Tab enforcement** - space indentation blocked (exit 2), forces rewrite with tabs
- **No console.log** - blocked in JS/TS files (exit 2)
- **No placeholder comments or stubs** - `// ...`, `// rest of...`, `// TODO: implement`, `// placeholder`, `// stub`, `throw new Error('not implemented')`, and Python `pass # todo` are all rejected with "write real code" (exit 2)
- **Security-sensitive file detection** - when editing auth, session, or crypto files, injects a security reminder into context (non-blocking)
- **Dependency verification** - checks imported packages exist in `package.json` (non-blocking)

The stub detection is worth explaining. Claude has a known tendency to write function signatures with placeholder bodies - `// TODO: implement this` or `throw new Error('not implemented')`. The rule in `discipline.md` says "implement every function body." The hook in `check-code-quality.sh` makes it mechanically impossible to ship a stub. If you've read the research on why prose rules get ignored (instruction-following degrades past ~150 rules), hooks are how you enforce the ones that matter most.

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
- **Accessibility baseline** - semantic HTML, accessible names (prefer native HTML over `aria-label` per [W3C First Rule of ARIA](https://www.w3.org/TR/using-aria/)), AA contrast, keyboard navigation
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

Beyond the default Agent tool, this setup defines 17 custom agents for specific domains. Some notable ones that go beyond what Claude does on its own:

| Agent | What it adds |
|-------|-------------|
| `ui-review` | Reviews frontend for usability, accessibility, responsive design - not just code correctness |
| `simplify` | Finds over-engineering and suggests concrete simplifications |
| `perf` | Runtime bottlenecks, bundle bloat, unnecessary network requests |
| `wp` / `wp-perf` / `wp-security` | WordPress-specific expertise following Human Made and 10up standards |
| `architect` | Persistent memory (`memory: user`) - retains architectural decisions across sessions |
| `code-reviewer` | Read-only (`permissionMode: plan`), persistent memory across sessions (`memory: user`) |
| `test-writer` | Persistent memory (`memory: user`) - learns your test patterns across projects |
| `frontend-builder` / `backend-builder` | `maxTurns: 30`, run in isolated worktrees for parallel execution |
| `simplify` | Upgraded to `model: sonnet` - proving behavioral equivalence requires deeper reasoning |

### Instruction Budget Management

This is easy to miss: Claude Code has a finite instruction budget. The system prompt takes ~50 instruction slots. Your always-loaded rules add more. [Research](https://dev.to/minatoplanb/i-wrote-200-lines-of-rules-for-claude-code-it-ignored-them-all-4639) shows that past ~150 total instructions, compliance degrades linearly - "double the instructions, halve the compliance."

This setup manages the budget by:
- **Keeping always-loaded rules lean** - 5 files, ~76 bullet points. With the system prompt, total is ~139.
- **Scoping aggressively** - `testing.md` and `architecture.md` used to load every session. Now they only load when you're working with code files. That saved 30 bullet points from sessions where they weren't relevant (editing config, writing shell scripts).
- **Deleting system prompt duplicates** - rules like "add error handling only for scenarios that can actually occur" already exist in Claude's system prompt. Restating them wastes a slot. We removed 4 such duplicates.
- **Merging small files** - `verification.md` had 7 bullet points, 4 of which duplicated other files. The unique parts (hook awareness) moved into `discipline.md`. One fewer file to load.

The `harness-maintenance.md` rule (only loaded when editing `~/.claude/` files) includes a budget check step: count always-on bullet points before adding new rules. If you're near 100, scope or consolidate before adding.

### Research-First Harness Changes

Training data gets stale. Claude Code updates frequently, and what was true about hook behavior or system prompt directives three months ago may not be true now. The `harness-maintenance.md` rule enforces external validation before making changes to rules, hooks, agents, or skills.

The protocol:
1. **WebSearch/WebFetch for external validation** - don't rely on training data for behavioral claims
2. **Check the [system prompt repo](https://github.com/Piebald-AI/claude-code-system-prompts)** - understand what the system prompt already says, so you don't duplicate it
3. **Check [known issues](https://github.com/anthropics/claude-code/issues)** - model-level behavioral patterns are documented there
4. **Check existing research** - a prior session may have already found the answer

After changes, source URLs go into a reference file so future sessions can re-validate decisions without re-researching from scratch. The CLAUDE.md also tracks external research per-project in `.planning/SOURCES.md` - same principle, project-level instead of harness-level.

### Hardening (Optional)

This setup is opinionated but not locked down. If you want to go further, here are adjustments worth considering:

**Block all outbound network access.** The `block-git-commit.sh` hook blocks `curl`/`wget` with POST data, but doesn't block GET requests or `WebFetch`. For stricter environments, add `WebFetch` and `Bash(curl *)` to the `permissions.deny` array in `settings.json`, or use `/sandbox` for OS-level network isolation. Trade-off: Claude can't fetch docs or check URLs.

**Prune CLAUDE.md aggressively.** Community consensus is that CLAUDE.md instructions are suggestions, not contracts - and instruction-following quality degrades as line count increases. This repo's CLAUDE.md is 32 lines (well under the ~100-line ceiling). The always-on rules add ~76 bullet points. With the system prompt's ~50, total is ~139 against a ~150 ceiling. If you extend it, regularly ask: "Would removing this line cause Claude to make mistakes?" If not, cut it. Anything you can enforce via a hook, enforce via a hook instead.

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
git clone https://github.com/stuartshields/claude-setup
cp -r claude-setup/. ~/.claude/
```

Then adapt it. The rules are opinionated - they reflect how I work. Read through each one in `rules/` and remove or modify anything that doesn't fit your style. If you don't work with WordPress, delete `php-wordpress.md`. If you prefer a different SQL library, update the parameterized query examples in `security.md`.

The official docs go deeper on everything here:
- Claude Code docs: [code.claude.com/docs](https://code.claude.com/docs)
- Hooks reference: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

And if you want structured workflow on top: [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)

---

## Continue Reading

[Previous: Start Here](start-here.md) | [Next: Governance Workflow](governance-workflow.md)

## Quick Links

- [Home](../index.md)
- [Start Here](start-here.md)
- [Governance Workflow](governance-workflow.md)
- [Rules](../rules/README.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)
- [Skills & Memory](../skills/README.md)
