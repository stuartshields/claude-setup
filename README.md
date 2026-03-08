# Claude Code Setup

Here's how I set up my Claude Code. This repo IS the configuration — the files here belong in `~/.claude/`. When you clone this and copy the contents to `~/.claude/`, you get persistent instructions, automated quality gates, and specialised subagents that apply across every project you work on.

The structure maps directly to `~/.claude/`: `rules/` → `~/.claude/rules/`, `agents/` → `~/.claude/agents/`, `hooks/` → `~/.claude/hooks/`, `skills/` → `~/.claude/skills/`, `settings.json` → `~/.claude/settings.json`. None of these directories belong in a project root — they're user-global configuration.

---

## Table of Contents

- [Quick Start](#quick-start)
- [CLAUDE.md](#claudemd)
	- [What it does](#what-it-does)
	- [CLAUDE.local.md](#claudelocalmd)
	- [@import syntax](#import-syntax)
- [Loading Order](#loading-order)
- [Rules](#rules)
	- [Always-loaded rules](#always-loaded-rules)
	- [Conditional rules](#conditional-rules)
- [Hooks](#hooks)
	- [Exit code contract](#exit-code-contract)
	- [Hook walkthrough: check-code-quality.sh](#hook-walkthrough-check-code-qualitysh)
- [Agents](#agents)
	- [Rules vs agents: when to use which](#rules-vs-agents-when-to-use-which)
- [Settings](#settings)
	- [Permissions](#permissions)
	- [Hook registration](#hook-registration)
- [Skills](#skills)
- [GSD](#gsd)
- [Next Steps](#next-steps)

---

## Quick Start

Want to try this now?

1. Clone this repo: `git clone https://github.com/shieldsstuart/project-claude-setup`
2. Copy the contents to your Claude directory: `cp -r project-claude-setup/. ~/.claude/`
3. Restart Claude Code (quit and reopen)
4. Open any project — your global rules, hooks, and agents are now active

That's it. Claude Code automatically loads `~/.claude/CLAUDE.md` at session start, picks up rules from `~/.claude/rules/`, runs hooks from `~/.claude/hooks/`, and makes agents from `~/.claude/agents/` available.

Read the rest of this to understand what each part does and why — so you can adapt it to your own workflow instead of just running mine.

---

## CLAUDE.md

### What it does

Without a CLAUDE.md, Claude loses your explicit standing instructions. Auto memory can still retain learned patterns, but it doesn't replace clear project rules like "use tabs not spaces", "never use var", "always write tests first".

A CLAUDE.md file fixes this. It's a markdown file that loads automatically at the start of every session. Whatever you put in it, Claude reads it before responding to anything. Think of it as your standing instructions — the baseline expectations for how Claude behaves whenever you use it.

The CLAUDE.md in this repo is my global one. Open it — that's the actual file. It covers my workflow rules (plan before coding, write tests first), style defaults (tabs, ES6+, no console.log), and CLAUDE.md features like `@import` syntax and loading order.

Here's the section I rely on most — the workflow rules:

```markdown
## 1. MANDATORY WORKFLOW
- **Plan First**: For any change > 2 files, output a `<plan>` and wait for approval.
- **Test First**: If the project has tests, write or update a failing test BEFORE implementing.
- **Context Pruning**: Read ONLY files strictly necessary for the current task.
- **No Yapping**: Skip introductions/conclusions. Output code or direct answers only.
- **Verify**: After implementing, run the project's build/test/lint command.
- **Scope Lock**: Do NOT modify files or add features beyond what the user asked for.
```

Without these rules, Claude will frequently write speculative code, skip tests, and add "helpful" extras you didn't ask for. With them, it behaves predictably.

One pattern worth stealing: notice the `> Last verified: 2026-03-04` line in section 4. Claude Code features evolve quickly. When you state facts about tool features (loading order, settings keys, hook events), date them and link docs. That gives you a clear freshness signal and makes stale guidance obvious.

<details>
<summary>Full CLAUDE.md content</summary>

```markdown
# GLOBAL PROTOCOL (v2026.2)

## 0. SHORTCUTS & TRIGGERS
- **Bootstrap Trigger**: If the current directory lacks a `CLAUDE.md`, immediately perform **DYNAMIC PROJECT INITIALIZATION**.
- **"Trace"** or **"/trace"**: Perform a deep-trace audit per the debugging rules in `~/.claude/rules/debugging.md`.

## 1. MANDATORY WORKFLOW
- **Plan First**: For any change > 2 files, output a `<plan>` and wait for approval.
- **Test First**: If the project has tests, write or update a failing test BEFORE implementing. Run the test to confirm it fails, then implement, then run again to confirm it passes.
- **Context Pruning**: Read ONLY files strictly necessary for the current task.
- **No Yapping**: Skip introductions/conclusions. Output code or direct answers only.
- **Verify**: After implementing, run the project's build/test/lint command. If it fails, diagnose and fix before moving on. Never mark work as done without verifying it runs.
- **Scope Lock**: Do NOT modify files or add features beyond what the user asked for. No unrequested refactors, no bonus improvements, no "while I'm here" changes.
- **On Compaction**: Always preserve in the summary: all modified file paths, the current task and acceptance criteria, test commands and results, key decisions and reasoning.
- **CLAUDE.md is the Source of Truth**: Before making changes, read the project's `CLAUDE.md`. If your changes diverge from what it specifies, ask the user: "This differs from the project CLAUDE.md — should I update it first?" Update CLAUDE.md **early** — when you discover a new convention, make an architecture decision, or establish a pattern, propose the update immediately. Do not wait until the end of the task. Sessions can crash, compact, or be interrupted — anything not written to CLAUDE.md is lost.
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
> Last verified: 2026-03-04. Official docs: https://code.claude.com/docs/en/memory

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

*Last synced with CLAUDE.md: 2026-03-04*

</details>

### CLAUDE.local.md

There's a second file worth knowing: `CLAUDE.local.md`. It lives alongside `CLAUDE.md` but is gitignored. Use it for personal notes that shouldn't be committed — your API keys, reminders about a local dev setup, project context that's specific to your machine. It loads at the same scope as `CLAUDE.md` but stays out of version control.

### @import syntax

CLAUDE.md supports `@path/to/file` imports. Instead of one giant file, you can split instructions across focused files and import them. That's what the `rules/` directory in this repo is for — each rule file covers one concern (security, testing, debugging, etc.), and they're loaded via `@import` references in CLAUDE.md.

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
| 4 | User (global) | `~/.claude/CLAUDE.md` | Your baseline — this repo |

More specific locations take precedence over broader ones. If your project's `CLAUDE.md` says "use 2-space indentation" but your global says "use tabs", the project wins.

One exception: array settings like `permissions.allow` **merge** across scopes rather than override. Add an allow rule at project level and it stacks on top of your global allows.

A few other loading behaviors worth knowing:

- CLAUDE.md files in **parent directories** above your working directory are also loaded (walking up the tree)
- **Subdirectory** CLAUDE.md files load on demand when Claude reads files in those directories
- The `claudeMdExcludes` setting in `settings.json` lets you skip specific CLAUDE.md files — useful in monorepos where you want to suppress a package's CLAUDE.md

**This repo demonstrates the user-global scope** (`~/.claude/`). Individual projects can also have `./CLAUDE.md` or `./.claude/CLAUDE.md` files that layer on top. The global rules here form the baseline; project files add or override for specific codebases.

---

## Rules

Without rules, you repeat the same instructions every conversation. "Use tabs." "No console.log." "Always parameterize SQL." "Don't add unrequested features." Every. Single. Session.

Rules fix that. Files in `~/.claude/rules/` load automatically at the start of every session — Claude reads them before doing anything else. Each file covers one concern. When a file gets too long, split it. Single responsibility applies to rules files the same way it applies to code.

The rules in this repo import automatically because the [CLAUDE.md](#claudemd) `@import` syntax pulls them in. But the `~/.claude/rules/` directory also has a special property: files there load unconditionally without any explicit `@import` (unless you have `paths:` frontmatter — more on that below).

### Always-loaded rules

These 8 files load every session, regardless of what project you're working on:

| File | What problem it solves |
|------|----------------------|
| `architecture.md` | Prevents God Files — enforces the 200-line rule, atomic responsibility, and directory mapping |
| `debugging.md` | Stops guessing — requires tracing data flow before proposing any fix |
| `dependencies.md` | Blocks hallucinated packages and unvetted dependencies from entering the codebase |
| `discipline.md` | Prevents scope creep, bonus refactors, TODO placeholders, and over-engineered abstractions |
| `security.md` | Enforces parameterized queries, input validation, and XSS prevention on every coding task |
| `style.md` | Enforces tabs, clean code, no truncated snippets — no "// ... rest of code" shortcuts |
| `testing.md` | Enforces test-first workflow with failing tests before implementation, AAA pattern |
| `verification.md` | Requires running build/test after every change — never assume success from a clean write |

Here's a taste of what a rule file looks like — this is the SQL injection section from `security.md`:

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

Some rules only matter for certain file types. Loading PHP rules when you're writing JavaScript wastes context — those tokens could be used for something relevant.

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

The three conditional rules in this repo and what triggers each:

| File | Triggers on |
|------|------------|
| `environment.md` | `.env`, Docker, deployment config, `package.json`, `tsconfig`, `wrangler` |
| `php-wordpress.md` | `.php` files, `wp-config.php`, `composer.json`, `phpunit.xml` |
| `ui-ux.md` | Component files, CSS, layout files |

Key insight from testing: conditional rules trigger on **file-read, not tool-use**. Claude reads a `.php` file → PHP rules load. Claude hasn't read any `.php` files in the session → PHP rules stay unloaded. If you're debugging why a conditional rule isn't firing, check whether Claude has actually read a matching file yet.

See [Hooks](#hooks) for lifecycle automation that complements these persistent instructions.

---

## Hooks

Rules tell Claude what to do. But Claude doesn't verify its own work automatically. It won't check code quality before writing a file, or warn you before stopping with unfinished tasks. Hooks solve that.

Hooks are shell scripts that run at key moments in Claude's lifecycle. Registered in [settings.json](#hook-registration), they intercept tool calls, prompt submissions, and session events. The hook decides what happens: let it through, block it, or add context.

The lifecycle events this setup uses (7 of 18 available):

| Event | When it fires |
|-------|--------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Before Claude processes your prompt |
| `PreToolUse` | Before any tool call — **can block** |
| `PostToolUse` | After a tool call succeeds |
| `PreCompact` | Before context compaction |
| `Stop` | When Claude finishes responding (exit 2 continues the conversation) |
| `SessionEnd` | Session terminates |

For the full list of 18 events, see the [official Claude Code docs](https://code.claude.com/docs/en/hooks).

### Exit code contract

This is the most important thing to get right:

| Exit code | Meaning |
|-----------|---------|
| `0` | Success — stdout is parsed for JSON output (e.g., `additionalContext`, `systemMessage`) |
| `2` | **Block** — stderr is fed back to Claude. Effect depends on event (PreToolUse blocks the call, Stop continues the conversation) |
| anything else | Non-blocking error — execution continues |

**The pitfall everyone hits: `exit 1` does NOT block.** If you want to stop Claude from writing a file, you must use `exit 2`. Exit 1 just logs a non-blocking error and lets the tool call proceed. Use exit 2 to block.

stdin/stdout: hooks receive a JSON object on stdin. Parse it with `jq`. Key fields are `tool_input.file_path` (the file being written) and `tool_input.command` (for Bash hooks). For command hooks, stderr with `exit 2` becomes the blocking error message for events that support blocking. stdout handling depends on event type and output shape (plain text vs JSON fields like `additionalContext` / `systemMessage`).

### Hook walkthrough: check-code-quality.sh

The hook-as-quality-gate pattern. This is a `PreToolUse` hook that fires before every `Write` or `Edit` tool call. If it finds style violations, it exits 2 and blocks the write — Claude sees the error message and fixes the violation before trying again.

Here's the core of how it works:

```bash
# Read stdin JSON, extract file path and tool name
FILE_PATH=$(jq -r '.tool_input.file_path // empty' < "$TMPINPUT")
TOOL=$(jq -r '.tool_name' < "$TMPINPUT")

# Get the content being written
if [ "$TOOL" = "Write" ]; then
	jq -r '.tool_input.content // empty' < "$TMPINPUT" > "$TMPCODE"
elif [ "$TOOL" = "Edit" ]; then
	jq -r '.tool_input.new_string // empty' < "$TMPINPUT" > "$TMPCODE"
fi

# Check for violations
if grep -q 'console\.log(' "$TMPCODE"; then
	ERRORS="${ERRORS}console.log() found — remove or use console.error. "
fi

# Block if violations found
if [ -n "$ERRORS" ]; then
	echo "$ERRORS" >&2
	exit 2  # Block the write, feed error back to Claude
fi
```

Rules are instructions. Hooks are enforcement. The rules say "no console.log" — the hook makes it impossible to accidentally ship one.

<details>
<summary>Full check-code-quality.sh script</summary>

```bash
#!/bin/bash
# Deterministic code quality gate for Write/Edit tool calls.
# Replaces the Stop prompt hook — no LLM, no JSON validation errors.

TMPINPUT=$(mktemp)
TMPCODE=$(mktemp)
trap 'rm -f "$TMPINPUT" "$TMPCODE"' EXIT

cat > "$TMPINPUT"

FILE_PATH=$(jq -r '.tool_input.file_path // empty' < "$TMPINPUT")

# Only check code files
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx|*.py|*.css|*.html|*.sql|*.go|*.rs|*.php) ;;
	*) exit 0 ;;
esac

TOOL=$(jq -r '.tool_name' < "$TMPINPUT")

if [ "$TOOL" = "Write" ]; then
	jq -r '.tool_input.content // empty' < "$TMPINPUT" > "$TMPCODE"
elif [ "$TOOL" = "Edit" ]; then
	jq -r '.tool_input.new_string // empty' < "$TMPINPUT" > "$TMPCODE"
else
	exit 0
fi

[ ! -s "$TMPCODE" ] && exit 0

ERRORS=""

# Tabs not spaces — only for Write (full file).
# Edit skipped because replacement may need to match existing indentation.
if [ "$TOOL" = "Write" ]; then
	if grep -Eq '^ ' "$TMPCODE"; then
		ERRORS="${ERRORS}Space indentation detected — use tabs. "
	fi
fi

# No console.log in JS/TS
case "$FILE_PATH" in
	*.js|*.mjs|*.ts|*.tsx|*.jsx)
		if grep -q 'console\.log(' "$TMPCODE"; then
			ERRORS="${ERRORS}console.log() found — remove or use console.error. "
		fi
		;;
esac

# No placeholder comments
if grep -Eq '//\s*\.\.\.\s*$' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// ...' found — write real code. "
fi
if grep -Eiq '//\s*rest of' "$TMPCODE"; then
	ERRORS="${ERRORS}Placeholder comment '// rest of...' found — write real code. "
fi

if [ -n "$ERRORS" ]; then
	echo "$ERRORS" >&2
	exit 2
fi

exit 0
```

</details>

**Note on matcher syntax:** Hook registration in `settings.json` uses regex matchers. A pipe (`|`) is standard regex OR, so `"Write|Edit"` matches both Write and Edit tool calls. This is documented behavior in the hooks reference matcher section.

---

## Agents

Rules apply to every conversation. But some tasks need a different personality entirely — a code reviewer that only reads and never writes, a security auditor that can use a cheaper model, a WordPress specialist that only loads PHP-related tools. Rules can't do that. Agents can.

Agents are markdown files with YAML frontmatter that define specialist subagents. Claude can delegate tasks to them when the work matches. The agent runs with its own instructions, its own tool restrictions, and optionally its own model. It reports back when done.

### Frontmatter fields

| Field | What it does |
|-------|-------------|
| `name` | Lowercase-with-hyphens identifier. How you reference the agent. (Required) |
| `description` | Tells Claude when to delegate to this agent. Quality matters — a vague description means missed delegations. (Required) |
| `tools` | Comma-separated list of allowed tools. Omit to inherit all tools. |
| `disallowedTools` | Tools to deny — removed from inherited or specified list. |
| `model` | `sonnet`, `opus`, `haiku`, or `inherit`. Default: inherit. |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`. Controls permission prompts. |
| `maxTurns` | Limits agentic turns. Prevents runaway agents from looping. |
| `skills` | Skills to load into the subagent's context at startup. |
| `mcpServers` | MCP servers available to this subagent. |
| `hooks` | Lifecycle hooks scoped to this subagent. |
| `memory` | Persistent memory scope: `user`, `project`, or `local`. |
| `background` | Set to `true` to always run as a background task. Default: `false`. |
| `isolation` | Set to `worktree` to run in a temporary git worktree. |

### Example: code-reviewer.md

The clearest example of why you'd want an agent instead of a rule. The code reviewer needs to:

1. Be read-only — it should never write or edit files, only report
2. Run on `sonnet` (lighter model) since reviewing doesn't need the most capable model
3. Have a 25-turn limit to prevent infinite review loops

Here's its frontmatter:

```yaml
---
name: code-reviewer
description: General-purpose code reviewer. Examines code for logical errors, race conditions, edge cases, type mismatches, and CLAUDE.md compliance. Read-only — never modifies code. Works on specific files by default; supports git diff review when explicitly requested.
tools: Read, Grep, Glob, Bash
model: sonnet
maxTurns: 25
---
```

Four tools only: `Read`, `Grep`, `Glob`, `Bash`. No `Write`, no `Edit`. The model declaration (`sonnet`) makes every code review cheaper than if it ran on `opus`. The `maxTurns: 25` means it can do a thorough review without risking an infinite loop.

A rule can say "never modify code when reviewing." An agent makes it structurally impossible.

### Where agent files live

This repo's `agents/` directory maps to `~/.claude/agents/`. These are **user-global agents** — available across every project.

For **project-specific agents**, put them in `.claude/agents/` at the project root. Project agents are available only in that project. If you have a database migration specialist that only makes sense for one codebase, put it there rather than polluting your global agent list.

### Rules vs agents: when to use which

| Use a rule when... | Use an agent when... |
|-------------------|---------------------|
| It's a constraint that always applies | It's a task you'd delegate to a specialist |
| "Always use tabs" | "Review this code for bugs" |
| "Never skip tests" | "Audit this for security issues" |
| "No console.log" | "Rewrite this as a WordPress plugin" |

Rule of thumb: if it's a style preference or a guardrail → rule. If it's a distinct task with a different set of capabilities → agent.

### New in recent releases

A few agent-related features worth knowing about:

**Permission modes** — Agents can specify a `permissionMode` to control how tool permissions are handled. `plan` mode lets the agent analyze without modifying files. `dontAsk` auto-denies tools unless pre-approved. `bypassPermissions` skips all prompts (for safe environments). The same five modes (`default`, `acceptEdits`, `plan`, `dontAsk`, `bypassPermissions`) are also available as a global `defaultMode` setting.

**Agent teams** (experimental) — Multiple Claude Code instances coordinating on work. A team lead delegates, teammates work independently with shared task lists and direct messaging. Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` or settings. Higher token usage than single sessions. See the [agent teams docs](https://code.claude.com/docs/en/agent-teams).

**PostToolUseFailure** — A hook event that fires after a tool call fails (companion to `PostToolUse` which fires on success). Cannot block since the failure already happened. Useful for logging or alerting on tool failures.

**Plugin hooks** — Plugins can bundle their own hooks via a `hooks/hooks.json` file. When a plugin is enabled, its hooks merge with user and project hooks. This is a plugin-specific mechanism, not a standalone alternative to `settings.json` for regular hook configuration.

---

## Settings

The `settings.json` in this repo is a template. **Copy it to `~/.claude/settings.json`** — that's where Claude Code looks for it. A `settings.json` at the repo root is not a recognized Claude Code path and will be silently ignored.

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

Why the deny rules? The `.env` deny prevents Claude from reading secrets that don't need to be in context. The `node_modules` deny prevents it from indexing thousands of dependency files when it does a broad search. Same logic for `dist/`, `build/`, lock files — noise that adds tokens without value.

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
```

The `matcher` field filters by tool name — only fires the hook when the matched tool is called. Omit `matcher` to fire on every tool call for that event. See [Hooks](#hooks) for the exit code contract and what these hooks do.

Settings also control `claudeMdExcludes` (skip specific CLAUDE.md files) and settings precedence: Managed policy > CLI args > Local > Project > User. Array settings like `permissions.allow` merge across scopes rather than override — project-level allow rules stack on top of global ones.

<details>
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
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/check-code-quality.sh" }]
      }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/verify-before-stop.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/check-unfinished-tasks.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/drift-review-stop.sh" }] }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/track-modified-files.sh" }]
      },
      {
        "matcher": "TaskCreate|TaskUpdate",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/track-tasks.sh" }]
      }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/remind-project-claude.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/check-unfinished-tasks.sh" }] }
    ],
    "PreCompact": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/pre-compaction-preserve.sh" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/session-cleanup.sh" }] }
    ]
  },
  "enabledPlugins": {
    "frontend-design@claude-code-plugins": true,
    "claude-hud@claude-hud": true,
    "swift-lsp@claude-plugins-official": true
  }
}
```

</details>

> **Note:** The `enabledPlugins` block lists plugins specific to this setup. Remove or replace these entries with your own plugins — they are personal preferences, not required for the configuration to work. Your `enabledPlugins` section will look different — list whatever plugins you actually use, or remove this block entirely.

---

## Skills

Skills are reusable task templates with step-by-step instructions. They differ from agents: agents are delegatable specialists (a different "person" doing the work), skills are more like checklists — structured guidance for a task that the main Claude session follows directly.

This repo includes two skills:

- `debug-wp` — WordPress debugging workflow: isolate, trace, reproduce, fix
- `qa-check` — Quality assurance checklist for before-you-ship reviews

Directory structure:

```
skills/
  debug-wp/
    SKILL.md    ← the step-by-step instructions
  qa-check/
    SKILL.md
```

Skills live at `~/.claude/skills/` globally, or `.claude/skills/` for project-specific ones.

### Skill frontmatter

Skills support 10 frontmatter fields:

| Field | What it does |
|-------|-------------|
| `name` | Display name (defaults to directory name). Lowercase, numbers, hyphens, max 64 chars. |
| `description` | What the skill does and when to use it. |
| `argument-hint` | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | Set to `true` to prevent Claude from auto-loading this skill. |
| `user-invocable` | Set to `false` to hide from the `/` menu. |
| `allowed-tools` | Tools Claude can use without permission when skill is active. |
| `model` | Model to use when skill is active. |
| `context` | Set to `fork` to run in a forked subagent context. |
| `agent` | Which subagent to use when `context: fork` is set. |
| `hooks` | Hooks scoped to this skill's lifecycle. |

### Forked context

Set `context: fork` to run the skill in a separate subagent. The skill content becomes the prompt. Use `agent` to specify which subagent type handles it — built-in agents (`Explore`, `Plan`, `general-purpose`) or custom subagents from your `agents/` directory.

### String substitutions

Skills support variable substitution: `$ARGUMENTS` (full argument string), `$ARGUMENTS[N]` or `$N` (Nth argument), `${CLAUDE_SESSION_ID}`, and `${CLAUDE_SKILL_DIR}`.

### Dynamic context

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude. Use it to inject dynamic context — git status, current branch, file listings — into the skill prompt.

### Bundled skills

Claude Code ships with several built-in skills: `/simplify` (code quality review), `/batch` (parallel large-scale changes), `/debug` (troubleshoot via debug log), `/loop` (repeated prompt execution), and `/claude-api` (API reference).

---

## GSD

GSD is a workflow framework I use on top of Claude Code. It's not required for any of this to work. Everything in this repo — the rules, hooks, agents, settings — functions without it.

What GSD adds: structured planning (breaking work into phases and plans), phased execution with per-task commits, and verification gates between phases. If you see references to `.planning/` directories or `/gsd:` commands in the CLAUDE.md, that's GSD. You can safely ignore or remove those sections if you don't use it.

More at: [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)

---

## Next Steps

The fastest path: clone, copy, restart.

```bash
git clone https://github.com/shieldsstuart/project-claude-setup
cp -r project-claude-setup/. ~/.claude/
```

Then adapt it. The rules are opinionated — they reflect how I work. Read through each one in `rules/` and remove or modify anything that doesn't fit your style. If you don't work with WordPress, delete `php-wordpress.md`. If you prefer a different SQL library, update the parameterized query examples in `security.md`.

The official docs go deeper on everything here:
- Claude Code docs: [code.claude.com/docs](https://code.claude.com/docs)
- Hooks reference: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

And if you want structured workflow on top: [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)
