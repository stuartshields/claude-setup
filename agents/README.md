---
title: Agents
---
<!-- Last updated: 2026-03-26T14:00+11:00 -->

## Agents

> **TL;DR:** 18 custom agents across four roles:
>
> - **Read-only auditors** (12) - `code-reviewer`, `a11y`, `security`, `perf`, `simplify`, `ui-review`, `migration-reviewer`, `cleanup`, `feasibility-check`, `wp-reviewer`, `wp-perf`, `wp-security`. Structurally blocked from writing files.
> - **Builders** (4) - `backend-builder`, `frontend-builder`, `test-writer`, `wp`. Run in worktrees for parallel execution.
> - **Researchers** (1) - `architect`. Deep analysis, produces decision documents, never writes implementation code.
> - **Fast agents** (1) - `quick-edit`. Haiku model, 50-line limit, escalates to sonnet when too complex.

### The problem

Some tasks need a different personality entirely. A code reviewer that can only read, never write. A security auditor on a cheaper model. A WordPress specialist with PHP-specific tools. Rules can't change what tools are available or what model runs. Agents can.

### How I use agents

**Structural restrictions beat prompt instructions.** The code reviewer's frontmatter lists four tools: `Read, Grep, Glob, Bash`. No `Write`, no `Edit`. A rule saying "never modify code when reviewing" works most of the time. Removing the tools makes it structurally impossible. Two hook guards (`agent-guard-write-block.sh`, `agent-guard-readonly.sh`) add a second layer for agents that need Bash but shouldn't run destructive commands.

**Four roles, four patterns:**

*Read-only auditors* are the most common. 12 of 18 agents are read-only. They analyse and report - they never change code. This is the pattern for code review, security audit, accessibility check, performance review, and feasibility checking. The `feasibility-check` agent is worth calling out: it extracts what a spec assumes about the codebase (fields, endpoints, dependencies), greps for each assumption, and reports CONFIRMED / NOT FOUND / CONTRADICTED. Run it before building to catch spec problems early.

*Builders* run in worktrees with `maxTurns: 30`. All four escalate after 2 failed approaches instead of looping. Launch multiple builders in parallel with `isolation: "worktree"` when changes don't overlap.

*The architect* has `memory: user` so it accumulates knowledge across projects. It researches approaches and produces structured decision documents - never implementation code. Useful for technology choices and migration strategies.

*Quick-edit* runs on haiku with a 50-line limit enforced by `agent-guard-max-lines.sh`. For typo fixes, variable renames, config tweaks. Escalates to sonnet if the task is too complex.

**Model routing saves cost.** Not every task needs opus. Code review runs on sonnet. Quick edits run on haiku. Security audits run on opus because the consequences of missing something are high. Match the model to the stakes.

### When to use an agent vs a skill vs a rule

- **Agent** = different capability set. Different model, different tools, different permissions. The task needs isolation or restriction.
- **Skill** = reusable workflow in the main context. Same model, same tools. The task needs structured steps, not a different personality.
- **Rule** = always-on constraint. Not a task at all - a behavioural guardrail.

Rule of thumb: if it's a style preference or a guardrail, it's a rule. If it's a structured procedure, it's a skill. If it's a distinct task needing different capabilities, it's an agent.

### What's in here

**Read-only auditors:** `a11y`, `code-reviewer`, `cleanup`, `feasibility-check`, `migration-reviewer`, `perf`, `security`, `simplify`, `ui-review`, `wp-perf`, `wp-reviewer`, `wp-security`

**Builders:** `backend-builder`, `frontend-builder`, `test-writer`, `wp`

**Research:** `architect`

**Fast:** `quick-edit`

`references/` contains supporting reference docs used by WordPress-specialized agents.

---

[Previous: Hooks](../hooks/README.md) | [Next: Skills & Memory](../skills/README.md)
