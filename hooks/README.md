---
title: Hooks
---
<!-- Last updated: 2026-05-19T14:30+10:00 -->

## Hooks

> **TL;DR:** 32 hooks across 6 categories:
>
> - **Quality gates** - `check-code-quality`, `project-quality-gates`, `stop-quality-check`, `tab-edit-guard`, `tab-read-reminder`, `bash-tab-warn`. Block bad code before it's written, surface tab/space indent mismatches on Edit with corrective feedback, and warn when sed/awk/perl is about to touch a tab-indented file.
> - **Loop and drift detection** - `detect-perf-degradation`, `drift-review-stop`, `repeated-edit-guard`, `repeated-bash-guard`, `repeated-approach-guard`, `context-drift-guard`. Catch reasoning loops, oscillating edits, command repetition, and context drift. The last three replaced prose rules that weren't being followed.
> - **Agent guards** - `agent-guard-write-block`, `agent-guard-readonly`, `agent-guard-max-lines`. Make "read-only" structurally enforced, not just a suggestion.
> - **Memory and session lifecycle** - `memory-review-prompt`, `compact-restore`, `pre-compaction-preserve`, `session-cleanup`. Memory review at natural breakpoints, compaction state preservation.
> - **Tracking and observability** - `posttool-dispatcher`, `track-modified-files`, `track-tasks`, `hook-observability-summary`, `log-instructions`. What changed, when, and why.
> - **Policy and notifications** - `block-git-commit`, `auto-approve-personal`, `check-unfinished-tasks`, `remind-handoff`, `remind-project-claude`, `stop-dispatcher`, `notification-alert`, `permission-notify`. Commit blocking, scoped permission auto-approval, task state enforcement at Stop, and attention alerts.

### The problem

Rules tell Claude what to do. But Claude doesn't verify its own work automatically. Under pressure - complex tasks, long sessions, approaching context limits - it starts cutting corners. A rule that says "no console.log" works most of the time. A hook that blocks the write works every time.

The difference becomes obvious with agent guards. Telling an agent "you are read-only, do not modify files" in its prompt works most of the time. A hook that exits 2 on Write/Edit calls works every time. The prompt sets intent, the hook guarantees it.

### How I use hooks

**Three patterns** cover most of what hooks do here:

**1. Block before write (quality gates).** Most setups run Prettier or Biome after a file is written - the formatter fixes it after the fact. I'd rather block the write entirely so the file is never wrong. `check-code-quality.sh` fires before every Write/Edit and rejects space indentation, console.log, debugger statements, placeholder comments, and TODO stubs. The code Claude produces is correct on first write because it has to be.

Here's the core of how it works:

```bash
# Get the content being written
if [ "$TOOL" = "Write" ]; then
	jq -r '.tool_input.content // empty' < "$TMPINPUT" > "$TMPCODE"
elif [ "$TOOL" = "Edit" ]; then
	jq -r '.tool_input.new_string // empty' < "$TMPINPUT" > "$TMPCODE"
fi

# Check for violations
if grep -q 'console\.log(' "$TMPCODE"; then
	ERRORS="${ERRORS}console.log() found - remove or use console.error. "
fi

# Block if violations found
if [ -n "$ERRORS" ]; then
	echo "$ERRORS" >&2
	exit 2  # Block the write
fi
```

**2. Detect loops mechanically (drift and repetition guards).** These replaced prose rules that weren't working. `context-drift-guard.sh` counts consecutive read-only tool calls and warns after 5 without an edit - the rule version of this ("after 5 reads, stop and summarise") was ignored. `repeated-approach-guard.sh` tracks file content hashes and detects when a file returns to a previous state - the write-revert-rewrite loop. `repeated-bash-guard.sh` blocks after 3 identical consecutive commands.

**3. Catch incomplete work at Stop (stop gates).** `stop-quality-check.sh` scans Claude's final message for signs of incomplete work: deferred follow-ups ("in a follow-up"), unverified success claims ("all done" with no test output), and "too many issues" excuses. When triggered, it blocks the stop and feeds the issues back. Claude sees the list and addresses them before finishing.

All Stop hooks funnel through `stop-dispatcher.sh` - a single entry point that runs checks sequentially, aggregates all blocking reasons, and returns one decision. This keeps Stop deterministic while spreading non-blocking reminders across earlier lifecycle events. `posttool-dispatcher.sh` does the same for PostToolUse - one buffered read fans out to 8 sub-hooks based on tool name, replacing 8 separate hook entries.

### The lesson that changed everything

I had a rule file called `context-management.md` with 11 bullet points about context discipline - "read only files the task requires", "after 5 reads without action, stop", "trust the compaction summary." Claude followed maybe half of them, half the time.

I deleted the file. Merged 3 essential points into `discipline.md`. Converted the "5 reads" rule into `context-drift-guard.sh`. The hook has a 100% detection rate. The rule had maybe 50%.

The principle: **if a behaviour matters enough to write a rule about, and the rule keeps getting ignored, convert it to a hook.** Prose rules are suggestions. Hooks are laws.

### Scoped auto-approval

`auto-approve-personal.sh` is a `PreToolUse` hook that emits `permissionDecision: allow` JSON for any tool call when the working directory is under `~/Personal/` - except for `~/Personal/project-claude-setup/`, which it explicitly excludes.

Why I use it: personal projects under `~/Personal/` are low-stakes throwaway work. Demos, experiments, side projects. The permission prompt is friction I don't need there. The hook removes it in exactly the scope where it's safe to.

Why `project-claude-setup` is excluded: this repo is the source of truth for my global Claude configuration. Mistakes here leak into every other project I work on. The permission prompt becomes a meaningful checkpoint, so the hook deliberately skips its own auto-approval for this directory.

**This pattern is intentionally narrow.** Do not register this hook (or any similar shape) for any project that touches secrets, customer data, production credentials, or anything you can't revert by `git reset`. Auto-approval bypasses the only deterministic gate Claude Code has between "tool call is about to fire" and "tool call ran" - if you allow it where it shouldn't be allowed, there's no other guard.

If you adopt this setup, change `$HOME/Personal/` to your own trusted-projects directory and audit the exclusion list against the kinds of work you actually do there. The same shape works for `~/scratch/`, `~/experiments/`, or any path you treat as a sandbox.

### What's in here

**Quality gates:** `check-code-quality.sh`, `project-quality-gates.sh`, `stop-quality-check.sh`, `tab-edit-guard.sh`, `tab-read-reminder.sh`, `bash-tab-warn.sh`

**Loop and drift detection:** `detect-perf-degradation.sh`, `drift-review-stop.sh`, `repeated-edit-guard.sh`, `repeated-bash-guard.sh`, `repeated-approach-guard.sh`, `context-drift-guard.sh`

**Agent guards:** `agent-guard-write-block.sh`, `agent-guard-readonly.sh`, `agent-guard-max-lines.sh`

**Memory and session lifecycle:** `memory-review-prompt.sh`, `compact-restore.sh`, `pre-compaction-preserve.sh`, `session-cleanup.sh`

**Tracking and observability:** `posttool-dispatcher.sh`, `track-modified-files.sh`, `track-tasks.sh`, `hook-observability-summary.sh`, `log-instructions.sh`

**Policy and notifications:** `block-git-commit.sh`, `auto-approve-personal.sh`, `check-unfinished-tasks.sh`, `remind-handoff.sh`, `remind-project-claude.sh`, `stop-dispatcher.sh`, `notification-alert.sh`, `permission-notify.sh`

---

[Previous: Rules](../rules/README.md) | [Next: Agents](../agents/README.md)
