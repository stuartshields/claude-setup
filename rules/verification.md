# Verification & Error Recovery

- **Run After Writing:** After implementing code, run the project's build, test, or lint command. Check CLAUDE.md for the correct commands.
- **Incremental Verification:** For multi-file changes, verify each logical step works before moving to the next. Don't write 5 files then test — write, test, iterate.
- **Failure Loop:** If build/tests fail: read error -> diagnose root cause -> fix -> re-run. Maximum 3 attempts before asking the user.
- **Never Assume Success:** A file that was written without errors doesn't mean it works. Syntax passes but logic may not. Run the actual command.
- **Regression Check:** If fixing a bug, verify the original test case passes AND that existing tests still pass.
