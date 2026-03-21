---
title: Component Reference
---
<!-- Last updated: 2026-03-21 -->

# Component Reference

> **TL;DR:** This setup has 6+6 rules, 22 hooks, 17 agents, and 9 skills. This page explains what each one does, why it exists, and how it compares to what the community builds. Use it to decide which parts to adopt and which to skip.

The individual READMEs ([rules](../rules/README.md), [hooks](../hooks/README.md), [agents](../agents/README.md), [skills](../skills/README.md)) explain how each system works. This page is the quick-scan reference for what each component does and why it's here.

---

## Token Budget: Every Byte Counts

Everything in this setup is built with token cost in mind. Claude Code has a finite context window and every rule, hook output, and MCP tool description eats into it. If your always-on instructions are too verbose, Claude starts ignoring the ones at the bottom. If your MCP servers register 200 tools, tool search alone burns tokens every turn.

How this setup stays lean:

**Rules** are split into always-on (6 files, ~85 bullets) and conditional (6 files, path-triggered). The conditional rules only load when you're working with matching file types - `php-wordpress.md` doesn't burn context when you're writing JavaScript. The always-on budget stays under ~100 bullets to avoid the point where Claude starts quietly dropping instructions.

**Hooks** are shell scripts, not LLM calls. A hook that checks for console.log costs zero tokens - it runs in bash, returns an exit code, and only injects text into context when it has something to say. The `additionalContext` output is one line. Compare this to a prompt-type hook that asks an LLM to review every write - that costs hundreds of tokens per tool call.

**Skills** load on demand. They're not in context until you invoke `/brainstorm` or `/multi-review`. Specialised rules that were previously always-loaded (figma, playwright) were converted to skills in v3.0, saving ~8KB that loaded on every frontend file touch.

**MCP servers** register tools that appear in Claude's tool search. Four MCP servers (context7, figma, playwright, tailwindcss) add ~100 tools to the search space. When you don't need them, they're overhead. This setup includes shell shortcuts for lean and full launch modes:

- `c` - lean mode. Loads only context7 (lightweight docs lookup). Uses `--strict-mcp-config` to ignore all other configured MCP servers. Figma plugin disabled.
- `cf` - full mode. All MCP servers and plugins active. Use when you're doing design-to-code, browser testing, or Tailwind work.
- Both support session resume: `c <session-id>` or `cf <session-id>`.

Shell shortcuts are in [`scripts/`](../scripts/) - Fish ([`claude-shortcuts.fish`](../scripts/claude-shortcuts.fish)) and Bash/Zsh ([`claude-shortcuts.bash`](../scripts/claude-shortcuts.bash)). Source whichever matches your shell.

The rule of thumb: if you haven't used a tool in the last 10 minutes, it shouldn't be loaded. MCP servers that sit idle still cost tool-search tokens on every turn.

---

## The Problem This Setup Solves

Claude is capable out of the box, but it has consistent failure modes that waste your time:

- **It skips the hard parts.** When implementation gets complex, Claude pivots to a "simpler approach" that avoids the real problem. You end up with workarounds instead of fixes.
- **It guesses instead of checking.** Claude writes imports for packages that don't exist, references APIs with the wrong signature, and declares things work without running them.
- **It drifts.** Long sessions accumulate context noise. Claude starts making bonus changes you didn't ask for, loses track of what it was doing, or repeats the same broken approach.
- **It forgets between sessions.** Corrections you made last Tuesday are gone by Wednesday. Conventions you established in one session don't carry to the next.
- **It doesn't verify its own work.** Claude will say "all done" without running tests, claim code works without checking, and move on while leaving broken state behind.

This setup addresses each failure mode with a different layer:

**Rules** set expectations. They tell Claude what to do (use tabs, validate dependencies, follow the 4-step debugging framework) and what not to do (no bonus refactors, no pivoting to avoid hard work, no success claims without evidence).

**Hooks** enforce rules mechanically. Claude can't talk its way past a hook. If it tries to write code with space indentation, the write is blocked before the file changes. If it tries to stop with unfinished tasks, the Stop hook sends it back. Rules are guidance - hooks are enforcement.

