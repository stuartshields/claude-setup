# Verification & Error Recovery

- **Run After Writing:** After implementing code, run the project's build, test, or lint command. Check CLAUDE.md for the correct commands.
- **Incremental Verification:** For multi-file changes, verify each logical step works before moving to the next. Don't write 5 files then test - write, test, iterate.
- **Failure Loop:** If build/tests fail: read error -> diagnose root cause -> fix -> re-run. Maximum 3 attempts before asking the user.
- **Never Assume Success:** A file that was written without errors doesn't mean it works. Syntax passes but logic may not. Run the actual command.

## Hook Awareness

Hooks run automatically and can affect your workflow. Know what they do:

- **Commit Blocking:** A PreToolUse hook blocks `git commit` and destructive Bash commands (`rm -rf`, filesystem destruction, recursive chmod/chown, outbound data transfer). Do not attempt to work around the block. If you need to commit, tell the user -- they commit manually.
- **PERF WARNING Response:** If hook output contains "PERF WARNING" (repeated identical tool calls or high failure rate), stop your current approach. You are in a loop or hitting persistent errors. Re-read the relevant code, form a new hypothesis, and try a different approach. Do not repeat the same call.
- **Post-Write File State:** PostToolUse hooks may modify file contents after a Write (e.g., formatting, tracking). When using Edit after a Write, always base `old_string` on reading the file's current contents -- not on what you wrote. The file on disk may differ from what you sent.
