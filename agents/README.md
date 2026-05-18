---
title: Agents
---
<!-- Last updated: 2026-05-15T15:00+10:00 -->

## Agents

> **TL;DR:** 27 custom agents across six roles:
>
> - **Read-only auditors** (15) - `code-reviewer`, `a11y`, `security`, `perf`, `simplify`, `ui-review`, `migration-reviewer`, `cleanup`, `feasibility-check`, `api-contract-reviewer`, `history-reviewer`, `test-coverage-reviewer`, `wp-reviewer`, `wp-perf`, `wp-security`. Structurally blocked from writing files.
> - **Builders** (5) - `backend-builder`, `frontend-builder`, `test-writer`, `seed-generator`, `wp`. Run in worktrees for parallel execution.
> - **Researchers** (2) - `architect`, `claude-architect`. Deep analysis and decision documents, never write implementation code.
> - **Orchestrators** (3) - `architect-reviewer`, `git-agent`, `pr-writer`. Coordinate other agents or handle operational workflows.
> - **Fast agents** (1) - `quick-edit`. Haiku model, 50-line limit, escalates to sonnet when too complex.
> - **QA** (1) - `browser-qa-agent`. Chrome-integrated interactive testing.

### The problem

Some tasks need a different personality entirely. A code reviewer that can only read, never write. A security auditor on a cheaper model. A WordPress specialist with PHP-specific tools. Rules can't change what tools are available or what model runs. Agents can.

### How I use agents

**Structural restrictions beat prompt instructions.** The code reviewer's frontmatter lists specific tools - no `Write`, no `Edit`. A rule saying "never modify code when reviewing" works most of the time. Removing the tools makes it structurally impossible. Two hook guards (`agent-guard-write-block.sh`, `agent-guard-readonly.sh`) add a second layer for agents that need Bash but shouldn't run destructive commands.

**Five roles, five patterns:**

*Read-only auditors* are the most common. 15 of 27 agents are read-only. They analyse and report - they never change code. This is the pattern for code review, security audit, accessibility check, performance review, and feasibility checking. The `feasibility-check` agent extracts what a spec assumes about the codebase (fields, endpoints, dependencies), greps for each assumption, and reports CONFIRMED / NOT FOUND / CONTRADICTED. Run it before building to catch spec problems early. Three more specialised reviewers split out what `code-reviewer` doesn't: `api-contract-reviewer` checks REST/GraphQL/RPC contracts for breaking changes, `history-reviewer` uses git blame and log to catch accidentally reverted fixes, and `test-coverage-reviewer` finds untested branches and tests that don't actually assert anything.

*Builders* run in worktrees with `maxTurns: 30`. All escalate after 2 failed approaches instead of looping. Launch multiple builders in parallel with `isolation: "worktree"` when changes don't overlap. The `seed-generator` analyses your database schema and writes realistic test data.

*Researchers* produce documents, not code. The `architect` researches approaches and produces structured decision documents for technology choices and migration strategies. The `claude-architect` is a meta-agent - it helps design and review Claude Code extensions themselves (agents, skills, hooks, commands).

*Orchestrators* coordinate workflows. The `architect-reviewer` is a supervisor that spawns auditor agents via Task(), consolidates findings, delegates fixes, and re-audits until quality standards are met. The `git-agent` handles git operations with a 3-tier safety system (read-only/safe-write/destructive). The `pr-writer` generates structured PR descriptions from git diff analysis.

*Quick-edit* runs on haiku with a 50-line limit enforced by `agent-guard-max-lines.sh`. For typo fixes, variable renames, config tweaks. Escalates to sonnet if the task is too complex.

*Browser QA* uses Chrome integration to navigate running web apps, click elements, fill forms, read console errors, and take screenshots. Requires Chrome integration to be active.

**Model routing saves cost.** Not every task needs opus. Code review runs on sonnet. Quick edits run on haiku. Security audits run on opus because the consequences of missing something are high. Match the model to the stakes.

### When to use an agent vs a skill vs a rule

- **Agent** = different capability set. Different model, different tools, different permissions. The task needs isolation or restriction.
- **Skill** = reusable workflow in the main context. Same model, same tools. The task needs structured steps, not a different personality.
- **Rule** = always-on constraint. Not a task at all - a behavioural guardrail.

Rule of thumb: if it's a style preference or a guardrail, it's a rule. If it's a structured procedure, it's a skill. If it's a distinct task needing different capabilities, it's an agent.

### What's in here

**Read-only auditors:** `a11y`, `api-contract-reviewer`, `code-reviewer`, `cleanup`, `feasibility-check`, `history-reviewer`, `migration-reviewer`, `perf`, `security`, `simplify`, `test-coverage-reviewer`, `ui-review`, `wp-perf`, `wp-reviewer`, `wp-security`

**Builders:** `backend-builder`, `frontend-builder`, `seed-generator`, `test-writer`, `wp`

**Research:** `architect`, `claude-architect`

**Orchestrators:** `architect-reviewer`, `git-agent`, `pr-writer`

**QA:** `browser-qa-agent`

**Fast:** `quick-edit`

`references/` contains supporting reference docs used by WordPress-specialized agents.

### Community sources

Several agents were adopted from community repos:

- `git-agent` - [0xdarkmatter/claude-mods](https://github.com/0xdarkmatter/claude-mods)
- `claude-architect` - [0xdarkmatter/claude-mods](https://github.com/0xdarkmatter/claude-mods)
- `code-reviewer` (enhanced) - [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- `perf` (enhanced) - [undeadlist/claude-code-agents](https://github.com/undeadlist/claude-code-agents)
- `architect-reviewer` - [undeadlist/claude-code-agents](https://github.com/undeadlist/claude-code-agents)
- `browser-qa-agent` - [undeadlist/claude-code-agents](https://github.com/undeadlist/claude-code-agents)
- `pr-writer` - [undeadlist/claude-code-agents](https://github.com/undeadlist/claude-code-agents)
- `seed-generator` - [undeadlist/claude-code-agents](https://github.com/undeadlist/claude-code-agents)

---

[Previous: Hooks](../hooks/README.md) | [Next: Skills & Memory](../skills/README.md)
