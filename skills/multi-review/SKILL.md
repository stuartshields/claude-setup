---
name: multi-review
description: Orchestrates parallel code review from three angles (maintainability, performance, security) by spawning subagents, then consolidates findings into a single report.
argument-hint: "[files, branch, or diff range to review]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Skill: multi-review

## When to Use

Run `/multi-review` after completing a feature, before merging, or when you want a thorough review from multiple angles. Use `$ARGUMENTS` to scope the review to specific files, a git diff range, or a branch name.

If `$ARGUMENTS` is empty, review staged changes (`git diff --cached`). If there are no staged changes, review unstaged changes (`git diff`).

Do NOT fix issues - only report them.

## Method

### Step 1: Determine Review Scope

Parse `$ARGUMENTS` to determine what to review:

- **File paths** (e.g., `src/api/` or `utils.ts`): Review those files directly.
- **Git diff range** (e.g., `HEAD~3..HEAD` or `abc123..def456`): Use `git diff` to get changed files.
- **Branch name** (e.g., `feature/auth`): Diff against the main branch to get changed files.
- **Empty**: Use staged changes. If none, use unstaged changes. If none, ask the user what to review.

Collect the list of files and the diff content. Store `BASE_SHA` and `HEAD_SHA` if reviewing git changes.

### Step 2: Spawn Three Review Agents in Parallel

Use the Agent tool to dispatch three agents simultaneously. Each agent receives the same scope but reviews from a different angle.

**Agent 1 - Maintainability (subagent: code-reviewer)**

Prompt the code-reviewer agent with:
- The specific files and/or diff to review
- Focus: readability, naming consistency, duplication, complexity, CLAUDE.md compliance, dead code, error handling patterns
- Constraint: report only, do not modify files
- Output: structured findings with file:line references and severity (critical, should-fix, nitpick)

**Agent 2 - Performance (subagent: perf)**

Prompt the perf agent with:
- The specific files and/or diff to review
- Focus: unnecessary computation, N+1 queries, missing caching, bundle size impact, render performance, memory leaks, synchronous blocking
- Constraint: report only, do not modify files
- Output: structured findings with file:line references and severity (critical, should-fix, nitpick)

**Agent 3 - Security (subagent: security)**

Prompt the security agent with:
- The specific files and/or diff to review
- Focus: OWASP top 10, input validation, SQL/NoSQL injection, XSS, CSRF, auth/authorisation gaps, hardcoded secrets, insecure dependencies
- Constraint: report only, do not modify files
- Output: structured findings with file:line references and severity (critical, should-fix, nitpick)

### Step 3: Consolidate Results

After all three agents return, synthesise their findings into a single report using the output format below. When agents disagree (e.g., perf says inline a function, maintainability says extract it), note the conflict explicitly.

## Output Format

```
## Multi-Review Report

**Scope:** <files or diff range reviewed>
**Date:** <YYYY-MM-DD>

### Summary

| Agent | Critical | Should-Fix | Nitpick |
|---|---|---|---|
| Maintainability | N | N | N |
| Performance | N | N | N |
| Security | N | N | N |
| **Total** | **N** | **N** | **N** |

### Findings by File

#### `path/to/file.ext`

| # | Severity | Agent | Line | Issue | Suggestion |
|---|---|---|---|---|---|
| 1 | critical | security | 42 | SQL injection via string concat | Use parameterized query |
| 2 | should-fix | perf | 78 | N+1 query in loop | Batch fetch outside loop |
| 3 | nitpick | maintainability | 15 | Unclear variable name `d` | Rename to `dateString` |

(Repeat for each file with findings.)

### Conflicts

List any disagreements between agents:

- **File:line** - Agent A says X, Agent B says Y. Trade-off: ...

(Omit this section if there are no conflicts.)

### Verdict

One of:
- **Ship it** - No critical issues. Should-fix items are minor.
- **Fix these first** - Critical issues must be resolved before merge. List them.
- **Rethink** - Fundamental problems found. Describe what needs reconsideration.
```

## Rules

- **Read-only.** Do not fix issues, create commits, or modify any files.
- **Review all files in scope.** Do not skip files because they look simple.
- **Each agent must receive the same scope.** Do not split files between agents.
- **Include file:line references** for every finding so the user can navigate directly.
- **Severity definitions:**
	- **critical** - Must fix before merge. Bugs, security vulnerabilities, data loss risks.
	- **should-fix** - Address soon. Performance issues, maintainability concerns, poor patterns.
	- **nitpick** - Optional. Style preferences, minor naming issues, trivial improvements.
