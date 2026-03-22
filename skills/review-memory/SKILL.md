---
name: review-memory
description: Review auto-memory for the current project. Shows accumulated learnings, identifies noise, and helps promote permanent patterns to CLAUDE.md, rules, or skills.
argument-hint: "[optional: '--compact' for quick low-context review]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Skill: review-memory

## When to Use

Run `/review-memory` when prompted by the memory review hook, or any time you want to audit what auto-memory has captured for this project. Use after completing a milestone, before starting new work, or when memory feels noisy.

Do NOT run this mid-task. Finish what you're working on first.

## Mode Selection

- **Full mode** (default): Reads all topic files, presents detailed categorisation table, acts on confirmation.
- **Compact mode** (`/review-memory --compact`): Quick list of new memories with one-line summaries. Asks "promote, keep, or remove?" for each. No topic file reads. Use when context is low or time is short.

---

## Full Mode

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

### Step 3.5: Post-Promote Contradiction Check

After promoting any entries, check for contradictions:

1. **Grep the destination file** for any rules or statements that conflict with what was just promoted. Flag contradictions to the user.
2. **Scan remaining memory entries** for anything that is now superseded by the promoted rule. If a memory says "do X" and the new rule says "do Y instead", mark that memory for removal.
3. **Check other rule files** for overlap. If the promoted content duplicates or contradicts an existing rule in a different file, flag it: "This overlaps with [file:line] — merge or remove?"

Only flag clear contradictions. Near-duplicates where both phrasings add value are fine to keep.

### Step 4: Update Review Timestamp

Write the current unix timestamp to the review cache so the hook knows when the last review happened:

```bash
date +%s > ~/.claude/projects/<project-path-encoded>/memory/.last-review
```

---

## Compact Mode

For use when context is low or the hook suggests `--compact`.

### Step 1: Read MEMORY.md Only

Read `MEMORY.md` from the project's memory directory. Do NOT read topic files — use only the one-line descriptions from MEMORY.md.

### Step 2: Quick List

Present each entry as a numbered list with the description from MEMORY.md:

```
1. [feedback] Stop taking shortcuts when debugging — Rewrote debugging.md
2. [feedback] Write complete code always — Restructured discipline.md
3. [project] Auth migration deadline March 15 — Legal compliance driver
```

Ask: "Any to promote, remove, or update? Otherwise I'll mark as reviewed."

### Step 3: Act on Response

- If the user says "all good" or similar → skip to Step 4
- If they flag specific entries → handle just those (promote/remove)
- If a promotion triggers a contradiction → flag it briefly, don't deep-dive

### Step 4: Update Review Timestamp

Same as full mode:

```bash
date +%s > ~/.claude/projects/<project-path-encoded>/memory/.last-review
```

---

## Rules

- **Do NOT auto-promote or auto-remove without user confirmation.** Present the table (full) or list (compact), wait for approval.
- **Do NOT modify CLAUDE.md without showing the proposed change first.**
- **Check for duplicates.** Before promoting, grep the destination file to confirm the learning isn't already there.
- **Verify memory accuracy before promoting.** Memories are written by Claude and may contain inferences or assumptions that were never confirmed. Quote the specific claim being promoted and confirm it's accurate with the user.
- **Keep MEMORY.md under 200 lines.** That's the auto-loaded limit. If it's over, prioritise removing noise.
- **Post-promote contradiction check is mandatory in full mode, advisory in compact mode.**
