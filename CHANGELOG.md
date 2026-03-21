# Changelog

## 2026-03-21

### New workflow skills
Added 5 new skills built from comparing workflows against external AI-augmented development patterns (Superpowers framework, community skills directory, colleague's blog post). These fill gaps the community hasn't addressed - no existing skills cover parallel multi-angle code review, user-perspective UX testing, or memory lifecycle management.

- `multi-review` - Spawns 3 subagents in parallel (code-reviewer for maintainability, perf for performance, security for vulnerabilities). Each reviews the same scope from a different angle. Consolidates findings into a single report with conflicts noted when agents disagree. The parallel review pattern was adapted from Superpowers' dispatching-parallel-agents skill and the blog post's 3-angle code review approach.
- `brainstorm` - Structured discovery before planning. Explores project context, interviews you one question at a time, proposes 2-3 approaches with trade-offs, writes a discovery brief, then dispatches a subagent to review the brief (max 3 iterations). Adapted from Superpowers' 9-step brainstorming skill - simplified to 6 steps since their spec review loop and visual companion are the only parts worth keeping.
- `vibe-user` - Opens an app in Playwright and explores it as a real user with no prior knowledge. Blocks source code reading - the value is the fresh perspective. Documents findings per page, tests core flows, reports top 3 improvements. No community equivalent exists.
- `test-plan` - Two modes in one skill. Generate mode creates user-facing test checklists from git diff. Execute mode runs the plan via Playwright, recording PASS/FAIL/BLOCKED with screenshots. No community equivalent for the generate-from-diff pattern.
- `review-memory` - Guided memory cleanup. Loads all topic files, categorises entries as Promote (move to CLAUDE.md/rules/skills), Keep, or Remove. Checks for duplicates before promoting. Updates the review timestamp so the memory-review hook knows when you last reviewed. The community uses manual `/reflect` or `/learn` skills that depend on you remembering to invoke them - our approach automates the prompt via hooks.

### New hooks
- `project-quality-gates.sh` - PostToolUse advisory hook that detects project lint/typecheck/test commands from package.json and config files (eslint, tsconfig, biome). Reports available gates without running them - the agent decides when to run them before finishing. Rate-limited to 60s. Adapted from the blog post's quality gates concept (6 checks per commit) into an advisory model that doesn't block partial work.
- `memory-review-prompt.sh` - Three-trigger memory review prompt. Fires on: GSD phase completion (UserPromptSubmit), 3+ new memory files on session start (SessionStart on startup/clear/compact), or context at 30% remaining with 3+ new files (PostToolUse). Advisory only. The 30% threshold sits between GSD's warning (35%) and critical (25%) levels. Reads the context bridge file written by the statusline hook - same pattern the GSD context monitor uses.

### CLAUDE.md
- Added Design Discussion Checkpoint rule - during active design discussions, treat agreement as "I like this direction" not "go build it." Asks "Ready to build?" once after discussion concludes. Takes precedence over Plan First's execute-directly clause. This gap was identified when Claude jumped to implementation mid-discussion - no community patterns address the discussion-to-implementation transition.
- Removed remaining emdashes from Plan First and Research Sources sections

### Skill structure standardisation
- Standardised all skills on `## Method` (was `## Procedure` in qa-check)
- Added `## Method` wrapper and `## Rules` section to figma skill
- Replaced all double dashes (`--`) with single dashes across all new and existing skills
- Removed "actionable" AI filler from vibe-user description
- Added `Do NOT` hard boundary to vibe-user When to Use section
- Merged vibe-user Constraints into Rules (single section)
- test-plan detects default branch instead of hardcoding `main`

### Rules
- Added hook awareness note to discipline.md - documents that agent-guard hooks and stop sub-hooks are intentionally absent from settings.json (registered in agent frontmatter or called by dispatchers)

### Documentation
- Updated skills/README.md - 9 skills across workflow and tool categories with descriptions
- Updated hooks/README.md - hook count 20 to 22, added both new hooks to file table
- Updated governance-workflow.md - Control 7 (Memory Governance) now references the memory-review hook and /review-memory skill

### Component reference page
- Added `docs/component-reference.md` - single reference page covering every rule, hook, agent, and skill with what it does, why it exists, and how it compares to community alternatives (everything-claude-code, Superpowers, Trail of Bits, claude-code-skills, skills.sh)
- Linked from start-here.md (Continue Reading + Quick Links) and README.md (reading path + Full Documentation)

### Research sources
- Updated CLAUDE.md research sources rule - entries now include a per-entry date: `(YYYY-MM-DD)` for when the source was last verified
- Backfilled all entries in `.planning/SOURCES.md` with verification dates
- Added Hook Development sources section for context threshold and session state patterns

### Rules - new file
- Added `staleness.md` - tracks `<!-- Last updated: YYYY-MM-DD -->` comments across all guidance files (rules, CLAUDE.md, agents, skills). Flags files older than 30 days so AI best practices stay current as models evolve. Requires updating the date on every edit.

### All rules + CLAUDE.md
- Added `<!-- Last updated: 2026-03-21 -->` comment to all 12 rule files and `CLAUDE.md`. Future sessions will compare these dates against the current date and flag stale guidance.

### Rules README
- Updated file count (11 → 12), always-loaded count (5 → 6), bullet count (~76 → ~85) to reflect `staleness.md` addition.

## 2026-03-20

### Rules audit - instruction budget compliance
- Reduced always-on instruction count from 128 to 89 bullet points (system prompt adds ~50, total now ~139 vs 150 ceiling)
- Scoped `testing.md` and `architecture.md` with `paths:` frontmatter - only load when working with code files, not config/shell
- Deleted `verification.md` - merged unique Hook Awareness section into `discipline.md`, rest was duplicated by debugging.md and discipline.md
- Removed 4 rules from `discipline.md` that duplicate system prompt directives (error handling, wrappers, current requirements, grep-before-reading)
- Removed `style.md` "Full Fidelity" section - moved to `discipline.md` where it carries more weight (behavioral rules > style file)

### Rules audit - behavioral fixes
- Rewrote `debugging.md` - replaced "3 tool calls then guess" with 4-step framework (Reproduce → Isolate → Fix → Validate), added Anti-Loop Protocol (2 failed attempts → stop and ask), raised tool call threshold to 8 before summarizing
- Added "Do Not Pivot to Avoid Hard Work" section to `discipline.md` - counteracts system prompt compound effect where "try simplest approach first" + "keep solutions simple" + "consider alternatives when blocked" causes premature retreat from correct-but-harder fixes
- Added "Complete Implementations Come First" as top section in `discipline.md` (primacy bias) with key rule duplicated at bottom (recency bias)
- Fixed `testing.md`: "one assertion per test" → "one behavior per test"; "3+ mocks = refactor" softened to "consider refactoring"; added "test core user-facing behavior first" rule
- Fixed `debugging.md`: "minimal change" → "targeted change" to align with anti-pivot rules
- Fixed `ui-ux.md`: "must have aria-label" → "must have accessible names - prefer semantic HTML over aria-label" (W3C First Rule of ARIA compliance)
- Added design system override caveat to `ui-ux.md`

### Rules - new file
- Added `harness-maintenance.md` - scoped rule that only loads when editing `~/.claude/` harness files (rules, hooks, agents, skills, settings). Enforces: external research before changes, instruction budget compliance, positive framing, conflict checking, source URL tracking

### CLAUDE.md
- Added Section 3 "Research Sources" - track external research per project in `.planning/SOURCES.md`
- Renumbered Style Defaults to Section 4

### Hooks
- Expanded `check-code-quality.sh` - now catches TODO stubs, placeholder/stub/skeleton comments, `throw new Error('not implemented')`, Python `pass # todo` patterns (all blocking, exit 2)
- Fixed `stop-dispatcher.sh` - now aggregates ALL blocking reasons from sub-hooks instead of only keeping the last one

### Agents
- Increased `maxTurns` from 20 to 30 on `backend-builder`, `frontend-builder`, `test-writer` - 20 turns was exhausting budget before implementation completed
- Added `memory: user` to `architect` agent with memory instructions - architectural decisions should persist across sessions
- Added memory instructions to `test-writer` and `code-reviewer` - both had `memory: user` but no instructions to use it
- Upgraded `simplify` agent model from haiku to sonnet - proving behavioral equivalence requires deeper reasoning than haiku provides
- Fixed `frontend-builder` aria-label rule to match W3C First Rule of ARIA

### Skills
- Added `context: fork` and `agent: Explore` to `qa-check` skill - verbose audit output now runs in isolated context instead of polluting main conversation
- Updated `qa-check` WCAG version from 2.1 to 2.2 for consistency with a11y agent

## 2026-03-18

- Fixed `hook-observability-summary.sh` - summary now aggregates across all session logs instead of only the current session. Previous behavior overwrote the summary each new session, losing all prior data. Header now shows session count, date range, and latest session ID.

## 2026-03-16

- Audited all custom hooks against community best practices (skipping GSD-managed hooks)
- Fixed `session-cleanup.sh` - added 5 missing `/tmp/claude-*` cleanup patterns and fixed glob for remind state files
- Added `stop_hook_active` guard to `stop-dispatcher.sh` - uses official loop-prevention mechanism instead of relying solely on custom flag files
- Rate-limited `hook-observability-summary.sh` - summary markdown now rebuilds every 10th event instead of every tool call
- Standardized stdin parsing to single-jq `@tsv` pattern in `hook-observability-summary.sh`, `track-modified-files.sh`, and `track-tasks.sh` - avoids buffering multi-MB PostToolUse payloads
- Removed duplicate CLAUDE.md reminder from `verify-before-stop.sh` - `remind-project-claude.sh` now owns that check exclusively
- Fixed `notification-alert.sh` to parse `title` and `message` from stdin JSON instead of hardcoding notification text
- Reverted tab enforcement in `check-code-quality.sh` to blocking (exit 2) - removed references to `fix-indentation.sh` which was never deployed
- Updated `hooks/README.md` - removed `fix-indentation.sh` walkthrough, updated code snippets to match deployed versions
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