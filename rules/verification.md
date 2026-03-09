# Verification & Error Recovery

- **Run After Writing:** After implementing code, run the project's build, test, or lint command. Check CLAUDE.md for the correct commands.
- **Incremental Verification:** For multi-file changes, verify each logical step works before moving to the next. Don't write 5 files then test - write, test, iterate.
- **Failure Loop:** If build/tests fail: read error -> diagnose root cause -> fix -> re-run. Maximum 3 attempts before asking the user.
- **Never Assume Success:** A file that was written without errors doesn't mean it works. Syntax passes but logic may not. Run the actual command.
- **Tests Pass ≠ Code Works:** Passing tests prove the tests pass, not that the feature works. After tests pass, sanity-check the actual behavior - run the app, call the endpoint, check the UI. If the project has no way to do this, state what you verified and what you couldn't.
- **Regression Check:** If fixing a bug, verify the original test case passes AND that existing tests still pass.
