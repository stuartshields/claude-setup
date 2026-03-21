<!-- Last updated: 2026-03-21 -->

# Staleness Check

Files in `~/.claude/` (rules, hooks, agents, skills, CLAUDE.md) and project-level equivalents contain guidance that may become outdated as AI models and tooling evolve. Each tracked file has a `<!-- Last updated: YYYY-MM-DD -->` comment.

## On Session Start
- Compare last-updated dates against the current date for files relevant to the current task.
- If any file is **more than 30 days old**, flag it to the user before making changes: "This file hasn't been reviewed since [date] — AI best practices may have changed. Want me to check for updates before proceeding?"

## On File Edit
- When you edit any file that has a last-updated comment, **update the date to today**.

## Applies To
- `~/.claude/CLAUDE.md`
- `~/.claude/rules/*.md`
- `~/.claude/agents/*.md`
- `~/.claude/skills/*/SKILL.md`
- Project-level `rules/`, `skills/`, `CLAUDE.md`, and documentation files that have the comment
