---
name: figma
description: Figma-to-code workflow using MCP tools. Fetches design context, screenshots, variables, and Code Connect mappings before implementation.
argument-hint: "[figma URL or file key]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, mcp__figma__get_design_context, mcp__figma__get_screenshot, mcp__figma__get_metadata, mcp__figma__get_variable_defs, mcp__figma__get_code_connect_map, mcp__figma__get_code_connect_suggestions, mcp__figma__send_code_connect_mappings, mcp__playwright__browser_navigate, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_snapshot, mcp__playwright__browser_resize, mcp__playwright__browser_evaluate
---

# Skill: figma

## When to Use

Use this skill when implementing UI from a Figma design. Invoke with `/figma [URL]` where the URL is a Figma design link, or `/figma` to start without a specific URL.

Use `$ARGUMENTS` as the Figma URL or file key. If empty, ask the user for the Figma URL.

Do NOT use this skill for general frontend work that doesn't involve a Figma design.

## Method

### MCP Tools Are Mandatory

If you have a Figma URL or file key, you MUST call these tools before writing any code. Never implement from memory, verbal description alone, or assumptions about what a design "probably" looks like.

**Required sequence:**

1. **`get_design_context`** - Fetch structured design representation (layout, spacing, colors, typography). This is your primary source of truth.
2. **`get_screenshot`** - Get a visual reference of the target design. Always do this alongside `get_design_context`.
3. **`get_metadata`** - If `get_design_context` returns too much data, use this first to get a lightweight structural outline, then re-fetch only the nodes you need.
4. **`get_variable_defs`** - When the design uses Figma variables/tokens, fetch them. Map to CSS custom properties or Tailwind theme values instead of hardcoding.

Only after you have both design context AND a screenshot should you start implementation.

**If any tool call fails or returns incomplete data:** Tell the user. Do not fill in the gaps from assumptions.

### Never Assume - Extract Then Compare

When implementing from a Figma design:

1. **Extract specs from MCP output.** Call `get_design_context` and list every measurable property from the response: widths, heights, gaps, padding, alignment, positioning, border-radius, colors, gradients, opacity, font sizes, line heights. Write these as a checklist.
2. **Compare against current code.** For each spec, check what the current codebase has. Identify every delta, not just the ones that seem "important."
3. **Fix all deltas.** Don't cherry-pick. If Figma says `align-items: center` and code says `flex-start`, that's a bug.

**MCP output is a representation, not final code.** The default output (React + Tailwind) should be translated into the project's conventions, framework, and design tokens. Reuse existing components instead of duplicating.

### Verify Visually - Screenshots Are Mandatory

- Call `get_screenshot` from Figma for the reference image.
- After implementation, take a browser screenshot and compare side-by-side with the Figma screenshot.
- If you can't see the difference, zoom in or measure with JS (`offsetHeight`, `getBoundingClientRect`, computed styles).
- Never say "the changes are applied" based only on CSS property existence. Verify the **rendered visual output**.
- If they don't match, iterate. Don't declare done until visual parity is achieved.

### Design Tokens and Variables

- When Figma uses variables, call `get_variable_defs` to get actual token values.
- Map Figma tokens to the project's CSS custom properties, Tailwind theme, or design system tokens.
- Never hardcode a color, spacing, or typography value when a token exists for it.
- If the Figma MCP server returns a localhost source for an image or SVG, use that source directly. Don't create placeholders or import new icon packages.

### Code Connect

If the project uses Code Connect mappings:
- Call `get_code_connect_map` to check existing component mappings before implementing.
- Use `get_code_connect_suggestions` to find suggested mappings for new components.
- When a Code Connect mapping exists, use the mapped codebase component directly instead of generating new code.

### Structure Matters

- Compare HTML/DOM structure against Figma's layer hierarchy. If Figma has a container div with a gradient and an image inside, the code must match, not flatten the gradient onto the image element.
- Pay attention to: parent-child relationships, overflow behavior, absolute vs relative positioning, z-index stacking.
- Break large designs into smaller sections. Large selections slow the tools down, cause errors, or produce incomplete responses.

## Rules

- **Never implement from memory.** Always call MCP tools first. If a tool fails, tell the user - do not fill in gaps from assumptions.
- **Never hardcode values when tokens exist.** Map Figma variables to the project's design system tokens.
- **Never declare done without visual verification.** Compare a browser screenshot against the Figma screenshot. CSS property existence is not proof.
- **If the user says it doesn't look right, they're right.** Don't explain why the CSS "should" work. Look at what's actually rendering. Call `get_screenshot` again and compare.
- **MCP output is a reference, not final code.** Translate to the project's conventions, framework, and existing components.
- **Break large designs into smaller sections.** Large selections slow the tools down or produce incomplete responses.
- **Visual iteration limit: 3 rounds.** After 3 compare-fix-screenshot cycles without achieving parity, stop and report: what matches, what doesn't, and what you've tried. The remaining deltas may need manual inspection or are platform-specific rendering differences.