**Agents** delegate specialised work. A code review from the main session is surface-level. A code review from a dedicated agent with restricted tools, a specific model, and read-only enforcement catches more. Agents also enable parallel work - three review agents running simultaneously, each focused on a different angle.

**Skills** structure repeatable workflows. Instead of re-explaining "interview me before planning, propose approaches, write a brief" every time, the brainstorm skill captures that workflow once. Invoke it, follow the steps, get consistent results.

**Memory and review hooks** close the loop across sessions. Auto-memory captures corrections as they happen. The memory-review hook prompts you to audit and promote learnings at natural breakpoints - phase completion, session start, low context. Permanent patterns move to CLAUDE.md or rules where they're explicit and version-controlled.

Each layer solves a different problem. Removing one doesn't break the others, but they work best together.

---

## What Makes This Setup Different

Most Claude Code setups focus on one or two layers - typically a CLAUDE.md with rules and maybe a few hooks for formatting. This setup goes deeper in five areas.

### Mechanical enforcement over prompt discipline

Prompt instructions control Claude's behaviour most of the time. But under pressure - complex tasks, long sessions, approaching context limits - Claude starts cutting corners. Hooks don't degrade under pressure. They fire every time regardless of context.

The agent guard hooks show the difference clearly. Telling an agent "you are read-only, do not modify files" in its system prompt works most of the time. A PreToolUse hook that exits 2 on Write/Edit calls works every time. The prompt sets intent, the hook guarantees it.

This setup has 22 hooks across 10 lifecycle events. Most community setups have 3-6 and use them for formatting and commit blocking. The agent guards, stop gates, task tracking, drift detection, and observability hooks here go further than what I've found elsewhere.

### Memory as a managed lifecycle

Most approaches to session-to-session learning fall into two camps: manual reflection skills you invoke at session end (Superpowers, blog-post-style `/reflect`), or automatic capture that injects everything into the next session (`claude-mem`). Manual reflection depends on remembering to do it. Automatic injection accumulates noise.

This setup treats memory as a lifecycle with three stages:

1. **Capture** - auto-memory records corrections and patterns as they happen during work
2. **Prompt** - the `memory-review-prompt.sh` hook fires at natural breakpoints: GSD phase completion, session start when 3+ new topic files have accumulated, or when context drops to 30% remaining (reading the context bridge file written by the statusline hook - the same mechanism the GSD context monitor uses at its 35%/25% thresholds)
3. **Review** - the `/review-memory` skill loads all topic files, categorises each as Promote (move to CLAUDE.md/rules/skills), Keep, or Remove, checks for duplicates before promoting, and updates the review timestamp

Permanent learnings get promoted to CLAUDE.md or rules where they're explicit and version-controlled. The memory directory stays lean. The 200-line auto-loaded limit on MEMORY.md means noise has a real cost - every stale entry pushes out something useful.

### WordPress depth

4 agents ([`wp`](../agents/wp.md), [`wp-reviewer`](../agents/wp-reviewer.md), [`wp-security`](../agents/wp-security.md), [`wp-perf`](../agents/wp-perf.md)) and 1 skill ([`debug-wp`](../skills/debug-wp/SKILL.md)) cover architecture, code review, security, performance, and debugging for WordPress projects. The agents know WordPress idioms - `wp_enqueue_script` instead of raw script tags, `$wpdb->prepare()` for queries, nonce verification on forms - so reviews catch WP-specific issues that a generic code reviewer misses. I haven't found equivalent WordPress-specialist tooling in other Claude Code setups.

### Always-on safety nets

Some protections only work if you remember to invoke them. This setup has several that run every session automatically:

- **Staleness detection** flags rule files older than 30 days. AI best practices evolve fast - a rule referencing deprecated features teaches Claude the wrong patterns.
- **Dependency hallucination prevention** forces Claude to verify package names and URLs exist before referencing them. I haven't seen this pattern in other community setups.
- **Discipline rules** (anti-pivot, scope control, Design Discussion Checkpoint) prevent Claude's most common failure modes without needing a specific skill or agent invocation.

### GSD, plugins, and MCP servers

