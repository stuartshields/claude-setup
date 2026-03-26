---
title: Skills & Memory
---
<!-- Last updated: 2026-03-25T10:00+11:00 -->

## Skills

> **TL;DR:** 11 skills across 2 categories:
>
> - **Workflow skills** - `/brainstorm` (structured discovery before planning), `/multi-review` (parallel code review from 3 angles), `/review-memory` (guided memory cleanup with full and compact modes, post-promote contradiction check), `/test-plan` (generate and execute user-facing test checklists, 15-file limit for large diffs), `/vibe-user` (browser-based UX testing as a real user, 10-page cap with checkpoints).
> - **Tool skills** - `/block-journey` (trace editor and front-end user journeys for a block/component), `/debug-rules` (audit rule loading via InstructionsLoaded hook, flags CSV bug), `/debug-wp` (WordPress debugging), `/figma` (Figma MCP design-to-code, 3-round visual iteration limit), `/playwright` (browser automation), `/qa-check` (multi-stack QA audit, runs in forked context).
>
> Skills run in the main context by default. `qa-check` uses `context: fork` so its verbose output doesn't pollute your conversation.

For what each skill does, why it exists, and how it compares to community alternatives, see the [Component Reference](../docs/component-reference.md#skills).

Skills are reusable task templates with step-by-step instructions. They differ from agents: agents are delegatable specialists (a different "person" doing the work), skills are more like checklists - structured guidance for a task that the main Claude session follows directly.

### Workflow skills

These skills structure how you work with agents. They were built after comparing workflows against external AI-augmented development patterns and identifying gaps.

- `brainstorm` - Structured discovery before planning. Explores project context, interviews you with clarifying questions one at a time, proposes 2-3 approaches with trade-offs, and writes a discovery brief. The interview is the point - it stops the agent from jumping straight to building without understanding the problem. Writes output to `.planning/discovery/` when GSD is active, `docs/discovery/` otherwise.
- `multi-review` - Parallel code review from three angles. Spawns three subagents simultaneously (code-reviewer for maintainability, perf for performance, security for vulnerabilities), each reviewing the same scope. Consolidates findings into a single report with conflicts noted when agents disagree. Use before merging or after completing a feature.
- `test-plan` - Two modes in one skill. Generate mode creates a user-facing test checklist from git diff - scenarios describe what a user does, not what the code does. Execute mode runs an existing plan via Playwright MCP, recording PASS/FAIL/BLOCKED per scenario with screenshots as evidence.
- `vibe-user` - Opens an app in Playwright and explores it as a real user with no prior knowledge. The skill explicitly blocks reading source code - the value is the fresh perspective. Documents findings per page, tests core user flows, and reports the top 3 highest-impact UX improvements.
- `review-memory` - Guided cleanup of auto-memory. Two modes: full mode loads all memory files, categorises each entry as Promote/Keep/Remove, presents a table for approval, and runs a post-promote contradiction check against existing rules. Compact mode (`/review-memory --compact`) reads only MEMORY.md summaries and asks a single question - use when context is low or the hook suggests it. Checks for duplicates before promoting and warns if MEMORY.md exceeds the 200-line auto-loaded limit. Run it when the memory-review hook prompts you, or anytime you want to audit what auto-memory has captured.

### Tool skills

These skills wrap specific tools or integrations with structured methodology.

- `block-journey` - Discovers all files for a block or component, traces the editorial and front-end user journeys, and writes a journey document to `.planning/journeys/`. Read-only analysis - does not modify source files. Accepts an optional directory scope (e.g., `/block-journey rte-blocks/accordion`).
- `debug-rules` - Diagnose rule loading issues. Reads the `InstructionsLoaded` audit log, compares against expected rules in `~/.claude/rules/`, reports what loaded (and why), what didn't, and flags the user-level `paths:` CSV bug if detected. Requires the `log-instructions.sh` hook.
- `debug-wp` - WordPress debugging workflow: isolate, trace, reproduce, fix
- `figma` - Figma MCP workflow for design extraction before implementation
- `playwright` - Playwright MCP browser automation and verification workflow
- `qa-check` - Quality assurance checklist for before-you-ship reviews (runs in forked context via Explore agent)

### Directory structure

```
skills/
  block-journey/
    SKILL.md    ← block/component user journey documentation
  brainstorm/
    SKILL.md    ← structured discovery before planning
  debug-wp/
    SKILL.md    ← WordPress debugging interview
  figma/
    SKILL.md    ← Figma MCP design-to-code
  multi-review/
    SKILL.md    ← parallel 3-angle code review
  playwright/
    SKILL.md    ← browser automation
  review-memory/
    SKILL.md    ← guided memory cleanup and promotion
  qa-check/
    SKILL.md    ← multi-stack QA audit
  test-plan/
    SKILL.md    ← test checklist generation and execution
  vibe-user/
    SKILL.md    ← browser-based UX testing
```

Skills live at `~/.claude/skills/` globally, or `.claude/skills/` for project-specific ones.

### Skill frontmatter

Skills support 12 frontmatter fields:

| Field | What it does |
|-------|-------------|
| `name` | Display name (defaults to directory name). Lowercase, numbers, hyphens, max 64 chars. |
| `description` | What the skill does and when to use it. |
| `argument-hint` | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | Set to `true` to prevent Claude from auto-loading this skill. |
| `user-invocable` | Set to `false` to hide from the `/` menu. |
| `allowed-tools` | Tools Claude can use without permission when skill is active. |
| `model` | Model to use when skill is active. |
| `effort` | Effort level when skill is active (`low`, `medium`, `high`, `max`). Overrides session effort. `max` is Opus 4.6 only. |
| `shell` | Shell for `` !`command` `` blocks. `bash` (default) or `powershell`. |
| `context` | Set to `fork` to run in a forked subagent context. |
| `agent` | Which subagent to use when `context: fork` is set. |
| `hooks` | Hooks scoped to this skill's lifecycle. |

<details markdown="1">
<summary>Example: A debugging skill (SKILL.md)</summary>

```yaml
---
name: debug-wp
description: Starts a structured interview to diagnose WordPress issues, then proposes a ranked list of solutions.
argument-hint: "[symptom or error message]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Skill: debug-wp

## When to Use
Use this skill when diagnosing any WordPress problem...

## Method
### Phase 1: Triage Interview
Ask questions in this order...
```

</details>

Run `/debug-wp 500 error on checkout page` to invoke with arguments. The `argument-hint` text appears in the autocomplete menu.

### Forked context

Set `context: fork` to run the skill in a separate subagent. The skill content becomes the prompt. Use `agent` to specify which subagent type handles it - built-in agents (`Explore`, `Plan`, `general-purpose`) or custom subagents from your `agents/` directory.

### String substitutions

Skills support variable substitution: `$ARGUMENTS` (full argument string), `$ARGUMENTS[N]` or `$N` (Nth argument), `${CLAUDE_SESSION_ID}`, and `${CLAUDE_SKILL_DIR}`.

### Dynamic context

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude. Use it to inject dynamic context - git status, current branch, file listings - into the skill prompt.

### Bundled skills

Claude Code ships with several built-in skills: `/simplify` (code quality review), `/batch` (parallel large-scale changes), `/debug` (troubleshoot via debug log), `/loop` (repeated prompt execution), and `/claude-api` (API reference).

---

## Memory

Without understanding memory, you don't know how Claude retains context between sessions. You might wonder why it remembers a correction you made last week, or where those learned preferences actually live. Two systems handle this: CLAUDE.md (your explicit instructions) and auto memory (Claude's own notes).

