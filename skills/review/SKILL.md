---
name: review
description: Multi-agent code review that spawns parallel specialist reviewers (correctness, security, a11y, performance, UI, API contracts, test coverage, git history) against the current diff. Use when reviewing code changes, before committing, or when asked to review.
disable-model-invocation: true
argument-hint: [scope - branch, files, folders, --full, --fix, or blank for uncommitted changes]
---

# Multi-Agent Code Review

Spawn parallel specialist agents against the current diff, collect findings, deduplicate, and present a single ranked report.

## 1. Determine Scope

Use this priority (first match wins):

1. **User-specified scope** in `$ARGUMENTS` (branch name, commit SHA, file paths, folder paths, or `--full`)
2. **Feature branch**: if current branch is not `main`/`master`, use `git diff main...HEAD` plus any uncommitted changes
3. **Uncommitted changes**: `git diff HEAD` (staged + unstaged)
4. **Latest commit**: `git show HEAD`

**Folder paths:** When a directory is passed (e.g. `src/components/`), all files under it are included. In diff mode, this runs `git diff` scoped to the folder. In full-file mode, all source files in the folder are read.

**Full-file review mode (`--full`):** Forces reading complete file content instead of diffing. Use this to review committed features holistically — not just recent changes. Each agent receives the full file content rather than a diff. Works with files and folders:
- `/review --full src/components/SettingsWindow.vue` — review one file
- `/review --full src/components/` — review all files in a folder
- `/review src/components/` — diff-based review of folder (default, uses git)

Auto-detection: if specified files/folders have no diff (no uncommitted changes, no branch diff), automatically falls back to full-file mode.

Run `git diff --stat` for the chosen scope to get the file list. Count frontend files (`*.vue`, `*.tsx`, `*.jsx`, `*.css`, `*.html`) vs backend files (`*.ts` in `worker/`, `*.py`, `*.go`, etc.).

## 2. Spawn Specialist Agents in Parallel

Launch ALL of the following agents **in a single message** so they run concurrently. Each agent receives the same diff scope.

### Agent 1: Code Reviewer (`code-reviewer`)
> Review the git diff for: logic errors, regressions, race conditions, edge cases, type mismatches, removed functionality, changed behavior, and CLAUDE.md compliance. Check all documented bug patterns. Return findings ranked by severity (critical/warning/info) with file:line references.

### Agent 2: Security Reviewer (`security`)
> Deep security audit of the git diff. Check for: injection (SQL, XSS, command), auth bypass, missing validation, CSP violations, secret exposure, OWASP top 10, error handling that leaks internals. Return findings ranked by severity with file:line references.

### Agent 3: Accessibility Reviewer (`a11y`)
> WCAG 2.2 AA review of changed frontend files. Check: semantic HTML, ARIA correctness, keyboard navigation, focus management, color contrast, touch targets, screen reader compatibility. Return findings ranked by severity with file:line references.

Only spawn if frontend files are in the diff. Skip if the diff is backend-only.

### Agent 4: Performance Reviewer (`perf`)
> Performance audit of the git diff. Check for: unnecessary re-renders, N+1 queries, missing indexes, blocking operations, bundle bloat, memory leaks, large payloads, hot path inefficiencies. Return findings ranked by severity with file:line references.

### Agent 5: UI Reviewer (`ui-review`)
> Review changed frontend components for: usability regressions, responsive design issues, interaction quality, missing hover/active/focus states, visual consistency with design system. Return findings ranked by severity with file:line references.

Only spawn if frontend component files (`.vue`, `.tsx`, `.jsx`) are in the diff. Skip if no component changes.

### Agent 6: API Contract Reviewer (`api-contract-reviewer`)
> Review changed API surfaces for: breaking changes (removed endpoints/fields, changed response shapes, new required params), schema consistency (type mismatches between schema and handler), versioning compliance, and missing validation. Return findings ranked by severity with file:line references.

Only spawn if the diff contains API route definitions, controller files, schema files (`.graphql`, `.gql`), or OpenAPI specs. Skip if no API surface changes.

### Agent 7: Test Coverage Reviewer (`test-coverage-reviewer`)
> Review whether tests adequately cover the code changes. Map changed source files to test files. Identify: untested new functions, untested error/edge case branches, assertion-free tests, stale tests referencing removed code. Return findings ranked by severity with file:line and test-file:line references.

### Agent 8: History Reviewer (`history-reviewer`)
> Use git blame and git log on changed lines to identify: reverted fixes (changes that undo previous bug fixes), removed guards (deleted validation/error handling that was added intentionally), pattern breaks (inconsistent with file's established conventions), and repeated mistakes (same change tried and reverted before). Return findings ranked by severity with file:line references and original commit SHAs.

Skip in `--full` mode (no diff to blame against).

**Each agent prompt must include:**
- The exact diff scope command to run (or file paths to read in full-file mode)
- Instruction to read project CLAUDE.md first
- Instruction to return findings as: `SEVERITY | file:line | description`

## 3. Synthesize Results

After all agents complete:

1. **Collect** all findings from all agents
2. **Deduplicate** — if two agents flag the same file:line, merge into one finding noting both perspectives
3. **Rank** by severity: Critical > Warning > Info
4. **Group** by category (Regression, Security, A11y, Performance, UI, API Contract, Test Coverage, History)

## 4. Output Format

Present the final report in this format:

```
## Code Review — [scope description]

**Agents**: [list which ran] | **Files reviewed**: [count]

### Critical ([count])
- **[Category]** `file:line` — description
  _Flagged by: [agent(s)]_

### Warning ([count])
- **[Category]** `file:line` — description
  _Flagged by: [agent(s)]_

### Info ([count])
- **[Category]** `file:line` — description
  _Flagged by: [agent(s)]_

### Clean
[One-line summary for each agent that found nothing]

### Verdict: [Ready to Commit | Needs Attention | Needs Work]
[One sentence summary and recommended next step]
```

If any Critical findings exist, verdict is **Needs Work**. If only Warnings, verdict is **Needs Attention**. Otherwise **Ready to Commit**.

If `--fix` was NOT provided, stop here.

## 5. Fix Phase (requires `--fix`)

### 5a. User Gate

Present the review report from Step 4, then ask the user:

> Which findings should I fix? (all / specific numbers / none)

If the user says "none," stop. If the user picks specific findings, proceed only with those. Wait for the user's response before continuing.

### 5b. Triage

Classify each selected finding:

- **Obvious fix** — the finding directly implies the fix (missing null check, CLAUDE.md compliance, missing ARIA attribute, off-by-one error)
- **Needs discussion** — multiple valid approaches, architectural implications, or the "obvious" fix might introduce new problems (security findings, performance trade-offs, structural changes)

### 5c. Apply Fixes

For **obvious fixes**: apply them directly without asking.

For **needs discussion** findings: present the options to the user and ask which approach to take before making changes. Include:
- What the issue is
- The approaches available (with trade-offs)
- Which approach you'd recommend and why

After all fixes are applied, re-run the relevant review agents against the changed files to confirm the findings are resolved and no new issues were introduced.
