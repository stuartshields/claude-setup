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