This setup uses [GSD (Get Shit Done)](https://github.com/gsd-build/get-shit-done) for structured project execution. GSD provides multi-phase milestone tracking, goal-backward verification (checking the outcome was achieved, not just that tasks completed), persistent state across context resets, and cross-phase integration checks. I chose it over [Superpowers](https://github.com/obra/superpowers) because Superpowers handles the build cycle well (brainstorm to PR) but doesn't address what happens when work spans multiple sessions - state loss, requirement drift, and verifying that phases connect. GSD covers both.

GSD agents (planner, executor, verifier, etc.) respect the existing setup - they read CLAUDE.md, discover project skills, and inherit global hooks. They don't use the custom agents (code-reviewer, security, perf) but both sets coexist.

**Plugins** enabled in `settings.json`:
- `frontend-design` - production-grade frontend component generation
- `figma` - Figma MCP integration for design-to-code workflows
- `claude-hud` - statusline dashboard showing model, task, directory, and context usage
- `swift-lsp` and `rust-analyzer-lsp` - language server support for Swift and Rust projects

**MCP servers** configured in `.claude.json`:
- `context7` - up-to-date library documentation and code examples. Used for verifying Claude Code features, skill frontmatter, and hook patterns against current docs rather than training data.
- `figma` - design context extraction, screenshots, variables, and Code Connect mappings. The [`figma`](../skills/figma/SKILL.md) skill wraps this with a structured workflow.
- `playwright` - browser automation for testing, visual verification, and UX review. Used by [`playwright`](../skills/playwright/SKILL.md), [`vibe-user`](../skills/vibe-user/SKILL.md), and [`test-plan`](../skills/test-plan/SKILL.md) skills.
- `tailwindcss` - Tailwind CSS utilities, colour palettes, and configuration guidance.

---

## Rules

Rules are markdown files that load into Claude's context and shape how it behaves. Six load on every session (always-on), six load conditionally based on file paths.

### Always-on rules

These load every session regardless of project. They define the baseline behaviour you want from Claude across all work.

| Rule | What it does | Why it exists | Community comparison |
|------|-------------|---------------|---------------------|
| [`debugging.md`](../rules/debugging.md) | 4-step framework: Reproduce, Isolate, Fix, Validate. Anti-loop protocol (stop after 2 failed attempts). | Without this, Claude jumps straight to fixing without confirming the root cause. The anti-loop protocol prevents it from trying the same broken approach repeatedly. | Superpowers has a `systematic-debugging` skill with similar 4-phase approach. Ours is always-loaded so it applies even without invoking a skill. |
| [`discipline.md`](../rules/discipline.md) | Scope control, anti-pivot rules, complete implementations, regression awareness, Design Discussion Checkpoint. | The strongest rule file. Prevents Claude from pivoting to easier approaches, skipping hard parts, making bonus changes, or jumping to implementation during design discussions. | I haven't found an equivalentcovers this breadth. ECC has a `coding-style` rule that partially overlaps. The anti-pivot and Design Discussion Checkpoint patterns are unique to this setup. |
| [`style.md`](../rules/style.md) | Tabs only, Edit tool tab handling, no console.log, clean code. | Claude defaults to spaces and leaves debug statements. The Edit tool tab handling section prevents a known Claude Code bug where Edit fails on indented lines. | ECC has language-specific style rules (TypeScript, Python, Go). Ours is language-agnostic and focused on the tab/Edit tool interaction that trips up most setups. |
| [`dependencies.md`](../rules/dependencies.md) | Verify packages/URLs exist before referencing. Ask before adding dependencies. | Claude hallucates package names. This rule forces verification via WebSearch or `npm search` before writing an import. | I haven't found an equivalent in other setups. ECC covers dependency security in their `security` rule but not hallucination prevention. |
| [`security.md`](../rules/security.md) | Input validation, parameterised queries, output escaping, secrets in env vars. | Baseline security patterns for every session. Lightweight - use the `security` agent for deep audits. | Trail of Bits has 35 security plugins - the community gold standard. Our rule is lighter but always-on, which means it applies even when you don't think to invoke a security review. |
| [`staleness.md`](../rules/staleness.md) | Tracks `<!-- Last updated -->` dates across all guidance files. Flags files older than 30 days. | AI best practices evolve fast. Rules written 3 months ago may reference deprecated features or outdated patterns. This catches drift automatically. | I haven't found an equivalent in other setups. |

### Conditional rules

These load only when you're working with matching file types. They add domain-specific guidance without burning context budget on every session.

| Rule | Loads when | What it does | Community comparison |
|------|-----------|-------------|---------------------|
| [`architecture.md`](../rules/architecture.md) | Code files (`*.js`, `*.ts`, `*.py`, etc.) | 200-line rule, directory mapping, monorepo guidance. | ECC has `patterns` rule + `architect` agent. |
| [`testing.md`](../rules/testing.md) | Code files | One behaviour per test, mock skepticism, test core user-facing behaviour first. | ECC has dedicated testing rules per language. Superpowers has `test-driven-development` skill. |
| [`ui-ux.md`](../rules/ui-ux.md) | Frontend files | Responsive design, WCAG accessibility, semantic HTML over ARIA. | Vercel has `web-design-guidelines` (185K installs). |
| [`php-wordpress.md`](../rules/php-wordpress.md) | PHP/WordPress files | Theme/plugin structure, hooks, custom post types, WP security. | I haven't found an equivalentat this depth. |
| [`environment.md`](../rules/environment.md) | Config files | Dev/production config patterns. | Trail of Bits has `devcontainer-setup`. |
| [`harness-maintenance.md`](../rules/harness-maintenance.md) | `~/.claude/` files | Rules for editing the harness itself: research first, instruction budget, conflict checking. | ECC has a `harness-optimizer` agent (similar concept, different approach). |

---

## Hooks

Hooks are shell scripts that intercept Claude's actions at specific lifecycle points. They enforce rules mechanically - Claude can't talk its way past a hook that exits 2.

### Quality gates

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`check-code-quality.sh`](../hooks/check-code-quality.sh) | PreToolUse (Write/Edit) | Blocks space indentation, console.log, debugger, placeholder comments, TODO stubs. | ECC has configurable hook profiles (minimal/standard/strict). Most community setups use Prettier/Biome as post-write formatters. Ours blocks before writing - bad code never hits the filesystem. |
| [`project-quality-gates.sh`](../hooks/project-quality-gates.sh) | PostToolUse (Write/Edit) | Detects available lint/typecheck/test commands from package.json. Advisory only - reminds Claude to run them, doesn't run them itself. | `claude-code-skills` has a `story-quality-gate` with 4-level verdicts. Ours is passive detection rather than active execution. |

