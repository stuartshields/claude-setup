---
name: brainstorm
description: Structured discovery workflow. Explores context, interviews the user with clarifying questions, proposes approaches with trade-offs, and writes a discovery brief before any planning begins.
argument-hint: "[topic or problem to explore]"
disable-model-invocation: true
effort: high
allowed-tools: Read, Grep, Glob, Bash, Write, Agent
---

# Skill: brainstorm

## When to Use

Run `/brainstorm` before starting complex work. When you have a vague idea and need to clarify scope, constraints, and approach before writing a plan or code. Use `$ARGUMENTS` as the starting topic.

If `$ARGUMENTS` is empty, ask the user what they want to explore.

Do NOT write code. This is discovery, not implementation.

## Method

### Step 1: Explore Context

Before asking any questions, read the relevant project files to understand what already exists:

- `CLAUDE.md` in the project root (conventions, stack, architecture)
- `package.json`, `requirements.txt`, or equivalent (dependencies, scripts)
- Existing code in the area related to `$ARGUMENTS` (Grep/Glob for relevant files)
- `.planning/SOURCES.md` if it exists (prior research on this or related topics)

Summarise what you found in 3-5 bullet points. This grounds the conversation in reality rather than assumptions.

### Step 2: Interview

Ask 3-5 clarifying questions, **one at a time**. Ask one question, wait for the answer, then ask the next based on the response. Do NOT batch all questions into a single message.

Focus questions on:
- **Who uses this?** Target users, their technical level, their workflow.
- **What problem does it solve?** The pain point, not the solution. What happens today without this?
- **What constraints exist?** Time, dependencies, backwards compatibility, performance requirements, team preferences.
- **What's the simplest version that's useful?** The MVP that delivers value. What can be deferred?
- **What's been tried before?** Prior attempts, why they failed or were abandoned.

Adapt questions based on answers. If the first answer reveals the scope is narrow, you may need only 2-3 questions. If it reveals complexity, ask up to 5.

The interview is the point. If you find yourself writing a brief after one question, you skipped the discovery.

### Step 3: Propose Approaches

Present 2-3 approaches with explicit trade-offs. For each approach:

```
### Approach N: <name>

**What it does:** One-paragraph description.

**What it costs:**
- Complexity: low / medium / high
- Time estimate: hours / days / weeks
- Dependencies: new deps required, if any

**What it doesn't handle:** Limitations, deferred concerns, known gaps.

**Best when:** The scenario where this approach is the right choice.
```

Let the user pick. Do not recommend one over the others unless asked.

### Step 4: Write Discovery Brief

Once the user has chosen an approach, write a brief to the appropriate location:

- If `.planning/` exists in the project root, write to `.planning/discovery/YYYY-MM-DD-<topic-slug>.md`
- Otherwise, write to `docs/discovery/YYYY-MM-DD-<topic-slug>.md`

Create the directory if it does not exist.

Brief format:

```
# Discovery: <Topic>

**Date:** YYYY-MM-DD
**Status:** Discovery complete

## Problem Statement

What problem are we solving and why it matters. 2-3 sentences.

## Context

Key findings from Step 1 (existing code, constraints, prior work).

## Chosen Approach

The approach the user selected, with rationale from the discussion.

## Constraints

- Hard constraints (must-haves, non-negotiables)
- Soft constraints (preferences, nice-to-haves)

## Open Questions

Anything unresolved that needs to be answered during planning or implementation.

## Next Step

Either "Write a plan" or "Implement directly" - based on scope and complexity.
```

### Step 5: Brief Review (max 3 iterations)

After writing the brief, dispatch a subagent to review it. The reviewer gets the brief file only - not your conversation history. This keeps the review focused on what was written, not what was discussed.

**Dispatch a general-purpose agent with this prompt:**

> Review the discovery brief at [path]. Check for:
>
> 1. **Completeness** - any TODOs, placeholders, "TBD", or incomplete sections?
> 2. **Consistency** - do any parts contradict each other?
> 3. **Clarity** - could any requirement be misinterpreted during planning?
> 4. **Scope** - does this stay focused on one problem, or drift into multiple?
> 5. **YAGNI** - does this include anything the user didn't ask for?
>
> Only flag issues that would cause real problems during implementation planning. Approve unless there are serious gaps that would lead to a flawed plan.
>
> Return: "Approved" or a numbered list of issues with section reference and specific problem.

**If "Approved":** Present the brief to the user for their review (Step 6).

**If issues found:** Fix them in the brief, then dispatch the reviewer again. Maximum 3 iterations. If the reviewer still finds issues after 3 rounds, present the brief to the user with the outstanding issues noted - let them decide whether to fix or proceed.

### Step 6: User Review

Present the brief to the user. They may approve it, request changes, or decide next steps. The brief is theirs now - discovery is complete.

## Rules

- **Do NOT write code.** This is discovery, not implementation.
- **Do NOT invoke planning or execution skills.** The user decides the next step after reading the brief.
- **Do NOT skip the interview.** Even "simple" problems benefit from 2-3 questions.
- **Do NOT batch questions.** Ask one at a time. The next question depends on the previous answer.
- **Do NOT recommend a single approach.** Present options and let the user choose.