### Auto memory

Claude writes notes for itself based on corrections you make and preferences it observes. If you tell Claude "always use `const` instead of `let` in this project," it remembers that for next time. This is enabled by default - you don't configure it, and it's separate from your CLAUDE.md files.

The difference: CLAUDE.md is what you tell Claude. Auto memory is what Claude tells itself.

### MEMORY.md

The entrypoint for auto memory is `MEMORY.md`. Claude creates and maintains this file automatically. The first 200 lines load at the start of every session - this is the auto-loaded limit for MEMORY.md specifically, not for CLAUDE.md files (which load in full regardless of length).

### Topic files

When Claude accumulates enough notes on a subject, it creates separate `.md` files alongside MEMORY.md - things like `debugging.md`, `api-conventions.md`, or whatever topics emerge from your work. These are referenced from MEMORY.md and loaded on demand.

### Storage location

Auto memory lives in your Claude directory, organized by project:

```
~/.claude/projects/<project-path-encoded>/memory/
├── MEMORY.md
├── debugging.md
└── api-conventions.md
```

The `<project-path-encoded>` is derived from your git repo's absolute path. For this repo, it's `-Users-stuart-Personal-project-claude-setup`. You can browse these files directly - they're plain markdown.

### The /memory command

Type `/memory` in Claude Code to see all loaded CLAUDE.md and rules files, toggle auto memory on or off, and open the memory folder. See the [official docs](https://code.claude.com/docs/en/memory) for the full reference.

### Subagent memory

Agents can maintain their own persistent memory using the `memory` frontmatter field. See the memory field in [Agents frontmatter](../agents/README.md#frontmatter-fields) for how subagents store their own notes. Three scopes are available:

| Scope | Location | Use when |
|-------|----------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not in VCS |

### CLAUDE.md vs auto memory

Use CLAUDE.md for explicit instructions you want every session - "use tabs," "no console.log," "always write tests first." Let auto memory handle learned patterns and corrections - things Claude picks up from how you work. If auto memory records something wrong, edit `MEMORY.md` directly. It's your file.

For the full auto memory reference: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)

---

## Files in this folder

How to use this folder in Claude:

1. Copy `skills/` to `~/.claude/skills/`
2. Run `/` in Claude Code to see invocable skills
3. Keep each skill's `SKILL.md` focused, with frontmatter that matches invocation intent

| File | What it does |
|------|--------------|
| `block-journey/SKILL.md` | Discovers block/component files, traces editorial and front-end user journeys, writes journey document to `.planning/journeys/`. |
| `brainstorm/SKILL.md` | Structured discovery workflow: context exploration, one-at-a-time interview, approach proposals, discovery brief. |
| `debug-wp/SKILL.md` | Structured WordPress debugging interview and ranked remediation workflow. |
| `figma/SKILL.md` | Figma MCP workflow for extracting design context/screenshots/variables before coding. |
| `multi-review/SKILL.md` | Parallel code review orchestrator: spawns maintainability, performance, and security agents simultaneously. |
| `playwright/SKILL.md` | Playwright MCP workflow for snapshot-first interaction, form automation, and visual/debug checks. |
| `qa-check/SKILL.md` | Multi-stack QA audit workflow (WCAG 2.2 AA accessibility, performance, code quality). Runs in forked Explore context. |
| `review-memory/SKILL.md` | Guided memory cleanup: categorise entries as Promote/Keep/Remove, check for duplicates, update review timestamp. |
| `test-plan/SKILL.md` | Two-mode skill: generate user-facing test checklists from git diff, or execute them via Playwright. |
| `vibe-user/SKILL.md` | Browser-based UX testing as a real user. Explores app with no source code access, reports findings per page. |

`README.md` in this folder is the skill system guide you're reading now.

---

## Continue Reading

[Previous: Agents](../agents/README.md)

## Quick Links

- [Home](../index.md)
- [Start Here](../docs/start-here.md)
- [Core Guide](../docs/core-guide.md)
- [Governance Workflow](../docs/governance-workflow.md)
- [Rules](../rules/README.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)


