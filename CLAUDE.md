<!-- Last updated: 2026-05-17T09:41+10:00 -->

# GLOBAL PROTOCOL (v2026.2)

## 0. SHORTCUTS & TRIGGERS
- **Bootstrap Trigger**: If the current directory lacks a `CLAUDE.md`, immediately perform **DYNAMIC PROJECT INITIALIZATION**.
- **"Trace"** or **"/trace"**: Perform a deep-trace audit per the `debugging` skill (`~/.claude/skills/debugging/SKILL.md`).

## 1. MANDATORY WORKFLOW
- **Verify**: After implementing, run the project's build/test/lint command. If it fails, diagnose and fix before moving on. Never mark work as done without verifying it runs.
- **On Compaction**: Always preserve in the summary: all modified file paths, the current task and acceptance criteria, test commands and results, key decisions and reasoning.
- **CLAUDE.md is the Source of Truth**: Before making changes, read the project's `CLAUDE.md`. If your changes diverge from what it specifies, ask the user: "This differs from the project CLAUDE.md - should I update it first?" Update CLAUDE.md **early** - when you discover a new convention, make an architecture decision, or establish a pattern, propose the update immediately. Do not wait until the end of the task. Sessions can crash, compact, or be interrupted - anything not written to CLAUDE.md is lost.
- **Complexity Routing**: For changes touching 6+ files or requiring architectural decisions, ask: "This is complex enough to warrant structured planning. Want me to handle it ad-hoc or write a formal plan?" For 3-5 files, write the plan to `.planning/PLAN.md` instead of an ephemeral `<plan>` tag. For 6+ files, use [GSD](https://github.com/gsd-build/get-shit-done) if installed, or create a `.planning/` structure manually.

## 2. DYNAMIC PROJECT INITIALIZATION / MIGRATION
- **Condition: No local CLAUDE.md**:
	1. Scan configs (`package.json`, `requirements.txt`, etc.).
	2. Identify stack & commands (build/test/lint).
	3. **If Node project:** ensure `.nvmrc` pins `22` and `package.json` has `"engines": { "node": ">=22" }`. Run `nvm use 22` before any install/dev command. Honour an existing pin and surface divergence — see `rules/environment.md` "Node Version".
	4. Create local `CLAUDE.md` with project-specific conventions. Code-quality expectations (DRY, single responsibility, no defensive scaffolding, no commented-out code, named constants) live in `~/.claude/rules/code-quality.md` and apply across all projects.
- **Condition: Local CLAUDE.md exists but is legacy**:
	1. Strip redundant rules (global rules in `~/.claude/rules/` are auto-loaded).
	2. Keep only project-specific conventions.
	3. Standardize indents to Tabs.

## 3. AGENT ROUTING

Default to the main session. Spawn an agent only when a pattern below matches; pick the most specific.

- **Multi-file PR / pre-merge review**: `architect-reviewer` (spawns code-reviewer + security + perf in parallel, consolidates, drives fixes).
- **Single-file or single-diff review**: `code-reviewer` directly.
- **WordPress code**: `wp-reviewer` / `wp-security` / `wp-perf` — pick by concern. Not `code-reviewer`.
- **API / REST / GraphQL contract changes**: `api-contract-reviewer` (breaking-change detection).
- **DB migration before apply**: `migration-reviewer`. **Git-history-aware diff** (did this revert a prior fix?): `history-reviewer`.
- **Dead code / orphans**: `cleanup`. **Over-engineered / nested code**: `simplify`. **Test coverage gaps**: `test-coverage-reviewer`.
- **Parallel builders for cross-cutting work**: `frontend-builder` + `backend-builder` with `isolation: "worktree"`. **Trivial edit (<50 lines)**: `quick-edit`.