### Stop and verification gates

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`stop-dispatcher.sh`](../hooks/stop-dispatcher.sh) | Stop | Single entry point for all Stop checks. Runs sub-hooks sequentially, aggregates blocking reasons, returns one decision. | I haven't found an equivalent in other setups. |
| [`check-unfinished-tasks.sh`](../hooks/check-unfinished-tasks.sh) | Stop + UserPromptSubmit | Warns/blocks on incomplete task state. | I haven't found an equivalent in other setups. |
| [`drift-review-stop.sh`](../hooks/drift-review-stop.sh) | Stop (via dispatcher) | Catches cognitive-drift response patterns. | I haven't found an equivalent in other setups. |
| [`stop-quality-check.sh`](../hooks/stop-quality-check.sh) | Stop (via dispatcher) | Blocks on deferred follow-ups, rationalised pre-existing issues, unverified success claims, "too many issues" excuses. | Superpowers has `verification-before-completion` as a skill. Ours is a hook - it fires automatically, you don't need to invoke it. |
| [`verify-before-stop.sh`](../hooks/verify-before-stop.sh) | UserPromptSubmit | Rate-limited advisory reminding Claude to run build/test/lint before finishing. | I haven't found an equivalent in other setups. |
| [`remind-project-claude.sh`](../hooks/remind-project-claude.sh) | UserPromptSubmit | Emits actionable CLAUDE.md reminders when conditions are met. | I haven't found an equivalent in other setups. |

