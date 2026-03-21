## Hooks

> **TL;DR:** 22 hooks across 10 lifecycle events. PreToolUse hooks block bad code before it's written (stubs, console.log, space indentation). Stop hooks catch incomplete work and shortcut patterns. PostToolUse hooks track modified files, detect reasoning loops, detect available quality gates, and prompt memory review when context is low. Exit 2 blocks, exit 0 allows, exit 1 is a silent warning.

Rules tell Claude what to do. But Claude doesn't verify its own work automatically. It won't check code quality before writing a file, or warn you before stopping with unfinished tasks. Hooks solve that.

Hooks are shell scripts that run at key moments in Claude's lifecycle. Registered in [settings.json](../docs/core-guide.md#hook-registration), they intercept tool calls, prompt submissions, and session events. The hook decides what happens: let it through, block it, or add context. For step-by-step examples, see the [Hooks Guide](https://code.claude.com/docs/en/hooks-guide).

**Tip:** Run `/hooks` to create and manage hooks interactively instead of editing JSON manually.

The lifecycle events this setup uses (10 of 18 available):

| Event | When it fires |
|-------|--------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Before Claude processes your prompt |
| `PreToolUse` | Before any tool call - **can block** |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails - **observe-only** |
| `PreCompact` | Before context compaction |
| `Stop` | When Claude finishes responding (exit 2 continues the conversation) |
| `SessionEnd` | Session terminates |
| `PermissionRequest` | Permission dialog is about to appear - **can auto-approve/deny** |
| `Notification` | Claude needs attention (permission, idle, auth) - **observe-only** |

