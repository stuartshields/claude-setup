---
name: test-plan
description: Generate a user-facing test checklist from git diff, or execute an existing test plan via Playwright. Two modes: generate (default) creates the plan, execute runs it in the browser.
argument-hint: "[git range or 'execute' to run existing plan]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_fill_form, mcp__playwright__browser_select_option, mcp__playwright__browser_press_key, mcp__playwright__browser_hover, mcp__playwright__browser_evaluate, mcp__playwright__browser_console_messages, mcp__playwright__browser_network_requests, mcp__playwright__browser_wait_for, mcp__playwright__browser_resize, mcp__playwright__browser_close, mcp__playwright__browser_tabs, mcp__playwright__browser_drag, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_file_upload, mcp__playwright__browser_navigate_back, mcp__playwright__browser_run_code
---

# Skill: test-plan

## When to Use

Use this skill before merging a feature branch, after completing implementation, or when you need a QA checklist. Invoke with `/test-plan` to generate from the current branch, `/test-plan main...HEAD` for a specific git range, or `/test-plan execute` to run an existing plan.

Use `$ARGUMENTS` to determine the mode:
- **Empty or git range** (default): Generate mode -create a test plan from code changes
- **"execute" or a file path**: Execute mode -run an existing test plan via Playwright

## Generate Mode

### Procedure

1. **Identify changes.** Detect the default branch (`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`, falling back to `main` if that fails). Run `git diff <default-branch>...HEAD --stat` to list changed files. If `$ARGUMENTS` contains a git range, use that instead.
2. **Understand each change.** Read each changed file to understand what was modified and why.
3. **Create test scenarios.** For each user-visible change, generate a test scenario:
	- **Scenario name:** What the user does (e.g., "Submit the contact form with valid data")
	- **Steps:** Numbered, specific enough for someone unfamiliar with the app
	- **Expected result:** What should happen after completing the steps
	- **Edge cases:** What could go wrong (empty fields, duplicate submissions, slow network, etc.)
4. **Group by feature area.** Organise scenarios under feature headings.
5. **Write the plan.** Save to `docs/test-plans/YYYY-MM-DD-<branch-name>.md`.

### Output Format

```
## Test Plan: <branch name>
Generated: <date>

### <Feature Area>

#### Scenario: <name>
- [ ] Step 1: ...
- [ ] Step 2: ...
- [ ] Step 3: ...
- Expected: ...
- Edge cases: ...
```

## Execute Mode

### Procedure

1. **Find the plan.** If `$ARGUMENTS` is a file path, use it. If `$ARGUMENTS` is "execute", find the most recent test plan in `docs/test-plans/`. If none exists, tell the user to generate one first.
2. **Read the plan.** Parse each scenario and its steps.
3. **Run each scenario.** For each scenario, use Playwright MCP to:
	- Navigate to the relevant page
	- Follow the steps exactly as written
	- Use `browser_snapshot` to verify page state after each action
	- Verify the expected result
4. **Record results.** For each scenario, record one of:
	- **PASS** -all steps completed and expected result verified
	- **FAIL** -a step didn't produce the expected result (include `browser_take_screenshot` as evidence)
	- **BLOCKED** -couldn't reach the step (prerequisite failed, page unreachable, login required)
5. **Update the plan.** Append results to the test plan file:

```
### Execution Results - <date>

| Scenario | Result | Notes |
|---|---|---|
| <name> | PASS/FAIL/BLOCKED | <details> |
```

## Rules

- **Test scenarios describe what a user does, not what the code does.** Write "Click the submit button and verify the success message appears" not "POST /api/form returns 200."
- **Steps must be reproducible by someone who has never seen the codebase.** No references to file names, function names, or implementation details.
- **One scenario per user action.** Don't combine "create an account" and "update profile" into one scenario.
- **Include the unhappy path.** For every form, test with empty fields, invalid data, and duplicate submissions. For every action, test what happens when it fails.
- **In execute mode, follow steps literally.** Do not improvise or skip steps. If a step is ambiguous, record it as BLOCKED with a note about what was unclear.
- **Use `browser_snapshot` first** to understand page structure before interacting. Use `browser_take_screenshot` to capture evidence of failures.
