---
name: debug-rules
description: Diagnose which rules loaded, which didn't, and why. Reads the InstructionsLoaded audit log and compares against expected rules.
argument-hint: "[session timestamp or 'latest']"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---
<!-- Last updated: 2026-03-23T16:30+11:00 -->

# Skill: debug-rules

## When to Use

Use this skill when:
- Conditional rules don't seem to be loading
- Claude is ignoring instructions that should be in a rule file
- You changed rule frontmatter and want to verify it works
- You want to see what rules loaded in a specific session

## Prerequisites

This skill requires the `InstructionsLoaded` audit hook. The hook is **not registered by default** - it's an on-demand diagnostic tool you enable when needed.

### Setup (one-time)

The hook script `~/.claude/hooks/log-instructions.sh` should already exist. To enable logging, add this to `~/.claude/settings.json` under `"hooks"`:

```json
"InstructionsLoaded": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "~/.claude/hooks/log-instructions.sh"
      }
    ]
  }
]
```

Then start a new session, do some work that touches files matching your conditional rules, and run `/debug-rules` again.

**Remove the hook from settings.json when done** - it's lightweight but unnecessary for normal use.

## Step 1: Verify hook is active

1. Check `~/.claude/hooks/log-instructions.sh` exists and is executable
2. Check `~/.claude/settings.json` has an `InstructionsLoaded` entry pointing to it
3. Check `~/.claude/instruction-audit.log` exists and is non-empty

If the hook script is missing, tell the user and stop. If the hook script exists but isn't registered in settings.json, show them the setup instructions above. If the log doesn't exist or is empty, tell the user: "No audit log found. Register the hook, start a new session, do some work, then run `/debug-rules` again."

## Step 2: Read the audit log

Read `~/.claude/instruction-audit.log`. If the user provided a timestamp, filter to entries from that session. If they said "latest" or gave no argument, use the most recent session (group by timestamp - entries within 2 seconds of each other are the same session start).

## Step 3: Inventory expected rules

Read all files in `~/.claude/rules/`. For each file:
- If it has no `paths:` frontmatter → it should appear with `reason: session_start`
- If it has `paths:` frontmatter → it should appear with `reason: path_glob_match` only when matching files are read

Build a table of expected rules and their type (always-on vs conditional).

## Step 4: Compare and report

Present three sections:

### Rules that loaded correctly
Table with: file name, load reason, scope (User/Project). These are working as expected.

### Rules that did NOT load
For each missing rule:
- Name and expected load type
- If always-on: this is a problem - it should have loaded at session_start
- If conditional: list what glob patterns it expects, and check the log for any `trigger_file_path` entries that should have matched. If matching files were read but the rule didn't fire, flag it as **BROKEN** (likely the user-level paths: bug)

### Unexpected behaviour
Flag any of these:
- Conditional rules loading at `session_start` (should only load on `path_glob_match`)
- Files in `~/.claude/rules/` that aren't rule files (no frontmatter closing `---`) loading as rules
- Duplicate loads of the same file

## Step 5: Recommendations

Based on findings, suggest:
- If conditional rules aren't firing: check if `paths:` uses YAML array syntax (broken in user-level rules) vs CSV string format (works). Show the fix.
- If unexpected files are loading: suggest moving them out of `~/.claude/rules/`
- If everything looks correct: say so

## Rules

- **Read-only.** Do not modify any files. Report only.
- **Check the log, don't guess.** Every conclusion must be backed by a log entry or absence of one.
- **Show the raw log entries** for any problems found so the user can verify.
