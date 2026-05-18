# Sources

External research that informed decisions in this project. Grouped by topic.

## Phase 15: Workflow Skills & Agents (2026-03-21)

### Superpowers Framework
- [obra/superpowers](https://github.com/obra/superpowers) - 7-stage development framework. Referenced for brainstorming, parallel agent dispatch, code review, and execution patterns. (2026-03-21)
- [brainstorming/SKILL.md](https://github.com/obra/superpowers/tree/main/skills/brainstorming) - 9-step brainstorm process with spec review loop (subagent reviews spec, max 3 iterations). Adapted to 6 steps for our brainstorm skill. (2026-03-21)
- [brainstorming/spec-document-reviewer-prompt.md](https://github.com/obra/superpowers/tree/main/skills/brainstorming) - Subagent prompt for spec review. 5 checks: completeness, consistency, clarity, scope, YAGNI. "Approve unless there are serious gaps." Adapted directly for our Step 5. (2026-03-21)
- [dispatching-parallel-agents/SKILL.md](https://github.com/obra/superpowers/tree/main/skills/dispatching-parallel-agents) - Pattern for spawning one agent per independent problem domain. Informed our multi-review skill structure. (2026-03-21)
- [requesting-code-review/SKILL.md](https://github.com/obra/superpowers/tree/main/skills/requesting-code-review) - Code review dispatch with git SHA scoping and severity triage. Informed multi-review's scope detection and output format. (2026-03-21)
- [executing-plans/SKILL.md](https://github.com/obra/superpowers/tree/main/skills/executing-plans) - Sequential task execution with blocker handling. Referenced for plan execution patterns. (2026-03-21)
- [verification-before-completion/SKILL.md](https://github.com/obra/superpowers/tree/main/skills/verification-before-completion) - "Evidence before claims." Red flag language patterns. Already covered by our discipline.md and verify-before-stop.sh. (2026-03-21)

### Ivan Kristianto's AI Workflow
- [Ivan Kristianto](https://github.com/ivankristianto) - AI-augmented development workflow patterns. Structured prompting (Role, Method, Constraints, Output), UX review as a user ("Vibe User"), parallel 3-angle code review, test plan generation and browser execution, quality gates (6 checks per commit), session reflection for extracting learnings, throw-away mindset, fire-and-forget patterns. Informed the workflow skills (multi-review, brainstorm, vibe-user, test-plan), memory review system, quality gates hook, and the prompt templates project. (2026-03-21)

### Claude Code Documentation
- [Context7: /anthropics/claude-code](https://context7.com) - Skill frontmatter fields (name, description, argument-hint, disable-model-invocation, allowed-tools, model, context, agent, hooks). Agent frontmatter fields (name, description with example blocks, model, color, tools, hooks, memory, permissionMode, maxTurns). (2026-03-21)
- [Context7: /affaan-m/everything-claude-code](https://context7.com) - Community reference config with /code-review, /e2e, /learn, /skill-create commands. Quality review as a manual command rather than passive hook. (2026-03-21)

### Community Skills (skills.sh)
- [skills.sh](https://skills.sh) - Agent skills directory. Searched for existing multi-review, brainstorming, UX testing, and test plan skills. Found: no dedicated multi-reviewer skill exists (gap filled by ours), Superpowers brainstorming is the standard (65K installs), no user-perspective UX testing skill exists (gap filled by vibe-user), no QA-checklist-from-diff skill exists (gap filled by test-plan). (2026-03-21)

## Anti-Loop & Debugging Rules (2026-03-23)

- [@ctoth's global CLAUDE.md](https://gist.github.com/ctoth/d8e629209ff1d9748185b9830fa4e79f) - "words first on failure", "batch size 3 then checkpoint", "scroll back to goal every ~10 actions" patterns → `~/.claude/rules/debugging.md`, `~/.claude/rules/discipline.md` (2026-03-23)
- [5 Patterns That Make Claude Code Follow Your Rules](https://dev.to/docat0209/5-patterns-that-make-claude-code-actually-follow-your-rules-44dh) - primacy/recency bias, 150-200 instruction budget, hook enforcement for hard rules → informed rule file structure decisions (2026-03-23)
- [SFEIR Institute Debugging Guide](https://institute.sfeir.com/en/claude-code/claude-code-advanced-best-practices/debugging/) - 4-step framework validation, "operations under 45s have 97% success rate", scope containment rules → `~/.claude/rules/debugging.md` (2026-03-23)
- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) - phase-wise gated plans, babysitting prevention patterns → general reference (2026-03-23)
- [@markomitranic's anthropic-claude-code-rules.md](https://gist.github.com/markomitranic/26dfcf38c5602410ef4c5c81ba27cce1) - baseline Claude Code rules, investigation patterns → cross-referenced with existing rules (2026-03-23)

## Loop Issue Reports (2026-03-23)

- [Opus 4.6 explore/thinking loops (#24585)](https://github.com/anthropics/claude-code/issues/24585) - 5-22 minute explore loops, informed exploration breaker rule → `~/.claude/rules/discipline.md` Context Pruning (2026-03-23)
- [Opus 4.6 regression: loops, memory loss (#28469)](https://github.com/anthropics/claude-code/issues/28469) - repeated file reading + compaction cycles → `~/.claude/rules/discipline.md` Post-Compaction Discipline (2026-03-23)
- [Opus 4.6 delete-and-rewrite loop (#25995)](https://github.com/anthropics/claude-code/issues/25995) - write-delete-rewrite oscillation → `~/.claude/rules/debugging.md` Anti-Loop Protocol (2026-03-23)
- [Infinite compaction loop (#6004)](https://github.com/anthropics/claude-code/issues/6004) - re-read after compaction triggers another compaction → `~/.claude/rules/discipline.md` Post-Compaction Discipline (2026-03-23)
- [Context buffer research](https://gist.github.com/badlogic/cd2ef65b0697c4dbe2d13fbecb0a0a5f) - compaction behaviour across Claude Code, Codex CLI, OpenCode → informed post-compaction rules (2026-03-23)

## Testing, Tool Usage & Communication Rules (2026-03-23)

- [Claude Tested Everything Except the One Thing That Mattered](https://christophermeiklejohn.com/ai/claude/2026/03/08/claude-tested-everything-except-the-one-thing-that-mattered.html) - 24% fix-commit ratio, tests follow ease not importance, CI circumvention → `~/.claude/rules/testing.md` Test Loops section (2026-03-23)
- [Claude Code Error Editing File: Causes & Fixes](https://claudelog.com/faqs/claude-code-error-editing-file/) - Edit tool retry patterns, stale content matching, whitespace mismatches → `~/.claude/rules/tool-usage.md` Edit Tool section (2026-03-23)
- [Edit tool retry issues (#3471)](https://github.com/anthropics/claude-code/issues/3471) - repeated Edit failures with whitespace variations → `~/.claude/rules/tool-usage.md` Edit retry limit (2026-03-23)
- [Claude defaults to 'defer' instead of 'try' (#31815)](https://github.com/anthropics/claude-code/issues/31815) - verification search loops, name variation retries → `~/.claude/rules/dependencies.md` verification limit (2026-03-23)
- [agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp) - scoped security audits, OWASP rule injection → `~/.claude/rules/security.md` Audit Scope (2026-03-23)
- [Claude Code Rules: Stop Stuffing Everything into One CLAUDE.md](https://medium.com/@richardhightower/claude-code-rules-stop-stuffing-everything-into-one-claude-md-0b3732bca433) - rule file splitting, instruction budget, scoped rules → informed creation of `testing.md`, `tool-usage.md`, `communication.md` (2026-03-23)
- [I Wrote 200 Lines of Rules for Claude Code. It Ignored Them All.](https://dev.to/minatoplanb/i-wrote-200-lines-of-rules-for-claude-code-it-ignored-them-all-4639) - 150-200 instruction ceiling, attention decay → validated rule deduplication strategy (2026-03-23)

## Skill & Agent Loop Bounds (2026-03-23)

- [Create custom subagents - Claude Code Docs](https://code.claude.com/docs/en/sub-agents) - maxTurns as safety net, subagent context isolation, tool restriction patterns → informed architect 8-turn research budget (2026-03-23)
- [Claude Code Agent Teams: The Complete Guide 2026](https://claudefa.st/blog/guide/agents/agent-teams) - escalation patterns, sequential delegation, unbounded loop risks without turn limits → informed all 5 skill/agent loop bounds (2026-03-23)
- [Extend Claude with skills - Claude Code Docs](https://code.claude.com/docs/en/skills) - skill context budget (2% of context window), skill loading mechanics → informed test-plan file read limit and vibe-user page cap (2026-03-23)

## Rule Compliance & Conditional Rules Bug (2026-03-23)

- [5 Patterns That Make Claude Code Follow Your Rules](https://dev.to/docat0209/5-patterns-that-make-claude-code-actually-follow-your-rules-44dh) - instruction budget (~150-200), primacy/recency anchoring, positive framing cuts violations ~50%, hook enforcement → informed context-management.md breakout, rule audit, and deduplication (2026-03-23)
- [Claude Code Rules: Stop Stuffing Everything into One CLAUDE.md](https://medium.com/@richardhightower/claude-code-rules-stop-stuffing-everything-into-one-claude-md-0b3732bca433) - priority saturation, scoped rules, total instruction count matters more than file count → validated splitting context-management from discipline.md (2026-03-23)
- [Claude Code Rules Directory: Modular Instructions That Scale](https://claudefa.st/blog/guide/mechanics/rules-directory) - "one concern per file", path targeting reduces noise, no empirical data on file count vs instruction count → confirmed file count is neutral (2026-03-23)
- [paths: frontmatter in user-level rules ignored (#21858)](https://github.com/anthropics/claude-code/issues/21858) - YAML array syntax in ~/.claude/rules/ paths: produces invalid globs. CSV string format works. Root cause: internal CSV parser expects string, not array → switched all 6 conditional rules to CSV format (2026-03-23)
- [Invalid YAML syntax in paths property (#13905)](https://github.com/anthropics/claude-code/issues/13905) - original docs had invalid unquoted glob syntax, Anthropic updated to YAML arrays, but parser still expects CSV strings internally → confirmed CSV workaround (2026-03-23)
- [Path-based rules not loaded on Write (#23478)](https://github.com/anthropics/claude-code/issues/23478) - conditional rules only fire on Read, not Write/create. Known limitation, closed as NOT_PLANNED → documented as acceptable for our use case (debugging/review rules trigger on reading existing files) (2026-03-23)
- [How Claude remembers your project - Official Docs](https://code.claude.com/docs/en/memory) - official docs show YAML array syntax as correct format, symlinks supported, InstructionsLoaded hook for audit logging → created log-instructions.sh hook to verify rule loading (2026-03-23)
- [Hooks - Official Docs](https://code.claude.com/docs/en/hooks) - InstructionsLoaded event schema: file_path, memory_type, load_reason, globs, trigger_file_path → informed log-instructions.sh implementation (2026-03-23)

## Rules Best-Practice Audit (2026-04-06)

### Debugging Improvements
- [Anthropic best practices](https://code.claude.com/docs/en/best-practices) - Context pollution: failed attempts degrade reasoning. `/clear` after hitting anti-loop limit → `~/.claude/rules/debugging.md` Anti-Loop Protocol (2026-04-06)
- [AgenticCoding.ai Lesson 10](https://agenticoding.ai/docs/practical-techniques/lesson-10-debugging) - Explicit "Explain" step (written root cause with file paths) before fixing → `~/.claude/rules/debugging.md` Validate Before Fixing (2026-04-06)
- [ChrisWiles/claude-code-showcase systematic-debugging](https://github.com/ChrisWiles/claude-code-showcase/blob/main/.claude/skills/systematic-debugging/SKILL.md) - Pattern comparison (diff working vs broken), regression bisect, red flag self-check phrases → `~/.claude/rules/debugging.md` (2026-04-06)
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code/blob/main/CLAUDE.md) - Semantic loop detection: same-component same-assumption = same diagnosis regardless of code diff → `~/.claude/rules/debugging.md` Anti-Loop Protocol (2026-04-06)
- [Addy Osmani - AI Coding Workflow 2026](https://addyosmani.com/blog/ai-coding-workflow/) - Revert-to-checkpoint as debugging escape hatch → `~/.claude/rules/debugging.md` Anti-Loop Protocol (2026-04-06)

### Dependency Security
- [Endor Labs 2025 State of Dependency Management](https://www.endorlabs.com/lp/state-of-dependency-management-2025) - 34% of AI-suggested deps don't exist; slopsquatting attack vector → `~/.claude/rules/dependencies.md` (2026-04-06)

### Supply Chain Security
- [Snyk ToxicSkills study](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/) - 36.8% of community agent skills contain security flaws; hidden Unicode/shell injection in SKILL.md → `~/.claude/rules/security.md` Supply Chain (2026-04-06)

### Testing
- [awesome-claude-code-toolkit testing.md](https://github.com/rohitg00/awesome-claude-code-toolkit/blob/main/rules/testing.md) - Empty-implementation test smell → `~/.claude/rules/testing.md` Test Quality (2026-04-06)

### CLAUDE.md Structure
- [HumanLayer - Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - ~150-200 instruction ceiling; don't include style rules Claude can infer → trimmed CLAUDE.md Section 3 (2026-04-06)
- [MindwiredAI - Boris Cherny's 100-Line Workflow](https://mindwiredai.com/2026/03/25/claude-code-creator-workflow-claudemd/) - ~100 line CLAUDE.md, continuous updates, subagent delegation → validated existing approach (2026-04-06)
- [OmerFarukOruc AI Coding Agent Guidelines](https://gist.github.com/OmerFarukOruc/a02a5883e27b5b52ce740cadae0e4d60) - Bounded escalation format (one targeted question with recommended default) → informed debugging escalation tightening (2026-04-06)

### Hook Development
- [Claude Code hook best practices](https://context7.com) - Keep hooks independent, use timeouts, handle errors gracefully, silent fail patterns, debounce patterns. Informed memory-review-prompt.sh design. (2026-03-21)
- [everything-claude-code /save-session](https://github.com/affaan-m/everything-claude-code) - Community pattern for session state persistence. Dated session files with what worked/failed/remains. We use auto-memory + hook prompts instead. (2026-03-21)

### Audit/Review Calibration
- [Anthropic code-review plugin command](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md) - "Do not manufacture findings to justify the invocation"; HIGH-SIGNAL-only filter; pre-filtered false-positive exclusion list → calibration block in `audit-vs-fix-discipline` skill + new `rules/discipline.md` "Don't Manufacture Findings" section (2026-05-19)
- [everything-claude-code code-reviewer agent](https://github.com/affaan-m/everything-claude-code/blob/main/agents/code-reviewer.md) - 80% confidence gate + 4-question pre-report check + "A clean review is valid" → adopted as the calibration gate (2026-05-19)
- [Are LLMs Reliable Code Reviewers? Systematic Overcorrection (arxiv 2603.00539)](https://arxiv.org/html/2603.00539v1) - elaborate review prompts INCREASE false positives → kept calibration block terse (2026-05-19)
- [Anthropic Code Review setup (REVIEW.md pattern)](https://support.claude.com/en/articles/14233555-set-up-code-review-for-claude-code) - per-project override file at repo root → new `REVIEW.md` at repo root with project-specific calibration (2026-05-19)