### Performance and loop detection

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`detect-perf-degradation.sh`](../hooks/detect-perf-degradation.sh) | PostToolUse + PostToolUseFailure | Detects reasoning loops (same tool 3x in 10 calls) and error spikes (5+ failures in 10 calls). | I haven't found an equivalentas a hook. Performance is typically handled by agents/skills, not hooks. |
| [`block-git-commit.sh`](../hooks/block-git-commit.sh) | PreToolUse (Bash) | Blocks `git commit` and destructive Bash patterns. | Common community pattern. Trail of Bits has safety hooks blocking dangerous commands. |

### Memory and session lifecycle

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`memory-review-prompt.sh`](../hooks/memory-review-prompt.sh) | UserPromptSubmit + SessionStart + PostToolUse | Three-trigger memory review: GSD phase completion, 3+ new memory files on session start, context at 30% remaining. | ECC has session auto-load/save hooks. `claude-mem` does automatic capture and injection. Our approach is prompted review - it tells you when to review, not what to remember. |
| [`pre-compaction-preserve.sh`](../hooks/pre-compaction-preserve.sh) | PreCompact | Saves session state before context compaction. | ECC has `pre-compact.js`. |
| [`compact-restore.sh`](../hooks/compact-restore.sh) | SessionStart (compact) | Restores pre-compaction saved state. | I haven't found an equivalent in other setups. |
| [`session-cleanup.sh`](../hooks/session-cleanup.sh) | SessionEnd | Removes session temp artifacts and rotates hooks.log. | ECC has `session-end.js`. |

### Tracking and observability

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`track-modified-files.sh`](../hooks/track-modified-files.sh) | PostToolUse (Write/Edit) | Logs files modified this session. | I haven't found an equivalent in other setups. |
| [`track-tasks.sh`](../hooks/track-tasks.sh) | PostToolUse (TaskCreate/TaskUpdate) | Tracks task lifecycle state. | I haven't found an equivalent in other setups. |
| [`hook-observability-summary.sh`](../hooks/hook-observability-summary.sh) | PostToolUse + PostToolUseFailure | Tracks hook outcomes and rebuilds aggregate summary every 10th event. | I haven't found an equivalent in other setups. |

### Agent guards

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`agent-guard-readonly.sh`](../hooks/agent-guard-readonly.sh) | Agent PreToolUse (Bash) | Blocks destructive Bash in read-only agents. | No direct equivalent. ECC uses hook profiles for strictness. |
| [`agent-guard-write-block.sh`](../hooks/agent-guard-write-block.sh) | Agent PreToolUse (Write/Edit) | Blocks Write/Edit entirely in read-only agents. | I haven't found an equivalent in other setups. |
| [`agent-guard-max-lines.sh`](../hooks/agent-guard-max-lines.sh) | Agent PreToolUse (Write/Edit) | Blocks edits over 50 lines in quick-edit agent. | I haven't found an equivalent in other setups. |

### Notifications

| Hook | When it fires | What it does | Community comparison |
|------|--------------|-------------|---------------------|
| [`permission-notify.sh`](../hooks/permission-notify.sh) | PermissionRequest | Plays system sound when Claude needs approval. | I haven't found an equivalent in other setups. |
| [`notification-alert.sh`](../hooks/notification-alert.sh) | Notification | Terminal bell + macOS notification banner. | I haven't found an equivalent in other setups. |

---

## Agents

Agents are specialist subagents with restricted tools, model overrides, and scoped memory. They do one job well.

### General-purpose agents

