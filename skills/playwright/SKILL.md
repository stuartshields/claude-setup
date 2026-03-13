---
name: playwright
description: Playwright MCP browser automation workflow. Snapshot-first approach for page interaction, visual verification, form filling, and debugging.
argument-hint: "[URL to navigate to]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_fill_form, mcp__playwright__browser_select_option, mcp__playwright__browser_press_key, mcp__playwright__browser_hover, mcp__playwright__browser_evaluate, mcp__playwright__browser_console_messages, mcp__playwright__browser_network_requests, mcp__playwright__browser_wait_for, mcp__playwright__browser_resize, mcp__playwright__browser_close, mcp__playwright__browser_tabs, mcp__playwright__browser_drag, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_file_upload, mcp__playwright__browser_navigate_back, mcp__playwright__browser_run_code
---

# Skill: playwright

## When to Use

Use this skill for browser automation tasks: visual testing, page interaction, form filling, screenshot comparison, and debugging rendered pages. Invoke with `/playwright [URL]` to navigate to a specific page, or `/playwright` to start without a URL.

Use `$ARGUMENTS` as the URL to navigate to. If empty, ask the user what page to work with.

Do NOT use this skill for writing test files or test code. This is for live browser interaction via MCP tools.

## Snapshot First, Screenshot Second

The Playwright MCP provides two ways to see page state. Use the right one:

- **`browser_snapshot`** - Returns the accessibility tree. Use this for planning actions, finding interactive elements, and understanding page structure. Fast, deterministic, token-efficient. **Always start here.**
- **`browser_take_screenshot`** - Returns a visual image. Use this for visual verification, layout debugging, comparing against Figma designs, and documentation. You cannot perform actions based on screenshots alone. Use `browser_snapshot` for that.

**Default workflow:**
1. `browser_snapshot` to understand what's on the page
2. Perform actions (`browser_click`, `browser_type`, `browser_fill_form`, etc.)
3. `browser_snapshot` again to verify the action worked
4. `browser_take_screenshot` only when visual verification is needed

## Visual Verification with Figma

When comparing implementation against Figma designs:
1. Call `get_screenshot` from the Figma MCP for the design reference
2. Navigate to the implementation with `browser_navigate`
3. Match viewport dimensions to the Figma frame with `browser_resize`
4. Call `browser_take_screenshot` to capture the current state
5. Compare the two images. If they don't match, identify the specific deltas and fix them
6. Repeat until visual parity is achieved

Don't declare "looks good" after a single screenshot. Compare carefully. If you can't tell, use `browser_evaluate` to measure computed styles and compare against the Figma spec values.

## Be Specific with Actions

Vague instructions lead to wrong element clicks. When interacting with elements:
- Reference elements by their accessibility role and name from `browser_snapshot` output (e.g., "Submit button in the login form", not just "the button")
- If multiple elements share the same label, provide context: parent container, position, or surrounding text
- After every action, take a snapshot to confirm the expected state change happened. Don't assume it worked.

## Form Interactions

- Use `browser_fill_form` to populate multiple fields at once instead of individual `browser_type` calls when possible
- For dropdowns, use `browser_select_option` rather than clicking and typing
- After form submission, use `browser_wait_for` to confirm the expected result (success message, redirect, etc.)
- Check `browser_console_messages` if something fails silently

## Debugging

When something goes wrong:
1. **`browser_console_messages`** - Check for JavaScript errors
2. **`browser_network_requests`** - Look for failed API calls (4xx, 5xx)
3. **`browser_evaluate`** - Inspect DOM state, computed styles, or run diagnostic JS
4. **`browser_take_screenshot`** - See what the user would actually see

Don't guess at the problem. Use these tools to gather evidence first.

## Token Efficiency

Large DOM trees consume significant tokens per `browser_snapshot`. Keep context manageable:
- Target specific sections of a page rather than full-page snapshots when possible
- For very large pages, use `browser_evaluate` to query specific elements instead of snapshotting the entire tree
- Close tabs and pages you're done with using `browser_close`

## Authentication

The Playwright MCP browser is visible. For authenticated pages:
- Navigate to the login page and let the user log in manually with their own credentials
- Cookies persist for the session duration, so you only need to do this once
- Don't attempt to script login with hardcoded credentials
