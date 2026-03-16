# Changelog

## 2026-03-16

- Audited all custom hooks against community best practices (skipping GSD-managed hooks)
- Fixed `session-cleanup.sh` — added 5 missing `/tmp/claude-*` cleanup patterns and fixed glob for remind state files
- Added `stop_hook_active` guard to `stop-dispatcher.sh` — uses official loop-prevention mechanism instead of relying solely on custom flag files
- Rate-limited `hook-observability-summary.sh` — summary markdown now rebuilds every 10th event instead of every tool call
- Standardized stdin parsing to single-jq `@tsv` pattern in `hook-observability-summary.sh`, `track-modified-files.sh`, and `track-tasks.sh` — avoids buffering multi-MB PostToolUse payloads
- Removed duplicate CLAUDE.md reminder from `verify-before-stop.sh` — `remind-project-claude.sh` now owns that check exclusively
- Fixed `notification-alert.sh` to parse `title` and `message` from stdin JSON instead of hardcoding notification text
- Reverted tab enforcement in `check-code-quality.sh` to blocking (exit 2) — removed references to `fix-indentation.sh` which was never deployed
- Updated `hooks/README.md` — removed `fix-indentation.sh` walkthrough, updated code snippets to match deployed versions
- Overhauled all 8 always-loaded rule files for instruction compliance, based on community best practices audit
- Reduced always-loaded rule surface from ~310 lines to ~190 lines (38% reduction) while preserving all substance
- Deduplicated "Tests Pass But Code Has Bugs" (was in both `testing.md` and `debugging.md`, now only in `testing.md`)
- Deduplicated SQL injection and XSS rules (generic principles in `security.md`, WP-specific implementations stay in `php-wordpress.md`)
- Flipped ~20 negatively-framed rules to positive directives (research shows ~50% compliance improvement)
- Compressed "Resolving the Tension" teaching material in `discipline.md` from 18 lines to 3
- Merged "No Victory Declarations" into "Verify Before Declaring Done" in `discipline.md`
- Removed redundant code examples where the directive is clear without them
- Reordered rules within each file: most-violated rules at top and bottom (primacy/recency bias)
- Added design principles section to `rules/README.md` documenting the instruction budget approach
- No changes to conditional rules (`environment.md`, `php-wordpress.md`, `ui-ux.md`) - already well-scoped

## 2026-03-14

- Added `hook-observability-summary.sh` - PostToolUse/PostToolUseFailure hook that writes a per-session hook outcome summary to `docs/hook-observability-summary.md` in `~/.claude`
- Added governance controls for Hook Observability Summary and Memory Governance in `docs/governance/template.md`
- Reorganized governance docs under `docs/governance/` with `template.md`, `audits/`, and `evidence/` for easier handling
- Moved hook observability output to `docs/governance/evidence/hook-observability-summary.md`
- Added `stop-dispatcher.sh` - single Stop hook entry that runs `check-unfinished-tasks.sh`, `drift-review-stop.sh`, and `stop-quality-check.sh` in order, then returns one final decision
- Changed Stop policy to block-only - advisory output no longer surfaces on Stop, which avoids noisy finish loops and keeps Stop deterministic
- Moved `verify-before-stop.sh` from `Stop` to `UserPromptSubmit` - now emits a compact, rate-limited verification reminder before prompts instead of running build/test at finish time
- Hardened task state tracking - removed fallback completion in `track-tasks.sh`; `TaskUpdate` now requires valid `taskId` mapping and persists mismatches for follow-up hooks
- Updated `check-unfinished-tasks.sh` mismatch handling - warns on `UserPromptSubmit`, blocks on `Stop` until task mapping is corrected
- Reduced `UserPromptSubmit` noise in `remind-project-claude.sh` - steady-state prompts stay quiet; reminders now emit only for actionable CLAUDE.md conditions and are sparsely repeated
- Reduced `UserPromptSubmit` task reminder chatter in `check-unfinished-tasks.sh` - reminders now emit on task-state changes, explicit task pivots, or sparse heartbeat intervals
- Updated `verify-before-stop.sh` advisory cadence - reminders are now state-aware and re-emit only on state changes (or sparse intervals), reducing repeated context injection

## 2026-03-13

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
- Updated CLAUDE.md "Plan First" rule - action-type routing (investigate vs implement) replaces the blanket "&gt; 2 files" plan gate

## 2026-03-09

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

## 2026-03-08

- Updated loading order, hook events, agent frontmatter, skills section, and new concepts to match current official docs

## 2026-03-04

- Initial release - rules, hooks, agents, settings, skills, GSD