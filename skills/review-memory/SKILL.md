---
name: review-memory
description: Review auto-memory for the current project. Shows accumulated learnings, identifies noise, and helps promote permanent patterns to CLAUDE.md, rules, or skills.
argument-hint: "[optional: 'clean' to auto-remove promoted entries]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Skill: review-memory

## When to Use

Run `/review-memory` when prompted by the memory review hook, or any time you want to audit what auto-memory has captured for this project. Use after completing a milestone, before starting new work, or when memory feels noisy.

Do NOT run this mid-task. Finish what you're working on first.

## Method

### Step 1: Load Memory

Read `MEMORY.md` from the project's memory directory. The path follows this pattern:
`~/.claude/projects/<project-path-encoded>/memory/MEMORY.md`

Where `<project-path-encoded>` is the project root path with `/` replaced by `-`.

Also read any topic files referenced from MEMORY.md (e.g., `feedback_testing.md`, `project_auth.md`).

List what was found:
- Total entries in MEMORY.md
- Topic files and their one-line descriptions
- Last modified dates

### Step 2: Categorise Each Entry

For each memory entry, classify as one of:

- **Promote** - This is a permanent pattern, convention, or constraint. It belongs in CLAUDE.md, a rule file, or a skill. Example: "always use parameterised queries in this project's API layer."
- **Keep** - Still relevant and useful for future sessions but not permanent enough for CLAUDE.md. Example: "user prefers terse responses with no trailing summaries."
- **Remove** - Stale, wrong, duplicated by CLAUDE.md/rules, or too specific to a past task. Example: "Phase 12 is currently in progress" when Phase 12 finished weeks ago.

Present the categorisation as a table:

```
| # | Entry | File | Category | Reason |
|---|-------|------|----------|--------|
| 1 | Always use tabs | MEMORY.md | Remove | Already in rules/style.md |
| 2 | User is senior dev | user_role.md | Keep | Informs response depth |
| 3 | API uses JWT auth | project_api.md | Promote | Add to project CLAUDE.md |
```

### Step 3: Act on Categorisation

Wait for the user to confirm or adjust the categories. Then:

**For "Promote" entries:**
- Identify the right destination (CLAUDE.md, a rule file, or a skill)
- Add the learning to that file
- Remove or update the memory entry to avoid duplication

**For "Remove" entries:**
- Delete from MEMORY.md or the topic file
- If a topic file becomes empty, delete the file and remove its reference from MEMORY.md

**For "Keep" entries:**
- Leave as-is

### Step 4: Update Review Timestamp

Write the current unix timestamp to the review cache so the hook knows when the last review happened:

```bash
date +%s > ~/.claude/projects/<project-path-encoded>/memory/.last-review
```

## Rules

- **Do NOT auto-promote or auto-remove without user confirmation.** Present the table, wait for approval.
- **Do NOT modify CLAUDE.md without showing the proposed change first.**
- **Check for duplicates.** Before promoting, grep the destination file to confirm the learning isn't already there.
- **Keep MEMORY.md under 200 lines.** That's the auto-loaded limit. If it's over, prioritise removing noise.
