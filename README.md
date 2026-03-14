# Claude Code Setup

Here's how I set up my Claude Code. This repo IS the configuration - the files here belong in `~/.claude/`. When you clone this and copy the contents to `~/.claude/`, you get persistent instructions, automated quality gates, and specialised subagents that apply across every project you work on.

The structure maps directly to `~/.claude/`: `rules/` → `~/.claude/rules/`, `agents/` → `~/.claude/agents/`, `hooks/` → `~/.claude/hooks/`, `skills/` → `~/.claude/skills/`, `settings.json` → `~/.claude/settings.json`. None of these directories belong in a project root - they're user-global configuration.

## What's Changed

### 2026-03-14
- Added `stop-dispatcher.sh` - single Stop hook entry that runs `check-unfinished-tasks.sh`, `drift-review-stop.sh`, and `stop-quality-check.sh` in order, then returns one final decision
- Changed Stop policy to block-only - advisory output no longer surfaces on Stop, which avoids noisy finish loops and keeps Stop deterministic
- Moved `verify-before-stop.sh` from `Stop` to `UserPromptSubmit` - now emits a compact, rate-limited verification reminder before prompts instead of running build/test at finish time
- Hardened task state tracking - removed fallback completion in `track-tasks.sh`; `TaskUpdate` now requires valid `taskId` mapping and persists mismatches for follow-up hooks
- Updated `check-unfinished-tasks.sh` mismatch handling - warns on `UserPromptSubmit`, blocks on `Stop` until task mapping is corrected
- Reduced `UserPromptSubmit` noise in `remind-project-claude.sh` - steady-state prompts stay quiet; reminders now emit only for actionable CLAUDE.md conditions and are sparsely repeated
- Reduced `UserPromptSubmit` task reminder chatter in `check-unfinished-tasks.sh` - reminders now emit on task-state changes, explicit task pivots, or sparse heartbeat intervals
- Updated `verify-before-stop.sh` advisory cadence - reminders are now state-aware and re-emit only on state changes (or sparse intervals), reducing repeated context injection

### 2026-03-13
- Added `fix-indentation.sh` - PostToolUse hook that auto-converts leading spaces to tabs via `unexpand` after Write/Edit, eliminating wasted token cycles from repeated Write rejections
- Changed tab enforcement in `check-code-quality.sh` from blocking (exit 2) to non-blocking warning - the PostToolUse hook handles the fix automatically
- Added "Tab Handling for Edit Tool" rule to `style.md` - explicit directives for using literal tab characters in `old_string`/`new_string`, with a ban on sed/awk/python3 fallbacks (addresses known Claude Code bugs [#11447](https://github.com/anthropics/claude-code/issues/11447), [#25913](https://github.com/anthropics/claude-code/issues/25913), [#26996](https://github.com/anthropics/claude-code/issues/26996))
- Removed `Bash(python3:*)` from allowed permissions - closes the escape hatch that let Claude bypass the quality hook entirely
- Added `stop-wrapper.sh` - JSON-safe wrapper that guarantees valid JSON output from all Stop hooks, preventing parse failures that caused silent hook bypasses
- Added `stop-quality-check.sh` - Stop hook that detects incomplete work patterns: deferred follow-ups, rationalised pre-existing issues, unverified success claims, "too many issues" excuses. Blocks once per session.
- Added `detect-perf-degradation.sh` - PostToolUse/PostToolUseFailure hook that tracks tool calls and detects reasoning loops (same call 3+ times) and error spikes (5+ failures in last 10 calls)
- All Stop hooks now wrapped with `stop-wrapper.sh` for reliable JSON output
- Added `PostToolUseFailure` event to hook configuration (fires `detect-perf-degradation.sh` on tool failures)
- Added Figma plugin (`figma@claude-plugins-official`) to enabledPlugins
- Updated CLAUDE.md "Plan First" rule - action-type routing (investigate vs implement) replaces the blanket "> 2 files" plan gate

### 2026-03-09
- Added Figma MCP rule enforcing tool-based design extraction (`get_design_context`, `get_screenshot`, `get_variable_defs`) over assumptions. Includes required tool call sequence, design token mapping, Code Connect support, and visual verification loop.
- Added Playwright MCP rule for browser automation best practices (`browser_snapshot` vs `browser_take_screenshot`, Figma comparison workflow, form interactions, debugging, token efficiency)
- Expanded block-git-commit hook to block destructive Bash commands (rm -rf, filesystem destruction, recursive permission changes) and data exfiltration (curl/wget POST)
- Fixed false positive where grep/search commands containing "rm -rf" as a string were incorrectly blocked
- Added "Beyond Default Claude" section and "Hardening" tips to README
- Strengthened TDD rules (mock skepticism, spec-first testing, mutation checks)
- Added persistent memory to code-reviewer and test-writer agents
- Added code examples to rules
- Added agent frontmatter fields (isolation, permissionMode, background)
- Added skill argument features, SKILL.md example
- Added /init /hooks /agents tips, hooks-guide link, stop_hook_active warning, hook types overview
- Added notification hooks (PermissionRequest + Notification) and git commit blocker hook
- Added memory system documentation
- Removed all emdashes and AI filler phrases across 28 files for human tone
- Added AGENTS.md context to CLAUDE.md section (what it is, how it relates, symlink workaround)

### 2026-03-08
- Updated loading order, hook events, agent frontmatter, skills section, and new concepts to match current official docs

### 2026-03-04
- Initial release - rules, hooks, agents, settings, skills, GSD

---

## Table of Contents

- [What's Changed](#whats-changed)
- [Quick Start](#quick-start)
- [Full Documentation](#full-documentation)
	- [Core Guide](docs/core-guide.md)
	- [Hooks](hooks/README.md)
	- [Agents](agents/README.md)
	- [Skills and Memory](skills/README.md)

---

## Quick Start

Want to try this now?

1. Clone this repo: `git clone https://github.com/shieldsstuart/project-claude-setup`
2. Copy the contents to your Claude directory: `cp -r project-claude-setup/. ~/.claude/`
3. Restart Claude Code (quit and reopen)
4. Open any project - your global rules, hooks, and agents are now active

That's it. Claude Code automatically loads `~/.claude/CLAUDE.md` at session start, picks up rules from `~/.claude/rules/`, runs hooks from `~/.claude/hooks/`, and makes agents from `~/.claude/agents/` available.

Read the rest of this to understand what each part does and why - so you can adapt it to your own workflow instead of just running mine.

---

## Full Documentation

The rest of this documentation is now split by area:

- [Core Guide](docs/core-guide.md)
- [Rules](rules/README.md)
- [Hooks](hooks/README.md)
- [Agents](agents/README.md)
- [Skills and Memory](skills/README.md)

Each section above was moved from this README without rewriting the original content.
