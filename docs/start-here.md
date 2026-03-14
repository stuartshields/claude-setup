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

## Recommended Reading Path

1. [Core Guide](core-guide.md)
2. [Governance Workflow](governance-workflow.md)
3. [Hooks README](../hooks/README.md)
4. [Agents README](../agents/README.md)
5. [Skills README](../skills/README.md)
