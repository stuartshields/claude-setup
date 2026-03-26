---
title: Core Guide
---
<!-- Last updated: 2026-03-26T14:00+11:00 -->

> **TL;DR:** CLAUDE.md gives Claude standing instructions. Rules add persistent constraints (7 always-loaded, 8 scoped). Hooks enforce those constraints mechanically. Agents delegate to specialists. Skills capture reusable workflows. Keep always-on instructions under ~70 bullet points or Claude starts ignoring them.

Each component type has its own README: [Rules](../rules/README.md), [Hooks](../hooks/README.md), [Agents](../agents/README.md), [Skills](../skills/README.md). This guide explains how the pieces fit together.

## CLAUDE.md

Without a CLAUDE.md, Claude loses your explicit standing instructions between sessions. Auto memory retains some learned patterns, but it doesn't replace clear rules like "use tabs not spaces" or "always write tests first."

A CLAUDE.md file loads automatically at the start of every session. Whatever you put in it, Claude reads before responding to anything. The CLAUDE.md in this repo is my global one - open it to see the actual file.

The section I rely on most is the mandatory workflow:

```markdown
## 1. MANDATORY WORKFLOW
- **Verify**: After implementing, run the project's build/test/lint command.
  If it fails, diagnose and fix before moving on.
- **On Compaction**: Always preserve in the summary: all modified file paths,
  the current task, test commands and results, key decisions.
- **CLAUDE.md is the Source of Truth**: Before making changes, read the
  project's CLAUDE.md. If your changes diverge, ask first.
- **Complexity Routing**: 6+ files → structured planning. 3-5 files → plan
  in .planning/PLAN.md. Under 3 → just do it.
```

Without these rules, Claude frequently writes speculative code, skips verification, and adds "helpful" extras you didn't ask for. With them, it behaves predictably.

**Tip:** Run `/init` in any project to generate a starting CLAUDE.md based on your project structure.

### CLAUDE.local.md

A second file worth knowing: `CLAUDE.local.md`. Lives alongside `CLAUDE.md` but is gitignored. Use it for personal notes that shouldn't be committed - reminders about a local dev setup, project context specific to your machine.

### Loading order

Claude Code loads CLAUDE.md files from multiple locations. More specific locations take precedence:

1. **Managed policy** (system-managed, can't be overridden)
2. **Local** (`CLAUDE.local.md`, gitignored)
3. **Project** (`./CLAUDE.md` or `./.claude/CLAUDE.md`)
4. **User/global** (`~/.claude/CLAUDE.md` - this repo)

Array settings like `permissions.allow` merge across scopes rather than override. Project-level allow rules stack on top of global ones.

This repo demonstrates the user-global scope. Individual projects layer on top with their own CLAUDE.md files.

---

## How the pieces fit together

The four layers build on each other:

**CLAUDE.md** is the foundation. Standing instructions that load every session. This is where workflow rules, style defaults, and project conventions live. It's the minimum viable setup - everything else adds enforcement on top.

**Rules** extend CLAUDE.md with focused constraint files. Each file covers one concern (security, debugging, testing). Some load always, some load only when relevant files are in play. The instruction budget matters - more rules doesn't mean better behaviour. See [Rules](../rules/README.md) for the budget lesson.

**Hooks** enforce rules mechanically. A rule says "no console.log." A hook makes it impossible to write one. Hooks fire at lifecycle events (before tool calls, after tool calls, at session start/end, at stop). They can block actions, add context, or just observe. When a rule keeps getting ignored, convert it to a hook. See [Hooks](../hooks/README.md) for the three enforcement patterns.

**Agents** delegate to specialists. A code reviewer that can only read, never write. A security auditor on a cheaper model. A quick-edit agent on haiku with a 50-line limit. Agents have their own tools, model, and permissions - structurally different from asking the main session to "review this code." See [Agents](../agents/README.md) for the four roles.

**Skills** capture reusable workflows. Brainstorming interviews, parallel code reviews, user testing, memory management. When you find yourself writing the same instructions more than twice, it's a skill. See [Skills](../skills/README.md) for workflow vs tool skills.

### When to use what

This is the question most people get stuck on:

- **CLAUDE.md** - standing instructions, style defaults, workflow rules. The stuff that applies to every session.
- **Rule** - focused constraint for a specific concern. "Always parameterize SQL." "Handle the unhappy path." Loads automatically.
- **Hook** - mechanical enforcement of a constraint. The rule keeps getting ignored? Make it a hook. Also for lifecycle automation (session cleanup, compaction preservation, observability).
- **Agent** - specialist task needing a different model, tools, or permissions. Code review, security audit, quick edits.
- **Skill** - reusable multi-step procedure. Brainstorming, parallel review, test plan generation.

If it's a preference or guardrail, it's a rule. If it needs enforcement, it's a hook. If it's a procedure, it's a skill. If it needs isolation, it's an agent.

---

## Settings

The `settings.json` in this repo is a template. Copy it to `~/.claude/settings.json` - that's where Claude Code reads it.

Two things worth understanding about settings:

**Permissions** use allow/deny rules to control what Claude can read without asking. The deny rules prevent Claude from reading secrets (`.env`), dependency trees (`node_modules`), and build artifacts (`dist/`). The allow rules pre-approve commonly-needed config files so Claude doesn't prompt every time it reads `package.json`.

**Hook scoping in teams.** Hooks from all settings files merge - they don't override. If your global settings register a hook and a project's settings register another, both run. This matters when working in teams:

- `~/.claude/settings.json` - your personal hooks (notification sounds, personal preferences)
- `.claude/settings.json` - team hooks (quality gates, security checks). Checked into git.
- `.claude/settings.local.json` - personal project overrides. Gitignored.

Keep notification hooks personal. Reserve project settings for hooks the whole team needs. There's no way to disable a single global hook from a project file - only `"disableAllHooks": true`, which kills everything.

---

## Continue Reading

- [Rules](../rules/README.md) - the instruction budget problem and how scoping solves it
- [Hooks](../hooks/README.md) - enforcement patterns and the prose-to-hook conversion lesson
- [Agents](../agents/README.md) - specialist roles and when structural restrictions beat prompt instructions
- [Skills](../skills/README.md) - workflow skills, tool skills, and memory as a lifecycle
- [Governance Workflow](governance-workflow.md) - keeping your setup healthy over time
