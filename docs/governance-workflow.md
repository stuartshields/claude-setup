---
title: Governance Workflow
---
<!-- Last updated: 2026-03-21 -->

# Governance Workflow

> **TL;DR:** Review your setup on a schedule - weekly quick checks (10 min), monthly full reviews (45 min). Seven controls cover config drift, docs parity, permissions, plugins, stop-path checks, hook observability, and memory hygiene. Use the review template to score findings by impact/effort and fix highest-score items first.

This is the operational workflow for keeping your Claude setup healthy over time. It covers both your global configuration (`~/.claude/`) and per-project overrides (`.claude/` at the project root). Without periodic review, rules go stale, hooks accumulate without anyone checking if they still fire correctly, and the gap between what your setup says and what it does widens quietly.

## How It Works

1. Run reviews on a fixed cadence.
2. Collect evidence before making changes - failures, noisy behaviour, repeated overrides, drift between global and project configs.
3. Score findings by impact and effort: `Score = Impact / Effort`. Impact 1-5 (low to high), Effort 1-5 (easy to hard). Fix high-score items first.
4. Apply updates in the correct layer:
   - Policy and behaviour rules go in `~/.claude/CLAUDE.md` and `~/.claude/rules/` (global) or project-level `CLAUDE.md` (project-specific)
   - Runtime behaviour and automation go in `~/.claude/settings.json` (global) or `.claude/settings.json` (project-specific)
   - Hooks go in `~/.claude/hooks/` (global) or registered per-project in `.claude/settings.json`
5. Validate changes across at least two different project types.
6. Record outcomes and schedule the next cycle.

## Cadence

- **Weekly** (10-15 min): quick drift and runtime checks. Has anything broken since last week? Any hooks firing when they shouldn't?
- **Monthly** (45-60 min): full control-by-control review using the template below.
- **Event-triggered** (same day): after Claude updates, hook rewiring, permission model changes, or major behaviour regressions.
- **Quarterly**: broader policy refresh across `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, and core rule files.

## What You Review

The review template (`~/.claude/docs/governance-review-template.md`) is a structured checklist with seven controls. Each control has pass/fail gates, an evidence section, and a scoring block. Here's what each one covers and why it matters.

### Control 1: Config Drift

Catches silent divergence between your global setup (`~/.claude/`) and project-level overrides (`.claude/`). Over time, project configs accumulate one-off changes that contradict global policy, or global updates land without propagating to projects that depend on specific behaviour.

What to check:
- Global `~/.claude/CLAUDE.md` version and content against project `CLAUDE.md` files where alignment is expected
- `~/.claude/settings.json` permissions and hooks vs `.claude/settings.json` overrides in active projects
- Rule files in `~/.claude/rules/` match the behaviour you're seeing in sessions

### Control 2: Docs Parity

Keeps documentation in sync after restructures. When you rename a hook or move a rule file, the README that references it doesn't update itself.

What to check:
- Folder READMEs in `~/.claude/hooks/`, `~/.claude/agents/`, `~/.claude/skills/` reflect current file structure
- Internal cross-references resolve (no dead links to renamed or removed files)
- Ownership defined for who updates docs when structure changes

### Control 3: Explicit Mode Policy

Removes ambiguity in runtime behaviour. If someone asks "what permission mode does this project use?", there should be a documented answer, not a shrug.

What to check:
- Written mode policy exists in `~/.claude/CLAUDE.md` (global default) and per-project `CLAUDE.md` where overridden
- Current `~/.claude/settings.json` and `.claude/settings.json` match the policy
- Rollback steps documented if mode changes cause regressions

### Control 4: Plugin Budget

Controls token and latency overhead from plugin sprawl. Each MCP server and plugin adds tool definitions to your context window even when unused. Plugins enabled globally in `~/.claude/settings.json` load everywhere unless disabled per-project.

What to check:
- Maximum plugin budget documented with rationale
- Each enabled plugin has an owner, use-case, and keep/remove decision
- Per-project `.claude/settings.json` disables plugins not needed for that project (e.g., Figma on backend-only projects)
- Review cadence defined and current cycle logged

### Control 5: Stop-Path Governance

Ensures stop-time checks remain complete and intentional. The `stop-dispatcher.sh` in `~/.claude/hooks/` runs multiple checks when Claude finishes responding - if one gets disabled or bypassed, incomplete work slips through.

What to check:
- Dispatcher targets in `~/.claude/hooks/stop-dispatcher.sh` documented and mapped to failure conditions
- Disabled or bypassed checks have explicit justification
- Manual validation process exists for emergency bypass

### Control 6: Hook Observability

Makes hook behaviour measurable so regressions are visible before they affect your workflow. A hook that silently fails 80% of the time looks identical to one that works - until you check the numbers.

What to check:
- Observability summary exists for hook outcomes (allow, block, warn, error) by hook name and event
- Both global hooks (`~/.claude/hooks/`) and project hooks (`.claude/settings.json`) are covered
- Current review includes baseline counts and trend comparison vs prior cycle
- High-noise or high-failure hooks have an owner and remediation plan

### Control 7: Memory Governance

Keeps persistent memory accurate, minimal, and aligned with current protocol. Auto memory accumulates over time. Stale entries teach Claude outdated patterns.

The `memory-review-prompt.sh` hook automates the review prompt - it fires on GSD phase completion, session start with 3+ new memory files, or when context drops to 30% remaining. Run `/review-memory` for guided cleanup: it categorises entries as Promote (move to CLAUDE.md/rules/skills), Keep, or Remove, and checks for duplicates before promoting.

What to check:
- Memory entries in `~/.claude/projects/*/memory/MEMORY.md` reviewed for stale or duplicated guidance
- Session-only notes not promoted to persistent memory without recurring value
- Agent memory (`~/.claude/agent-memory/`) reviewed if subagents use persistent memory
- Memory changes include owner, rationale, and review date
- MEMORY.md stays under 200 lines (the auto-loaded limit)

## Running A Review

The full template lives at `~/.claude/docs/governance-review-template.md`. It's a markdown checklist designed for Claude to use during audits - fill in the evidence sections, assign scores, and mark pass/fail for each control.

A typical monthly review:

1. Open the template (or copy it for this cycle's record)
2. Fill in review metadata: date, reviewer, scope, protocol versions
3. Walk through each control's pass/fail gates
4. Score findings: `Impact / Effort`
5. Prioritise: fix anything scoring above 2.0 before the next cycle
6. Record high/medium/low priority actions in the summary section
7. Sign off and set the next review date

For weekly checks, you don't need the full template. Just scan controls 1 (drift), 5 (stop-path), and 4 (plugin budget) - those are the ones most likely to shift between full reviews.

## Continue Reading

[Previous: Core Guide](core-guide.md) | [Next: Rules](../rules/README.md)

## Quick Links

- [Home](../index.md)
- [Start Here](start-here.md)
- [Core Guide](core-guide.md)
- [Rules](../rules/README.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)
- [Skills & Memory](../skills/README.md)