| Agent | What it does | Why it exists | Community comparison |
|-------|-------------|---------------|---------------------|
| [`code-reviewer`](../agents/code-reviewer.md) | Read-only code review for logical errors, race conditions, edge cases, type mismatches, CLAUDE.md compliance. | A second pair of eyes that can't accidentally change your code. Hooks enforce read-only - it physically can't write. | ECC has a `code-reviewer` agent. `claude-code-skills` has a multi-agent validator using 20 criteria. |
| [`security`](../agents/security.md) | Deep security audit adapted to detected tech stack. | Catches OWASP top 10, injection, auth gaps, secret exposure. Uses opus for depth. | Trail of Bits has 35 security plugins with CodeQL/Semgrep - the community gold standard. Our agent is lighter but doesn't require external tooling. |
| [`perf`](../agents/perf.md) | Performance audit for runtime bottlenecks, bundle bloat, network requests, rendering. | Catches the performance issues you don't think to look for. | `claude-code-skills` has a 4-sub-agent performance pipeline (profiler, researcher, validator, executor) - more sophisticated than ours. |
| [`architect`](../agents/architect.md) | Deep architectural research and recommendations. Does NOT write code. | Separates the thinking from the doing. Produces decision documents, not implementations. | ECC has an `architect` agent. Trail of Bits has `audit-context-building`. |
| [`cleanup`](../agents/cleanup.md) | Finds dead code, unused exports, orphaned files, stale dependencies. | Periodic hygiene before things accumulate. | ECC has `refactor-cleaner`. |
| [`simplify`](../agents/simplify.md) | Analyses code for unnecessary complexity and suggests simplifications. | Catches over-engineering after the fact. Uses sonnet for reasoning depth. | I haven't found an equivalent in other setups. |
| [`test-writer`](../agents/test-writer.md) | Writes tests. Detects framework, matches existing patterns, handles unit/integration/e2e. | The agent writes the tests, not you. Follows your existing test conventions. | ECC's `tdd-guide` guides the process. `claude-code-skills` has `test-auditor` with 7 parallel workers. |
| [`quick-edit`](../agents/quick-edit.md) | Fast haiku-based editor for trivial changes under 50 lines. Hooks prevent scope creep. | Speed for small changes. Escalates to sonnet if the task is too complex. | I haven't found an equivalent in other setups. |
| [`frontend-builder`](../agents/frontend-builder.md) | Implements frontend components with full fidelity. Designed for parallel execution. | Build multiple components simultaneously in separate worktrees. | Vercel skills cover patterns. I haven't found an equivalentas a builder agent. |
| [`backend-builder`](../agents/backend-builder.md) | Implements API routes, database schemas, server logic. Designed for parallel execution. | Same parallel pattern as frontend-builder, for backend work. | I haven't found an equivalent in other setups. |

### Review agents

| Agent | What it does | Community comparison |
|-------|-------------|---------------------|
| [`ui-review`](../agents/ui-review.md) | UI/UX review for usability, accessibility, responsive design, interaction quality. | I haven't found an equivalent in other setups. |
| [`a11y`](../agents/a11y.md) | Deep WCAG 2.2 AA/AAA review. Semantic HTML, keyboard nav, ARIA, forms, focus, contrast, motion. | I haven't found an equivalentas a dedicated agent. |
| [`migration-reviewer`](../agents/migration-reviewer.md) | Database migration safety. Checks SQL migrations, ORM migrations for destructive operations, rollback plans, data integrity. | I haven't found an equivalent in other setups. |

### WordPress agents

I haven't found WordPress-specialist agents in other Claude Code setups. These cover the full WordPress workflow.

| Agent | What it does |
|-------|-------------|
| [`wp`](../agents/wp.md) | Principal WordPress developer. Architecture, hooks, REST API, block editor, build tooling. |
| [`wp-reviewer`](../agents/wp-reviewer.md) | Read-only WordPress code reviewer. PHP, hooks, queries, REST endpoints. |
| [`wp-security`](../agents/wp-security.md) | WordPress security specialist. Sanitisation, escaping, nonces, auth, REST security. |
| [`wp-perf`](../agents/wp-perf.md) | WordPress performance. Query optimisation, caching strategy, asset loading, Core Web Vitals. |

---

## Skills

Skills are reusable task templates - structured guidance that the main Claude session follows directly. Unlike agents, skills don't delegate to a different "person."

### Workflow skills

