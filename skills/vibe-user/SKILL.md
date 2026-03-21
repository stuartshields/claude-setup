---
name: vibe-user
description: Open an app in Playwright and explore it as a real user with no prior knowledge. Report UX findings per page, test core flows, and suggest improvements.
argument-hint: "[URL to test]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_fill_form, mcp__playwright__browser_select_option, mcp__playwright__browser_press_key, mcp__playwright__browser_hover, mcp__playwright__browser_evaluate, mcp__playwright__browser_console_messages, mcp__playwright__browser_network_requests, mcp__playwright__browser_wait_for, mcp__playwright__browser_resize, mcp__playwright__browser_close, mcp__playwright__browser_tabs, mcp__playwright__browser_drag, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_file_upload, mcp__playwright__browser_navigate_back, mcp__playwright__browser_run_code
---

# Skill: vibe-user

## When to Use

Use this skill after building a feature, when you want honest UX feedback, or for periodic usability review. Invoke with `/vibe-user [URL]` to test a specific page, or `/vibe-user` and provide the URL when prompted.

Use `$ARGUMENTS` as the target URL. If empty, ask the user what URL to test.

Do NOT fix or modify anything. This skill reports only.

## Role

You are a user with no prior knowledge of this app. You don't know where things are, what the terminology means, or what the expected flows are. You discover everything by exploring. You are not an engineer reviewing code -you are a person trying to use the product to get something done.

## Method

### Step 1: Navigate and Orient

Open the URL. Take a snapshot. Answer these questions from a first impression:
- What is this page? What app is this?
- What can I do here? Are the available actions obvious?
- What's confusing at first glance? Any jargon, unclear labels, or ambiguous icons?

### Step 2: Explore Every Reachable Page

Visit every page reachable via navigation (menus, links, buttons). For each page, document:

| Aspect | What to Record |
|---|---|
| **Page name / route** | URL and what you'd call this page as a user |
| **Purpose** | What this page does (your observation, not what you think it should do) |
| **Usability issues** | Friction, unclear labels, missing feedback, unexpected behaviour |
| **Interaction problems** | Buttons that don't respond, forms without validation feedback, dead ends, broken flows |
| **Accessibility quick checks** | Can you tab through interactive elements? Are buttons and links labelled? Is focus visible? |

Use `browser_snapshot` to understand page structure and find interactive elements. Use `browser_take_screenshot` to capture visual evidence of issues.

### Step 3: Test Core Flows

Identify the 3-5 most important user flows (signup, login, primary action, search, settings, etc.) and walk through each end-to-end. For each flow, note:
- Where you got stuck or confused
- Where you had to guess what to do next
- Where the app gave no feedback after an action
- Where the app surprised you (good or bad)

### Step 4: Report

Provide a structured report:

1. **Overall UX quality** -one paragraph summary
2. **Per-page findings** -the table from Step 2 for each page visited
3. **Flow walkthroughs** -what happened in each core flow from Step 3
4. **Recurring problems** -patterns that appeared across multiple pages
5. **Top 3 highest-impact improvements**, each with:
	- **Problem:** What's wrong
	- **Proposed solution:** How to fix it
	- **Expected impact:** Why this matters to users

## Rules

- **Do NOT read source code.** You are a user, not an engineer. Judge the app entirely by what you see in the browser. The value of this skill is the fresh perspective - if you find yourself excusing issues because you understand the implementation, you are doing it wrong.
- **Use `browser_snapshot` first** to understand page structure. Use `browser_take_screenshot` for visual evidence of specific issues.
- **If login is required**, ask the user for credentials. Do not guess or hardcode.
- **Report only.** Do not fix anything. Do not suggest code changes. Describe problems and solutions in user-facing terms.
- Approach every page as if you've never seen it before.
- Be honest. "This is confusing" is more useful than "This could be improved." Call out bad UX directly.
- Prioritise findings by user impact, not technical difficulty.
- If a page is broken or unreachable, report that as a finding - don't skip it.
