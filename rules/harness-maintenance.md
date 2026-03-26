---
paths: ".claude/rules/**,.claude/hooks/**,.claude/agents/*.md,.claude/skills/**,.claude/CLAUDE.md,.claude/settings.*"
---
<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Harness Maintenance Protocol

> Applies when modifying rules, hooks, agents, skills, settings, or global CLAUDE.md - not project work or GSD.

## Research Before Changing
- **IMPORTANT: Do not use training data for harness decisions.** Always validate with external sources (WebSearch/WebFetch) before modifying rules, hooks, agents, or skills. Training data is stale and may reflect outdated Claude Code behavior, deprecated APIs, or patterns that no longer apply.
- **Check the system prompt repo** ([Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)) to understand what the system prompt already says. Rules that duplicate system prompt directives waste instruction slots.
- **Check known issues** on [anthropics/claude-code](https://github.com/anthropics/claude-code/issues) for model-level behavioral patterns relevant to the change.
- **Check existing research first.** Read `~/.claude/projects/-Users-stuart--claude/memory/reference_harness_research.md` before searching - the topic may already have sources from a prior session.

## Instruction Budget
- **Always-on ceiling: ~70 bullet points across unscoped rule files.** The system prompt adds ~50 more. Total should stay under ~120. Current count: ~59 always-on bullets across 7 files.
- **Before adding a new rule:** count always-on bullet points (`grep -c '^\s*-' ~/.claude/rules/*.md` for unscoped files). If at/near 70, scope or consolidate before adding.
- **Delete rules Claude already follows without instruction.** If removing a rule wouldn't change behavior, it's wasting a slot.
- **Scope rules by path** when they only apply to specific file types. Use `paths:` frontmatter. Currently 8 of 15 rule files are scoped.

## Hooks Over Prose
- **If a rule is violated 2-3 times, move enforcement to a hook.** Prose rules are suggestions; hooks are laws. Meta-cognitive rules ("if you catch yourself doing X, stop") are especially weak as prose - convert them to hooks that detect the pattern mechanically.
- **Prefer detection hooks over instruction rules** for: context drift (consecutive reads without action), approach oscillation (write-revert-rewrite), command repetition, and workaround chains. These patterns are better caught by tracking state than by asking the model to self-monitor.
- **Advisory hooks (exit 0) for warnings, blocking hooks (exit 2) for hard limits.** Use advisory for patterns where judgment matters (2nd edit to same file). Use blocking for patterns that are always wrong (4th identical bash command).

## Rule Quality Checks
- **Positive framing over negative - with exceptions.** "Use named exports" beats "Do NOT use default exports." **Keep negative framing for trap rules** (wrong actions that look right) **and safety rails** (severe consequences).
- **Anchor critical rules at top and bottom** of the file (primacy + recency bias).
- **Check for conflicts with system prompt directives.** System prompt has higher attention weight - your rule must be specific and additive to win.
- **Check for conflicts between rule files.** Search for contradictions.
- **Include rationale when the reason is non-obvious.** One sentence, not a paragraph.

## After Any Change
- **Add source URLs** to `~/.claude/projects/-Users-stuart--claude/memory/reference_harness_research.md` under the appropriate section.
- **Recount always-on instructions** to verify budget compliance.
- **Test hooks** with sample input to verify they catch what they should and don't false-positive.
