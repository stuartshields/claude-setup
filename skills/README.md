---
title: Skills & Memory
---
<!-- Last updated: 2026-03-26T14:00+11:00 -->

## Skills

> **TL;DR:** 11 skills across 2 categories:
>
> - **Workflow skills** - `/brainstorm`, `/multi-review`, `/review-memory`, `/test-plan`, `/vibe-user`. Structure how you work with Claude - discovery, review, testing, memory management.
> - **Tool skills** - `/block-journey`, `/debug-rules`, `/debug-wp`, `/figma`, `/playwright`, `/qa-check`. Wrap specific tools or integrations with structured methodology.

### The problem

You find yourself writing the same instructions more than twice. "Review this code for maintainability, performance, and security - spawn three agents in parallel." "Open the app in a browser and explore as a user with no prior knowledge." "Generate a test plan from the git diff, focused on what a user does, not what the code does."

Skills capture the reasoning once. You invoke it, the skill runs the procedure, you come back to the result.

### How I use skills

**Workflow skills structure how you interact with Claude.** These are the ones that changed how I work:

`/brainstorm` stops Claude from jumping to implementation. It interviews you one question at a time, proposes approaches with trade-offs, and writes a discovery brief. The interview is the point - it forces both you and Claude to understand the problem before committing to a solution.

`/multi-review` spawns three review agents in parallel (maintainability, performance, security). The consolidated report notes conflicts when agents disagree - "perf says inline this, maintainability says extract it" - so you make the trade-off, not the agent.

`/vibe-user` opens your app in a browser and explores it as a real user. It blocks source code reading - the whole point is a fresh perspective. You built it, so you know too much. This skill surfaces problems you'd never notice.

`/test-plan` generates user-facing test checklists from git diff ("click submit and verify the success message") not code-facing ones ("POST /api/form returns 200"). Execute mode runs the plan via Playwright.

`/review-memory` is the manual counterpart to the memory-review hook. Categorises accumulated memories as promote/keep/remove, checks for duplicates, and runs a post-promote contradiction check against existing rules.

Several of these were inspired by patterns from [Ivan Kristianto](https://github.com/ivankristianto) - the parallel code review, the "Vibe User" concept, test plan generation, and the idea that session learnings need a deliberate review step.

**Tool skills wrap integrations.** `/figma` structures the Figma MCP workflow. `/playwright` structures browser automation. `/debug-wp` runs a structured WordPress debugging interview. `/qa-check` runs a multi-stack quality audit in a forked context so its verbose output doesn't pollute your conversation.

**Effort routing.** Skills set their own effort level so heavy analysis runs at `high` effort even if the session default is lower. `/multi-review`, `/qa-check`, and `/brainstorm` run at high. `/debug-rules` runs at low - it's a mechanical log comparison. This saves tokens on simple skills without compromising quality on complex ones.

### When to use a skill vs a rule vs an agent

- **Skill** = reusable procedure. "How to do X." A checklist, a workflow, a methodology. Runs in the main context.
- **Rule** = behavioural constraint. "Always do Y." A guardrail that applies every session.
- **Agent** = different capability set. Different model, tools, or permissions. The task needs isolation.

If you're writing the same instructions more than twice, it's a skill. If it's a constraint you want enforced silently, it's a rule. If the task needs a restricted or specialised environment, it's an agent.

### What's in here

**Workflow:** `brainstorm`, `multi-review`, `review-memory`, `test-plan`, `vibe-user`

**Tool:** `block-journey`, `debug-rules`, `debug-wp`, `figma`, `playwright`, `qa-check`

---

## Memory

Two systems handle session-to-session learning: CLAUDE.md (what you tell Claude) and auto memory (what Claude tells itself).

### The key distinction

**CLAUDE.md** is for explicit instructions you want every session - "use tabs", "no console.log", "always write tests first." You write it, you version-control it, you review changes.

**Auto memory** is for learned patterns and corrections Claude picks up from how you work. If you tell Claude "always use `const` instead of `let` in this project," it remembers that. This is enabled by default. The first 200 lines of `MEMORY.md` load at the start of every session - that's the auto-loaded limit, so noise has a real cost.

### Memory as a lifecycle

Most approaches to session-to-session learning either capture everything automatically (noise accumulates) or rely on manual reflection you forget to do. This setup treats memory as a lifecycle:

1. **Capture** - auto-memory records corrections and patterns during work
2. **Prompt** - the `memory-review-prompt.sh` hook fires at natural breakpoints: session start when 3+ new files have accumulated, context dropping to 30%, and wrap-up phrases
3. **Review** - `/review-memory` categorises entries as promote/keep/remove, checks for duplicates, and runs a contradiction check against existing rules
4. **Promote** - permanent learnings get moved to CLAUDE.md or rule files where they're explicit and version-controlled

The memory directory stays lean. Stale entries get removed. The 200-line limit means every slot matters.
