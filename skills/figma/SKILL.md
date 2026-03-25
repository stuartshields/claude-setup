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

### Responsive Gate - Fetch All Breakpoints First

If the design has mobile and desktop variants (separate frames, component variants with Size/Breakpoint properties, or sibling frames named "Mobile"/"Desktop"):

1. **Identify all breakpoint variants before writing any code.** Use `get_metadata` on the parent frame or component set to find all variants (e.g., `Size=Large, State=Default`, `Card / Mobile`, `Card / Desktop`).
2. **Fetch `get_design_context` for EVERY breakpoint variant.** Do not fetch desktop and guess mobile, or vice versa. Each breakpoint is a separate MCP call.
3. **Build a comparison table** of the values that differ between breakpoints (spacing, padding, font sizes, border-radius, image heights, etc.) and the values that are the same. This table is your responsive spec.
4. **If you cannot find a mobile/desktop variant,** ask the user for the node URL. Do not invent "smaller-looking" values. Mobile values that look reasonable to you are still guesses — and guesses are wrong.

**This gate is blocking.** Do not write responsive CSS until you have MCP data for every breakpoint the design targets.

### Never Assume - Extract Then Compare

When implementing from a Figma design:

1. **Extract specs from MCP output.** Call `get_design_context` and list every measurable property from the response: widths, heights, gaps, padding, alignment, positioning, border-radius, colors, gradients, opacity, font sizes, line heights. Write these as a checklist.
2. **Compare against current code.** For each spec, check what the current codebase has. Identify every delta, not just the ones that seem "important."
3. **Fix all deltas.** Don't cherry-pick. If Figma says `align-items: center` and code says `flex-start`, that's a bug.
4. **No invented values.** Every CSS value you write must trace back to an MCP output or an existing project token. If you cannot find the value in MCP data, you are missing context — fetch it or ask. "Looks about right" is not a source.

**MCP output is a representation, not final code.** The default output (React + Tailwind) should be translated into the project's conventions, framework, and design tokens. Reuse existing components instead of duplicating.

### Post-Implementation Spec Audit (Blocking)

After writing CSS/SCSS for a Figma component, **re-read the output file and verify every value against the MCP data** before declaring done. This is a data-level check, not a visual check.

1. **Re-fetch or re-read the MCP output** you used during implementation. For each breakpoint variant, you should still have the `get_design_context` data from the Responsive Gate step.
2. **Read every style file you wrote or edited.** For each CSS property (font-size, line-height, padding, gap, border-radius, color, width, height), confirm the value matches the MCP data or maps to a project token that resolves to the MCP value.
3. **Build a verification table** and present it to the user:

```
| Property       | Figma (desktop) | Figma (mobile) | Code (lg:)  | Code (base) | Match? |
|----------------|-----------------|----------------|-------------|-------------|--------|
| title font     | 28px            | 28px           | --text-h4   | --text-h4   | ✅     |
| content padding| 32px            | 20px           | 32px        | 20px        | ✅     |
```

4. **Any row that doesn't match is a bug.** Fix it before moving on. Do not skip this step because "it looks right visually."

This audit catches the exact failure mode where correct MCP data was fetched but wrong values were written into the code.

### Verify Visually - Screenshots Are Mandatory

After the spec audit passes, do a visual verification:

- Call `get_screenshot` from Figma for the reference image.
- After implementation, take a browser screenshot and compare side-by-side with the Figma screenshot. If Playwright MCP is available, use `browser_navigate` + `browser_take_screenshot` to capture the rendered output, or use `browser_evaluate` to extract computed styles (`getComputedStyle`) and bounding boxes (`getBoundingClientRect`) for precise numerical comparison.
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
- **Never write a CSS value you didn't get from Figma or an existing token.** If you don't have the MCP data for a breakpoint, fetch it. If you can't find the variant, ask the user. Inventing "reasonable" values is the #1 source of Figma mismatches.
- **Never hardcode values when tokens exist.** Map Figma variables to the project's design system tokens.
- **Never declare done without a spec audit.** After writing styles, re-read your output and verify every value against the MCP data in a comparison table. Present the table to the user. This catches wrong values that look "close enough" visually.
- **Never declare done without visual verification.** After the spec audit, compare a browser screenshot against the Figma screenshot. CSS property existence is not proof.
- **If the user says it doesn't look right, they're right.** Don't explain why the CSS "should" work. Look at what's actually rendering. Call `get_screenshot` again and compare.
- **MCP output is a reference, not final code.** Translate to the project's conventions, framework, and existing components.
- **Break large designs into smaller sections.** Large selections slow the tools down or produce incomplete responses.
- **Visual iteration limit: 3 rounds.** After 3 compare-fix-screenshot cycles without achieving parity, stop and report: what matches, what doesn't, and what you've tried. The remaining deltas may need manual inspection or are platform-specific rendering differences.
