---
layout: default
title: Claude Code Setup
---
<!-- Last updated: 2026-03-21 -->

# Claude Code Setup

Here's how I set up my Claude Code. This repo IS the configuration - the files here belong in `~/.claude/`. When you clone this and copy the contents to `~/.claude/`, you get persistent instructions, automated quality gates, and specialised subagents that apply across every project you work on.

If you're searching for a practical Claude Code setup with global rules, hooks, agents, and a repeatable governance workflow, this is exactly what this repo is for.

The structure maps directly to `~/.claude/`: `rules/` → `~/.claude/rules/`, `agents/` → `~/.claude/agents/`, `hooks/` → `~/.claude/hooks/`, `skills/` → `~/.claude/skills/`, `settings.json` → `~/.claude/settings.json`. None of these directories belong in a project root - they're user-global configuration.

## Read Online

- GitHub Pages docs: https://stuartshields.github.io/claude-setup/
- Repo on GitHub: https://github.com/stuartshields/claude-setup

## Changelog

Release history is maintained in [CHANGELOG.md](CHANGELOG.md).

## Contributing

If you want to suggest changes, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Who This Is For

- You use Claude Code regularly and want consistent behaviour across projects.
- You want guardrails (quality, security, workflow discipline) baked in by default.
- You want a setup you can audit and improve over time, not just a one-off prompt file.

---

## Table of Contents

- [Read Online](#read-online)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)
- [Who This Is For](#who-this-is-for)
- [Quick Start](#quick-start)
- [Recommended Reading Path](#recommended-reading-path)
- [Full Documentation](#full-documentation)
	- [Start Here](docs/start-here.md)
	- [Core Guide](docs/core-guide.md)
	- [Governance Review Template](docs/governance-review-template.md)
	- [Governance Audits](docs/governance/audits/)
	- [Governance Evidence](docs/governance/evidence/)
	- [Hooks](hooks/README.md)
	- [Agents](agents/README.md)
	- [Skills and Memory](skills/README.md)

---

## Quick Start

Want to try this now?

1. Clone this repo: `git clone https://github.com/stuartshields/claude-setup.git`
2. Copy the contents to your Claude directory: `cp -r claude-setup/. ~/.claude/`
3. Restart Claude Code (quit and reopen)
4. Open any project - your global rules, hooks, and agents are now active

That's it. Claude Code automatically loads `~/.claude/CLAUDE.md` at session start, picks up rules from `~/.claude/rules/`, runs hooks from `~/.claude/hooks/`, and makes agents from `~/.claude/agents/` available.

Read the rest of this to understand what each part does and why - so you can adapt it to your own workflow instead of just running mine.

## Recommended Reading Path

1. [Start Here](docs/start-here.md)
2. [Core Concepts and Workflow: Core Guide](docs/core-guide.md)
3. [Governance Process: Governance Workflow](docs/governance-workflow.md)
4. [Automation Layer: Hooks](hooks/README.md)
5. [Agent Roles: Agents](agents/README.md)
6. [Skills and Memory Model: Skills and Memory](skills/README.md)

---

The governance template gives you a repeatable audit workflow for your global Claude setup: same controls each cycle, pass/fail gates, evidence capture, and simple prioritization scoring so drift and weak spots are visible early.

## Governance Workflow

Use [Governance Workflow](docs/governance-workflow.md) as the operational guide and [Governance Review Template](docs/governance-review-template.md) for control-by-control review evidence.

Mirror-sync note: copy only intentionally changed files (for example `docs/governance/**`, `hooks/hook-observability-summary.sh`, `README.md`) and do not bring over unrelated folders.
