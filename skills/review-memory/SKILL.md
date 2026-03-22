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

For each memory entry, evaluate all three categories **in this order**:

1. **Remove?** Is this stale, wrong, duplicated by CLAUDE.md/rules, or derivable from code/git? If yes → Remove.
2. **Promote?** Does this encode a convention, decision, or constraint that should survive memory cleanup? If losing it would cause mistakes in future sessions, it belongs in CLAUDE.md, a rule file, or a skill → Promote.
3. **Keep** only if the entry is still relevant but too situational or temporary for a permanent file (e.g., user preferences, in-flight research, external context not derivable from code).

**Every "Keep" must include a one-line justification for why it doesn't belong in CLAUDE.md, a rule, or a skill.** If you can't articulate why, it's probably a Promote.

Present the categorisation as a table:

```
| # | Entry | File | Category | Reason |
|---|-------|------|----------|--------|
| 1 | Always use tabs | MEMORY.md | Remove | Already in rules/style.md |
| 2 | User is senior dev | user_role.md | Keep | User profile, not a project convention |
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
- **Verify memory accuracy before promoting.** Memories are written by Claude and may contain inferences or assumptions that were never confirmed. Quote the specific claim being promoted and confirm it's accurate with the user.
- **Keep MEMORY.md under 200 lines.** That's the auto-loaded limit. If it's over, prioritise removing noise.
