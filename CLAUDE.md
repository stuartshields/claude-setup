# GLOBAL PROTOCOL (v2026.2)

## 0. SHORTCUTS & TRIGGERS
- **Bootstrap Trigger**: If the current directory lacks a `CLAUDE.md`, immediately perform **DYNAMIC PROJECT INITIALIZATION**.
- **"Trace"** or **"/trace"**: Perform a deep-trace audit per the debugging rules in `~/.claude/rules/debugging.md`.

## 1. MANDATORY WORKFLOW
- **Plan First**: If the user asks to **investigate, review, audit, or explore** - report findings and wait for direction. Do not modify files. This applies even when routing through workflows or subagents - an audit routed through a planning workflow still produces a read-only report, not an action plan. If the user asks to **fix, implement, add, or update** - execute directly. Only gate on a `<plan>` when the scope is genuinely unclear (not when you've already identified the changes). See Complexity Routing below for file-count thresholds.
- **Design Discussion Checkpoint**: When the user has been asking questions about an approach (how it works, trade-offs, alternatives, edge cases), treat agreement as "I like this direction" not "go build it." After the discussion naturally concludes (no more questions from either side), ask "Ready to build?" once. If the user says no, continue the discussion and do not ask again until they give a clear build signal. Explicit triggers to start building: "build it", "go ahead", "start", "execute", "yes" in response to "Ready to build?". This rule takes precedence over the execute-directly clause of Plan First when a design discussion has been ongoing.
- **Context Pruning**: Read ONLY files strictly necessary for the current task.
- **No Yapping**: Skip introductions/conclusions. Output code or direct answers only.
- **Verify**: After implementing, run the project's build/test/lint command. If it fails, diagnose and fix before moving on. Never mark work as done without verifying it runs.
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
