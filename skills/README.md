---
layout: default
title: Skills & Memory
---

## Skills

Skills are reusable task templates with step-by-step instructions. They differ from agents: agents are delegatable specialists (a different "person" doing the work), skills are more like checklists - structured guidance for a task that the main Claude session follows directly.

This repo includes four skills:

- `debug-wp` - WordPress debugging workflow: isolate, trace, reproduce, fix
- `figma` - Figma MCP workflow for design extraction before implementation
- `playwright` - Playwright MCP browser automation and verification workflow
- `qa-check` - Quality assurance checklist for before-you-ship reviews

Directory structure:

```
skills/
  debug-wp/
    SKILL.md    ← the step-by-step instructions
  figma/
    SKILL.md
  playwright/
    SKILL.md
  qa-check/
    SKILL.md
```

Skills live at `~/.claude/skills/` globally, or `.claude/skills/` for project-specific ones.

### Skill frontmatter

Skills support 10 frontmatter fields:

| Field | What it does |
|-------|-------------|
| `name` | Display name (defaults to directory name). Lowercase, numbers, hyphens, max 64 chars. |
| `description` | What the skill does and when to use it. |
| `argument-hint` | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | Set to `true` to prevent Claude from auto-loading this skill. |
| `user-invocable` | Set to `false` to hide from the `/` menu. |
| `allowed-tools` | Tools Claude can use without permission when skill is active. |
| `model` | Model to use when skill is active. |
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

## Procedure
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
| `debug-wp/SKILL.md` | Structured WordPress debugging interview and ranked remediation workflow. |
| `figma/SKILL.md` | Figma MCP workflow for extracting design context/screenshots/variables before coding. |
| `playwright/SKILL.md` | Playwright MCP workflow for snapshot-first interaction, form automation, and visual/debug checks. |
| `qa-check/SKILL.md` | Multi-stack QA audit workflow (accessibility, performance, code quality). |

`README.md` in this folder is the skill system guide you're reading now.

---

## Continue Reading

- Runtime setup and instruction loading: [Core Guide](../docs/core-guide.md)
- Specialist subagents: [Agents README](../agents/README.md)
- Hook lifecycle automation: [Hooks README](../hooks/README.md)
- Governance checklist: [Governance Review Template](../docs/governance-review-template.md)