| Skill | What it does | Why it exists | Community comparison |
|-------|-------------|---------------|---------------------|
| [`multi-review`](../skills/multi-review/SKILL.md) | Spawns 3 subagents in parallel (maintainability, performance, security). Consolidates findings with conflicts noted. | One command, three review angles. Catches issues that a single reviewer misses. | Superpowers separates requesting and receiving review into two skills. ECC has a single `/code-review` command. Neither runs reviews in parallel. |
| [`brainstorm`](../skills/brainstorm/SKILL.md) | Interviews you one question at a time, proposes 2-3 approaches with trade-offs, writes a discovery brief, runs a spec review loop (max 3 iterations). | Stops Claude from jumping to implementation before understanding the problem. The spec review catches gaps you glossed over. | Superpowers' `brainstorming` (65K installs) is the standard. We adapted their 9-step process to 6 steps, keeping the interview and spec review loop. |
| [`test-plan`](../skills/test-plan/SKILL.md) | Generate mode: creates user-facing test checklists from git diff. Execute mode: runs the plan via Playwright with PASS/FAIL/BLOCKED per scenario. | Test scenarios describe what a user does, not what the code does. Bridges the gap between code tests (test-writer agent) and user acceptance. | I haven't found an equivalentfor generating checklists from diffs. ECC's `/tdd` and Superpowers' `test-driven-development` focus on code-level tests. |
| [`vibe-user`](../skills/vibe-user/SKILL.md) | Opens an app in Playwright, explores as a real user. Blocks source code reading. Reports UX findings per page with top 3 improvements. | You built it, so you know too much. This skill surfaces problems you wouldn't notice because you're too close to the code. | I haven't found an equivalent in other setups. Anthropic's `webapp-testing` and Vercel's `web-design-guidelines` are code-focused, not user-focused. |
| [`review-memory`](../skills/review-memory/SKILL.md) | Loads all auto-memory files, categorises each as Promote/Keep/Remove, checks for duplicates, updates review timestamp. | Auto-memory accumulates noise. This skill helps you promote permanent learnings to CLAUDE.md/rules/skills and clean up the rest. | ECC uses session auto-save. `claude-mem` does automatic capture. Nobody has guided review with promote/keep/remove categorisation. |

### Tool skills

| Skill | What it does | Why it exists | Community comparison |
|-------|-------------|---------------|---------------------|
| [`debug-wp`](../skills/debug-wp/SKILL.md) | WordPress debugging interview and ranked remediation. | Structured diagnosis for WordPress problems. | I haven't found an equivalent in other setups. |
| [`figma`](../skills/figma/SKILL.md) | Figma MCP workflow for design extraction before implementation. | Forces tool-based design extraction over assumptions. Never implement from memory. | Google Labs Stitch handles design-to-code but isn't Figma-specific. |
| [`playwright`](../skills/playwright/SKILL.md) | Snapshot-first browser automation and verification. | The right workflow for Playwright MCP - snapshot to understand, screenshot to verify. | Anthropic's `webapp-testing` skill is the closest. |
| [`qa-check`](../skills/qa-check/SKILL.md) | Multi-stack QA audit (WCAG 2.2, performance, code quality). Auto-detects tech stack. | Before-you-ship checklist that adapts to WordPress, Python, Node, or static sites. | Superpowers' `verification-before-completion` checks that fixes are resolved. Ours is broader - accessibility, performance, and code quality. |

---

## Where the Community Goes Further

These are areas where other setups do more than ours. Worth knowing if you're considering what to add.

**Language-specific tooling.** [everything-claude-code](https://github.com/affaan-m/everything-claude-code) has dedicated rules, reviewers, and build-error resolvers for TypeScript, Python, Go, Rust, Java, Kotlin, C++, and Swift. We use language-agnostic rules - simpler to maintain, but less targeted.

**Security depth.** [Trail of Bits](https://github.com/trailofbits/skills) has 35 security plugins with CodeQL and Semgrep integration. Our security agent is lighter and doesn't require external tooling, but it can't match their depth.

**Multi-model review.** [claude-code-skills](https://github.com/levnikolaevich/claude-code-skills) runs Codex + Gemini + Claude in parallel debate rounds. We run three Claude agents in parallel on different angles - same parallelism, single model.

**Self-improving workflows.** Superpowers' `writing-skills` meta-skill and Trail of Bits' `skill-improver` create feedback loops for skill quality. We don't have this yet - when a skill underperforms, the fix is manual.

---

## Continue Reading

- [Start Here](start-here.md) - setup and first steps
- [Core Guide](core-guide.md) - how the pieces fit together
- [Governance Workflow](governance-workflow.md) - keeping the setup healthy over time

## Quick Links

- [Home](../index.md)
- [Rules](../rules/README.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)
- [Skills & Memory](../skills/README.md)
