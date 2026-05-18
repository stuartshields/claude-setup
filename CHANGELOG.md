# Changelog

Tracks changes to harness config: rules, agents, skills, hooks, settings, and global CLAUDE.md.

## 2026-05-17

### Audit pass 4 — clean-code alignment + Node 22 enforcement
- **`CLAUDE.md` Section 3 "AGENT ROUTING"**: added 7-bullet decision tree mapping common intents → specific agents. Closes the "27 agents, which one?" routing ambiguity at the main-session level. Per [Nimbalyst 2026 Subagents Guide](https://nimbalyst.com/blog/claude-code-subagents-guide/) + [Rick Hightower's coordination patterns](https://medium.com/@richardhightower/claude-code-subagents-and-main-agent-coordination-a-complete-guide-to-ai-agent-delegation-patterns-a4f88ae8f46c) — community consensus is that agents are deliberately context-walled, so the lever for reducing overlap is routing INTO them, not sharing rules INSIDE them
- **4 agent descriptions sharpened** to disambiguate adjacent specialists:
  - `code-reviewer`: now specifies "single files or focused diffs" + redirects to `architect-reviewer` for multi-file/pre-merge
  - `architect-reviewer`: now specifies "multi-file PR or pre-merge review" + redirects to `code-reviewer` for single-file
  - `cleanup`: now "code that shouldn't exist" + redirects to `simplify` for code that exists but is over-built
  - `simplify`: now "live code with unnecessary complexity" + redirects to `cleanup` for unused/dead code
- **Agents NOT consolidated (with reasoning)**: kept `wp-reviewer` / `wp-security` / `wp-perf` separate (WordPress is a real domain with idiom-specific failure modes per concern); kept `migration-reviewer`, `api-contract-reviewer`, `history-reviewer`, `test-coverage-reviewer` as genuine specialists. Context isolation is the platform feature, not the bug
- **`rules/discipline.md`**: added "Boy-scout the surface, not the diff" bullet to "Surface, Don't Dismiss". Codifies the *noticing* half of the Boy Scout Rule (scan ±20 lines for decay while editing) without importing the [clean-code-skills boy-scout SKILL.md](https://github.com/ertugrul-dmr/clean-code-skills/blob/main/skills/typescript/boy-scout/SKILL.md) — that skill mandates silent auto-application, which directly contradicts the "silently expanding scope is the mirror failure" rule already on the books. Budget: 54 → 55 always-on bullets
- **`rules/environment.md`**: clarified Node 22 default to cover the active-shell case explicitly. New bullet 1: "Default to Node 22 in the active shell" — if `node --version` major ≠ 22 AND no project pin exists, run `nvm use 22` before any install/dev/build. Earlier wording was framed as "new projects only" and missed the common case of an existing project on a session with the wrong shell version
- **`rules/code-quality.md`**: new always-on rule (5 bullets). Establishes write-time principles for DRY, single responsibility, no defensive scaffolding, delete-don't-comment dead code, named constants over magic numbers. Existing coverage (`simplify` agent, `code-reviewer` agent, `check-code-quality.sh` hook) operates at review/cleanup time; this rule fires while code is being written. Always-on budget remains under the 70 ceiling
- **`rules/environment.md`**: added "Node Version" section. New Node projects pin to 22 via `.nvmrc` + `engines.node: ">=22"`. Existing pins (`.nvmrc`, `engines.node`, `.tool-versions`, `volta.node`) win — Claude surfaces divergence rather than auto-switching. `nvm install` requires user consent
- **`CLAUDE.md`**: bootstrap step 3 now writes Node 22 pin for Node projects. Step 4 references `code-quality.md` so local CLAUDE.md authors know clean-code expectations live at the global layer
- **`rules/README.md`**: count corrected 13 → 14. Always-on now lists 6 files
- **Audit cross-referenced** against [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills) (C1-C5, F1-F4, G1-G36, N1-N7), [Anthropic Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), [Progressive Disclosure pattern](https://deepwiki.com/daymade/claude-code-skills/3.3-progressive-disclosure-pattern), [Nimbalyst 2026 Subagents Guide](https://nimbalyst.com/blog/claude-code-subagents-guide/), [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md). Validated patterns against community rather than single-source

### Deliberately NOT changed (with reasoning)
- **Agents (27 files)**: `code-reviewer`, `simplify`, `cleanup` already cover the clean-code-skills checklist (large functions, dead code, redundancy, defensive checks, magic numbers, deep nesting, SRP via 200-line rule). Editing 27 files for marginal gain violates "smallest viable change" and risks regression. Verified by reading `simplify.md`, `code-reviewer.md`, `cleanup.md` end-to-end
- **Skills (~21 files)**: sampled `debugging`, `pre-flight-environment`, `audit-vs-fix-discipline`. Frontmatter is specific + trigger-laden + third-person. All under the 500-line progressive-disclosure threshold. No structural changes needed
- **`check-code-quality.sh` hook**: already enforces tabs, no `console.log`, no debugger, no `// ...` placeholders, no stub TODOs, no "throw not implemented" at write-time. Adding more patterns would false-positive on legitimate refactors

### Drift surfaced and fixed (same session)
- **Project mirror sync**: copied `rules/input-validation.md` (since 2026-04-23 in global) and `rules/swift-testing.md` (since 2026-05-10) into the repo — both were missing. `rules/README.md` count corrected 14 → 16, always-on `6 → 7` (input-validation added), scoped `8 → 9` (swift-testing added)
- **`rules/discipline.md` sync**: mirror was missing the "Surface, Don't Dismiss" section (4 bullets, added to global on 2026-05-15). Overwrote mirror with global. Now identical
- **`hooks/check-code-quality.sh`**: diffed mirror vs global — identical. No drift to fix
- **`rules/README.md` in global**: confirmed it does not exist (only the project mirror has one). Likely intentional — the showcase repo documents what users see. Left as-is

## 2026-05-15

### Audit pass 1 — sync + schema upgrade
- **Synced repo against live `~/.claude/`**: copied `api-contract-reviewer`, `history-reviewer`, `test-coverage-reviewer` into the repo (these existed live since 2026-04-02 but were never mirrored)
- **agents/README.md**: bumped count 24 → 27. Added the three reviewers to the read-only auditors group. Updated the "Read-only auditors" prose to describe what each adds beyond `code-reviewer`
- **README.md (live)**: replaced inline "What's Changed" section with pointer to `CHANGELOG.md`. The repo restructured to a separate changelog on 2026-03-22 but the live copy still had inline history with stale `fix-indentation.sh`/`stop-wrapper.sh` claims
- **hooks/repeated-bash-guard.sh, repeated-edit-guard.sh, context-drift-guard.sh**: switched from unofficial `CLAUDE_SESSION_ID` to canonical stdin `.session_id` extraction with `CLAUDE_CODE_SESSION_ID` env var fallback (2.1.132+). The old env var didn't exist, so session IDs were silently collapsing to `"unknown"`
- **13 read-only auditor agents**: added `permissionMode: plan` frontmatter (added in Claude Code 2.1.126). Total agents using the field: 3 → 16
- **settings.json**: pinned `worktree.baseRef: "fresh"` (default flipped twice in April/May; explicit avoids future surprise)
- **hooks/posttool-dispatcher.sh**: new dispatcher consolidating 8 PostToolUse hook entries into 1. Single stdin buffer, parallel-array matcher table, sub-hooks invoked by tool name. Settings.json PostToolUse collapsed 8 → 1. PostToolUseFailure left unchanged

### Audit pass 2 — community best-practice alignment
- **10 agents rewrote descriptions** to follow the Nimbalyst 2026 triage pattern ("Use when [condition]. Reports [output shape]."): `a11y`, `api-contract-reviewer`, `code-reviewer`, `feasibility-check`, `history-reviewer`, `migration-reviewer`, `test-coverage-reviewer`, `wp-reviewer`, `quick-edit`, `backend-builder`. Source: [Nimbalyst Practical 2026 Subagents Guide](https://nimbalyst.com/blog/claude-code-subagents-guide/)
- **skills/multi-review**: deleted (live + repo). Superseded by `skills/review` which spawns 8 specialist reviewers vs `multi-review`'s 3. Both were user-invocable (`disable-model-invocation: true`), making `multi-review` a strict subset
- **skills/README.md**: updated TL;DR count 13 → 15. Added `clean-worktrees`, `review`, `swift-concurrency-review` (previously unlisted). Rewrote `/multi-review` paragraph to describe `/review`'s 8-specialist approach. Removed `/multi-review` from effort-routing list

### Audit pass 3 — relaxing over-strict hooks
- **hooks/verify-before-stop.sh**: state key stabilised to `"has_changes"` (was `$TOTAL_CHANGED` count). Heartbeat raised 5m → 30m. Fixed: every Edit/Write that changed the uncommitted-file count was re-firing the `VERIFICATION: N files...` reminder, producing per-prompt noise on long sessions
- **hooks/remind-project-claude.sh**: state key now binary `s{0|1}c{0|1}` (staleness × churn) instead of md5(NOTES). Heartbeat raised 15m → 60m. Fixed: CLAUDE.md age stays constant mid-session but changed-file count drift was re-firing the reminder
- **hooks/check-unfinished-tasks.sh**: UserPromptSubmit heartbeat raised 5m → 15m for steady-state task lists
- **hooks/stop-quality-check.sh**: removed 3 low-precision patterns (deferred work, listed-without-fixing, "too many issues" excuse). Kept the 2 high-precision blocks (pre-existing-issue rationalisation, success-without-verification). The removed patterns false-positived on legitimate trade-off discussion and scope-boundary explanations. Smoke-tested: 4/4 cases (legitimate discussion, rationalisation, unverified claim, verified claim) all classify correctly
- **hooks/block-git-commit.sh**: added allowlist for `rm -rf` under harness subdirectories with at least one subpath segment. Permits `rm -rf ~/.claude/skills/foo/` (single-target authorized cleanup) while still blocking `rm -rf ~/.claude/`, pipelines (`cd /tmp && rm -rf .`), and unrelated paths. 14/15 smoke tests pass; one pre-existing limitation around quoted echo strings is unchanged (regex can't distinguish quoted-string content from real command boundaries)
- **hooks/repeated-edit-guard.sh**: thresholds raised 2/3 → 3/5. Diagnosis check now at 3rd edit, workaround warning at 5th. Multi-step refactors and review-feedback workflows legitimately edit the same file 2-3 times
- **hooks/context-drift-guard.sh**: thresholds raised 5/7 → 8/12. Investigation-heavy work (audits, multi-file review) routinely hit the old thresholds during normal operation

### Bug fix discovered during this session
- **hooks/track-tasks.sh**: fixed read-modify-write race condition. Parallel `TaskUpdate` calls in one message could both read the state file, both write `${STATE}.tmp`, and last write would lose the earlier change. The bug surfaced when the Stop hook reported task #13 as unfinished despite it being marked completed. Added `mkdir`-based atomic lock around the state-file read-modify-write window (POSIX-portable, works on macOS + Linux). Smoke-tested with two concurrent hook invocations — both updates persist correctly. State file for the affected session patched directly to unblock

### Skipped (with reasoning recorded)
- **Hook `args: []` exec form refactor**: investigated and skipped. Exec form doesn't expand `~`, which would break 18 `~/.claude/hooks/...` entries. The bug class exec form fixes (shell quoting of paths with spaces / args with special chars) doesn't apply since your hooks take no arguments and have safe paths. Verdict: not worth the breakage risk
- **`tool-usage` skill → rules/discipline.md**: skipped — conflicts with the user's own `rules/harness-maintenance.md` ("Conditional procedures belong in skills, not rules"). `tool-usage` IS conditional (when Edit fails, when search budget hit)
- **Debug skill consolidation (`debugging`, `debug-rules`, `debug-wp`)**: investigated and rejected. The three are genuinely distinct in scope (general framework / rule-load diagnostics / WordPress interview); not overlap



## 2026-05-10

- **rules/swift-testing.md**: new scoped rule for Swift Testing patterns (paths-scoped to `*.swift`)
- **skills/swift-concurrency-review/**: new skill for reviewing Swift 5.5+ concurrency code (post-await state races, TOCTOU, cancellation handling, consumer-Task ownership)

## 2026-04-28

- **hooks/block-git-commit.sh**: hardened against further destructive-bash patterns and data exfiltration vectors

## 2026-04-23

- **rules/input-validation.md**: new always-on rule for input validation at trust boundaries (size ceilings, bounded numerics, authenticated vs payload identity, length/charset discipline, validate-before-persist ordering)

## 2026-04-11

- **CLAUDE.md**: refreshed (timestamp bumped to 2026-04-06T01:25+11:00)

## 2026-04-08

- **rules/debugging.md → skills/debugging/**: moved out of always-on rules into a model-invocable skill. Trigger phrases include "broken", "not working", "bug", "error", "still broken", "/trace"
- **rules/tool-usage.md → skills/tool-usage/**: moved out of always-on rules into a skill. Procedural conditionals don't belong in always-on context
- **hooks/repeated-bash-guard.sh**: removed `exit 2` blocking, kept advisory output. anthropics/claude-code#24327 causes Claude to stop responding when this hook blocks instead of acting on feedback
- **hooks/repeated-edit-guard.sh**: updated workaround-chain message to point at the `debugging` skill (was pointing at deleted `rules/debugging.md`)
- **rules/harness-maintenance.md**: expanded positive-framing exceptions for trap rules and safety rails
- **hooks/rtk-rewrite.sh, gsd-phase-boundary.sh, gsd-session-state.sh, gsd-validate-commit.sh**: refreshes

## 2026-04-06

- **rules/dependencies.md**: tightened hallucinated-reference prevention (verify package name, version, import path)
- **rules/security.md**: condensed to baseline patterns (parameterized SQL, framework escaping, URL allowlist, secrets, supply chain)
- **rules/testing.md**: refreshed
- **hooks/memory-review-prompt.sh**: updated cadence

## 2026-04-02

- **agents/api-contract-reviewer.md**: new read-only reviewer for REST/GraphQL/RPC contracts
- **agents/history-reviewer.md**: new read-only reviewer using `git blame`/`log` to catch accidentally reverted fixes
- **agents/test-coverage-reviewer.md**: new read-only reviewer for test gaps and assertion quality
- **skills/review/SKILL.md**: refreshed

## 2026-04-01

- **agents/architect-reviewer, browser-qa-agent, claude-architect, git-agent, perf, pr-writer, seed-generator, code-reviewer**: metadata refresh (consistent frontmatter, descriptions, `permissionMode` where appropriate)
- **skills/clean-worktrees/**: new skill for removing stale agent worktrees and orphaned branches

## 2026-03-26

- **rules/staleness.md, communication.md, discipline.md, research-and-decisions.md**: refreshes
- **hooks/drift-review-stop.sh, context-drift-guard.sh, repeated-approach-guard.sh**: refreshes
- **skills/block-journey, brainstorm, debug-rules, multi-review, qa-check, review-memory**: SKILL.md refreshes

## 2026-03-25

- **skills/figma/SKILL.md**: added Responsive Gate section (multi-breakpoint workflow) and Post-Implementation Spec Audit section (Playwright-based visual verification loop) — sources tracked in `SOURCES.md`

## 2026-03-23

- **agents/backend-builder, frontend-builder, test-writer, wp, feasibility-check, architect, security**: refreshes
- **skills/test-plan, vibe-user**: refreshes
- **rules/architecture.md, environment.md, php-wordpress.md, ui-ux.md**: refreshes
- **hooks/log-instructions.sh**: refresh

## 2026-03-22

### Synced from global `~/.claude/`
- **rules/discipline.md**: Added Context Pruning section (3 bullets). Added to Complete Implementations (edge cases), Do Not Pivot (test assertions, conditional branches, no workaround chains), Scope Control (classify before acting, design discussions, task boundaries, mid-session redirects), Verify Before Declaring Done (fix bugs during review, challenge tests, confirm right problem, passing tests != correct). Removed Anti-Over-Engineering section and "Do exactly what was asked" bullet (consolidated)
- **rules/debugging.md**: Added 6 bullets to Validate Before Fixing. Expanded Anti-Loop bullet. Specified `console.error` over `console.log` in two bullets
- **rules/style.md**: Updated Clean code bullet — `console.error` for debug, `console.log` hook-blocked
- **rules/harness-maintenance.md**: Expanded positive framing rule with trap/safety exceptions
- **rules/staleness.md**: Updated format from `YYYY-MM-DD` to ISO 8601 datetime
- **skills/review-memory/SKILL.md**: Reordered evaluation to Remove-first. Added Keep justification. Added accuracy verification rule
- **CLAUDE.md**: Removed rules now covered by `discipline.md` (Plan First, Design Discussion, Context Pruning, No Yapping, Do exactly what was asked, Anti-Over-Engineering)

### Timestamps
- Updated all `<!-- Last updated -->` comments from `YYYY-MM-DD` to ISO 8601 datetime (`YYYY-MM-DDTHH:MM+TZ:TZ`) across all rule files and CLAUDE.md

### Changelogs
- Created `~/.claude/CHANGELOG.md` for tracking harness config changes (rules, agents, skills, hooks, settings)

### Synced from global `~/.claude/` (second pass)
- **hooks/repeated-edit-guard.sh**: New hook — guards against repeated edits to the same file
- **settings.json**: Added `repeated-edit-guard.sh` PreToolUse hook on Edit, session cleanup now clears edit count files, figma plugin disabled
- **rules/discipline.md**: Shortened "No workaround chains" bullet (removed specific examples, kept the principle)

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