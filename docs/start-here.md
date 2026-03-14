---
title: Start Here
---

# Start Here

If you are new to this repo, read this first.

This repository is a curated mirror of my global Claude setup in `~/.claude/`.

Use this page as your entry point, then follow the reading path below.

## What This Repo Is

- Global rules, hooks, agents, skills, and settings used across projects.
- Governance docs for ongoing review and drift control.
- Documentation-first mirror of the setup, not a dump of local runtime state.

## What This Repo Is Not

- A project-local `.claude` replacement.
- A place for generated logs or temporary machine-specific files.
- A full snapshot of everything in `~/.claude` at all times.

## Setup In 4 Steps

1. Clone the repo: `git clone https://github.com/stuartshields/claude-setup.git`
2. Copy the contents to your global Claude directory: `cp -r claude-setup/. ~/.claude/`
3. Restart Claude Code.
4. Open any project and confirm your global rules/hooks/agents are active.

## Continue Reading

[Next: Core Guide](core-guide.md)

## Quick Links

- [Home](../index.md)
- [Core Guide](core-guide.md)
- [Governance Workflow](governance-workflow.md)
- [Rules](../rules/README.md)
- [Hooks](../hooks/README.md)
- [Agents](../agents/README.md)
- [Skills & Memory](../skills/README.md)