For the full list of 18 events, see the [official Claude Code docs](https://code.claude.com/docs/en/hooks).

### Exit code contract

This is the most important thing to get right:

| Exit code | Meaning |
|-----------|---------|
| `0` | Success - stdout is parsed for JSON output (e.g., `additionalContext`, `systemMessage`) |
| `2` | **Block** - stderr is fed back to Claude. Effect depends on event (PreToolUse blocks the call, Stop continues the conversation) |
| anything else | Non-blocking error - execution continues |

**The pitfall everyone hits: `exit 1` does NOT block.** If you want to stop Claude from writing a file, you must use `exit 2`. Exit 1 just logs a non-blocking error and lets the tool call proceed. Use exit 2 to block.

**Another pitfall: Stop hook infinite loops.** Stop hooks that invoke Claude (e.g., prompt-type hooks) can trigger infinite loops - the Stop event fires, the hook runs Claude, Claude stops, firing Stop again. Guard against this with an environment variable check:

```bash
if [ -n "$stop_hook_active" ]; then exit 0; fi
export stop_hook_active=1
```

stdin/stdout: hooks receive a JSON object on stdin. Parse it with `jq`. Key fields are `tool_input.file_path` (the file being written) and `tool_input.command` (for Bash hooks). For command hooks, stderr with `exit 2` becomes the blocking error message for events that support blocking. stdout handling depends on event type and output shape (plain text vs JSON fields like `additionalContext` / `systemMessage`).

Hooks support four types: `command` (shell scripts, shown in all examples above), `prompt` (sends a prompt to an LLM for validation), `agent` (runs a multi-step agent), and `http` (calls an HTTP endpoint). Most hooks use `command` - see the [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) for prompt and agent hook examples.

### Hook walkthrough: check-code-quality.sh

The hook-as-quality-gate pattern. This is a `PreToolUse` hook that fires before every `Write` or `Edit` tool call. All violations (space indentation, trailing whitespace, console.log, debugger statements, placeholder comments) exit 2 and block the write, forcing Claude to rewrite with the correct style. The indentation check uses a smart-tabs heuristic (inspired by ESLint's `no-mixed-spaces-and-tabs` and editorconfig-checker) that allows spaces for docblock continuation (`* @param`) and alignment after tabs, while blocking pure space indentation.

Here's the core of how it works:

```bash
# Read stdin JSON, extract file path and tool name
FILE_PATH=$(jq -r '.tool_input.file_path // empty' < "$TMPINPUT")
TOOL=$(jq -r '.tool_name' < "$TMPINPUT")

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
	exit 2  # Block the write, feed error back to Claude
fi
```

Rules are instructions. Hooks are enforcement. The rules say "no console.log" - the hook makes it impossible to accidentally ship one.

**Why PreToolUse instead of a formatter?** Most setups I've seen run Prettier or Biome in a PostToolUse hook - the formatter fixes the file *after* it's already been written. That works, but bad code hits your filesystem first and gets patched after the fact. I'd rather block the write entirely so the file is never wrong. The tradeoff is a shell regex isn't a parser, so the indentation check uses a smart-tabs heuristic instead of a blunt "any leading space = error" pattern. Codex users hit the [same tabs-vs-spaces problem](https://community.openai.com/t/codex-using-tabs-vs-spaces/1285572) but their hook engine can't do pre-write blocking. This pattern only works in Claude Code.

<details>
<summary>Full check-code-quality.sh script</summary>

See the full script at [`check-code-quality.sh`](check-code-quality.sh). The deployed version also includes non-blocking security-sensitive file detection and dependency verification for JS/TS imports.

</details>

### Alerting: when Claude needs your attention

Two hook events can notify you when Claude is waiting: `PermissionRequest` and `Notification`. This setup uses both - pick whichever fits your workflow, or run them together.

**`PermissionRequest`** fires specifically when a permission dialog appears. It can auto-approve or deny tool calls - not just observe. Use this when you want control over which permissions get through.

**`Notification`** fires on any notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`. It's observe-only - it can't block or approve anything. Use this when you just want to know Claude is waiting, regardless of why.

If you run both on permission prompts, you'll get two alerts. That's intentional in this setup - `PermissionRequest` plays a simple sound, `Notification` shows a macOS banner. Remove one if the double-alert is too much.

### Hook walkthrough: permission-notify.sh

A `PermissionRequest` hook that plays a system sound when Claude needs your approval.

```bash
#!/bin/bash
# Play notification sound (non-blocking)
afplay /System/Library/Sounds/Glass.aiff &

exit 0
```

Exit 0 with no output means "show the normal permission dialog" - the hook just adds a sound on top. The `&` backgrounds `afplay` so the hook returns immediately.

`PermissionRequest` hooks can do more than notify. They receive JSON on stdin with `tool_name`, `tool_input`, and `permission_suggestions`. To auto-approve, output JSON with `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": { "behavior": "allow" }
  }
}
```

To deny instead: `"behavior": "deny"` with an optional `"message"`. You can also modify the tool input before approval using `"updatedInput"`. This setup only uses the notification pattern - auto-approve is available but intentionally left out to keep the permission system intact.

### Hook walkthrough: notification-alert.sh

A `Notification` hook that sends a terminal bell and macOS notification banner whenever Claude needs attention.

```bash
#!/bin/bash
IFS=$'\t' read -r TITLE MSG < <(jq -r '[.title // "Claude Code", .message // "Needs your attention"] | @tsv')

# Terminal bell (triggers dock badge in most terminals)
printf '\a'

# macOS notification banner (visible even behind other windows)
osascript -e "display notification \"${MSG}\" with title \"${TITLE}\" sound name \"Ping\"" 2>/dev/null &

exit 0
```

The terminal bell (`\a`) triggers a dock bounce or tab badge in most terminal emulators - useful when you've switched to another app. The `osascript` call creates a native macOS notification banner that appears in Notification Center, visible even when the terminal is behind other windows.

The hook reads `title` and `message` from stdin JSON so the banner shows context-specific text (e.g., "Permission needed" vs "Claude Code is idle"). The `Notification` event fires on four types - use a matcher to filter:

```json
"Notification": [
  {
    "matcher": "permission_prompt|idle_prompt",
    "hooks": [{ "type": "command", "command": "~/.claude/hooks/notification-alert.sh" }]
  }
]
```

Omit the matcher (as this setup does) to fire on all notification types.

### Hook walkthrough: block-git-commit.sh

The hook-as-policy-enforcement pattern. This is a `PreToolUse` hook on the `Bash` tool that prevents Claude (and its subagents) from running `git commit` commands. All code changes are staged but never committed - you commit manually when ready.

```bash
#!/bin/bash
command=$(jq -r '.tool_input.command // empty' 2>/dev/null)

if [[ "$command" =~ git[[:space:]]+(.*[[:space:]]+)?commit ]] || \
   [[ "$command" =~ gsd-tools[^[:space:]]*[[:space:]]+commit ]]; then
	echo "BLOCKED: Git commits are disabled." >&2
	exit 2
fi

exit 0
```

The regex matches `git commit`, `git -C path commit`, and `gsd-tools.cjs commit` (the GSD framework's commit wrapper). Exit 2 blocks the Bash call entirely - Claude sees the error and skips the commit step.

---

## Continue Reading

- Configuration and loading model: [Core Guide](../docs/core-guide.md)
- Governance and audit workflow: [Governance Review Template](../docs/governance-review-template.md)
- Specialist subagents: [Agents README](../agents/README.md)
- Skills and memory system: [Skills README](../skills/README.md)

---

### Files in this folder

How to use this folder in Claude:

1. Copy `hooks/` to `~/.claude/hooks/`
2. Register hooks in `settings.json` by event/matcher
3. Keep executable bits on scripts (`chmod +x`)

| File | What it does |
|------|--------------|
| `agent-guard-max-lines.sh` | Agent `PreToolUse` hook that blocks `Write`/`Edit` exceeding 50 lines. Used by `quick-edit` agent. |
| `agent-guard-readonly.sh` | Agent `PreToolUse` hook that blocks destructive Bash commands. Used by `code-reviewer` agent. |
| `agent-guard-write-block.sh` | Agent `PreToolUse` hook that blocks `Write`/`Edit` entirely. Used by `code-reviewer` agent. |
| `block-git-commit.sh` | `PreToolUse` policy hook that blocks `git commit` and destructive Bash patterns. |
| `check-code-quality.sh` | Deterministic `PreToolUse` quality gate for `Write`/`Edit`. Catches: space indentation, trailing whitespace, console.log, debugger, placeholder comments, TODO stubs, "not implemented" throws, Python pass stubs. |
| `check-unfinished-tasks.sh` | `Stop` + `UserPromptSubmit` hook that warns/blocks on incomplete task state. |
| `compact-restore.sh` | `SessionStart` restore hook that reloads pre-compaction saved state. |
| `detect-perf-degradation.sh` | `PostToolUse` + `PostToolUseFailure` hook that detects reasoning loops and error spikes. |
| `hook-observability-summary.sh` | `PostToolUse` + `PostToolUseFailure` hook that tracks hook outcomes per session and rebuilds an aggregate summary across all sessions every 10th event. |
| `memory-review-prompt.sh` | Three-trigger memory review: GSD phase completion (`UserPromptSubmit`), accumulated memory on session start (`SessionStart`), low context at 30% remaining (`PostToolUse`). Advisory only. |
| `drift-review-stop.sh` | `Stop` hook that catches common cognitive-drift response patterns. |
| `notification-alert.sh` | `Notification` hook for terminal/native attention alerts. |
| `permission-notify.sh` | `PermissionRequest` hook that plays alert when approval is needed. |
| `project-quality-gates.sh` | `PostToolUse` (`Write\|Edit`) advisory hook that detects project lint/typecheck/test commands from package.json and config files. Rate-limited to 60s. |
| `pre-compaction-preserve.sh` | `PreCompact` hook that saves session/project state before compaction. |
| `remind-project-claude.sh` | `UserPromptSubmit` hook that emits actionable CLAUDE.md reminders. |
| `session-cleanup.sh` | `SessionEnd` hook that removes session temp artifacts. |
| `stop-dispatcher.sh` | Single `Stop` dispatcher that runs stop checks, aggregates all blocking reasons, and returns one final decision. |
| `stop-quality-check.sh` | `Stop` hook that blocks incomplete-work completion patterns. |
| `track-modified-files.sh` | `PostToolUse` (`Write|Edit`) tracker for files modified this session. |
| `track-tasks.sh` | `PostToolUse` (`TaskCreate|TaskUpdate`) tracker for task lifecycle state. |
| `verify-before-stop.sh` | `UserPromptSubmit` advisory digest for compact, rate-limited verification reminders. |

`README.md` in this folder is the operational guide you're reading now.

**Note on matcher syntax:** Hook registration in `settings.json` uses regex matchers. A pipe (`|`) is standard regex OR, so `"Write|Edit"` matches both Write and Edit tool calls. This is documented behavior in the hooks reference matcher section.

### Hook walkthrough: stop-quality-check.sh

The hook-as-accountability pattern. This is a `Stop` hook that scans Claude's final message for signs of incomplete work before it finishes responding. It catches five patterns:

1. **Deferred follow-ups** - "in a follow-up", "as a next step", "out of scope for now"
2. **Rationalised pre-existing issues** - "pre-existing issue", "was already broken"
3. **Listed problems without fixing** - "you may want to", "consider adding", TODO/FIXME/HACK
4. **Success claims without evidence** - "all done", "should work now" with no mention of test/build output
5. **"Too many issues" excuses** - "would require significant", "beyond what can be"

```bash
# Pattern 4: Claiming success without verification evidence
if echo "$LAST_MSG" | grep -qiE '(all (done|set|good|fixed)|everything (works|is working|looks good)|should (work|be fine) now)' && \
   ! echo "$LAST_MSG" | grep -qiE '(test|build|lint|verified|ran |pass|EXIT|output)'; then
	ISSUES="${ISSUES}- Declared success without verification evidence\n"
fi
```

When triggered, it blocks via `exit 2` and feeds the issues back - Claude sees the list and addresses them before finishing. A per-session flag prevents the hook from blocking twice (so it doesn't loop if Claude addresses the feedback but uses similar language in its follow-up).

Stop handling in this setup is centralised through `stop-dispatcher.sh`. It runs the Stop checks in sequence and emits a single final decision, so Stop remains block-only and deterministic while non-blocking reminders are surfaced earlier via `UserPromptSubmit` hooks.

### Hook walkthrough: detect-perf-degradation.sh

The hook-as-early-warning pattern. This is a `PostToolUse` and `PostToolUseFailure` hook that tracks every tool call in a session log and watches for two degradation signals:

- **Reasoning loops** - the same tool with the same input called 3+ times in the last 10 calls
- **Error spikes** - 5+ tool failures in the last 10 calls

```bash
# Repeat detection: same tool + same input hash 3+ times in last 10
REPEAT_COUNT=$(echo "$LAST_10" | awk -F'|' -v tool="$TOOL_NAME" -v hash="$INPUT_HASH" \
	'$1 == tool && $2 == hash' | wc -l | tr -d ' ')
if [ "$REPEAT_COUNT" -ge 3 ]; then
	echo "PERF WARNING: Repeated identical call to ${TOOL_NAME} detected (${REPEAT_COUNT}x). Possible reasoning loop."
fi
```

The hook is advisory (exit 0) - warnings appear as system reminders, not blocks. It only analyses every 5th entry to minimise overhead. Each tool call is logged as `tool_name|input_hash|status`, where the input hash is the first 8 characters of an MD5 of the tool input. This keeps the log compact while still catching exact duplicates.

Both events (`PostToolUse` and `PostToolUseFailure`) feed into the same log, so the error rate calculation sees the full picture regardless of whether individual calls succeeded or failed.

---

