---
name: clean-worktrees
description: Remove stale agent worktree directories and their orphaned branches. Run after parallel agent work or when .claude/worktrees/ accumulates cruft.
argument-hint: [--dry-run to preview without deleting]
---

# Clean Stale Agent Worktrees

Remove worktree directories and orphaned `worktree-agent-*` branches left behind by agent isolation mode.

Based on community patterns from [claude-codex-settings](https://github.com/fcakyon/claude-codex-settings/blob/main/plugins/github-dev/commands/clean-gone-branches.md) and [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/examples/commands/git-worktree-remove.md), adapted for Claude Code's agent worktree pattern.

Related upstream issue: [anthropics/claude-code#26725](https://github.com/anthropics/claude-code/issues/26725)

## Process

### 1. Inventory

Run these commands and report counts:

```bash
# Count worktree directories
WORKTREE_DIRS=$(find .claude/worktrees -maxdepth 1 -type d -name 'agent-*' 2>/dev/null | wc -l | tr -d ' ')

# Count git worktree registrations (excluding main)
GIT_WORKTREES=$(git worktree list 2>/dev/null | grep 'worktree-agent-' | wc -l | tr -d ' ')

# Count orphaned branches
ORPHANED_BRANCHES=$(git branch --list 'worktree-agent-*' 2>/dev/null | wc -l | tr -d ' ')
```

Report:
```
## Worktree Inventory

- Worktree directories: {WORKTREE_DIRS}
- Git worktree registrations: {GIT_WORKTREES}
- Orphaned branches: {ORPHANED_BRANCHES}
```

If all counts are 0: report "No stale worktrees found." and stop.

### 2. Dry Run Check

If `$ARGUMENTS` contains `--dry-run`: report the inventory and stop. Do not delete anything.

### 3. Clean Up

Run in this order:

```bash
# Prune stale git worktree references
git worktree prune

# Remove registered worktrees that match agent pattern
git worktree list | grep 'worktree-agent-' | awk '{print $1}' | while read wt; do
  git worktree remove --force "$wt"
done

# Delete orphaned branches (allowed by block-git-commit.sh for worktree-agent-* only)
git branch --list 'worktree-agent-*' | xargs git branch -D
```

### 4. Report

```
## Cleanup Complete

- Removed {N} worktree directories
- Deleted {N} orphaned branches
- Pruned git worktree references
```
