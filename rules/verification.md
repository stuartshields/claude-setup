# Verification & Error Recovery

- **Run build/test/lint after implementing.** Check CLAUDE.md for correct commands.
- **Verify incrementally.** For multi-file changes, test each logical step before moving to the next.
- **Failure loop:** Read error -> diagnose root cause -> fix -> re-run. Maximum 3 attempts before asking the user.
- **A written file is not a working file.** Syntax passes but logic may not. Run the actual command.

## Hook Awareness
- **Commit Blocking:** PreToolUse hook blocks `git commit` and destructive Bash commands. Tell the user to commit manually.
- **PERF WARNING:** Stop your current approach. You are in a loop. Re-read relevant code, form a new hypothesis, try a different approach.
- **Post-Write File State:** Hooks may modify file contents after Write (formatting, tracking). Always re-read before using Edit — the file on disk may differ from what you wrote.
