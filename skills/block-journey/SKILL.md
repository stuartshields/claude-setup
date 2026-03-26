---
name: block-journey
description: Discover all files for a block or component, trace the editorial and front-end user journeys, and write a journey document to .planning/journeys/.
argument-hint: "[directory/]<block-name>"
disable-model-invocation: true
effort: medium
allowed-tools: Read, Grep, Glob, Write, Agent
---

# Skill: block-journey

## When to Use

Run `/block-journey <name>` to document how a block or component works from two perspectives: the editor creating content, and the visitor consuming it. Use when onboarding to an unfamiliar block, before modifying one, or after building one to capture its contracts.

Parse `$ARGUMENTS` to extract the block name and an optional path scope:

- **`accordion`** — search the entire working directory for a block named "accordion"
- **`rte-blocks/accordion`** — search only within directories whose path contains "rte-blocks" for "accordion"
- **`mu-plugins/rtm-blocks/faq`** — search only within directories whose path contains "mu-plugins/rtm-blocks" for "faq"

If `$ARGUMENTS` contains a `/`, treat everything before the last `/` as a **path substring filter** and everything after as the block name. Match the filter against the full directory path, not just the immediate parent. This matters when the same plugin name exists under different parent directories (e.g., `plugins/rtm-blocks` vs `mu-plugins/rtm-blocks`). If no `/`, treat the entire argument as the block name and search broadly.

When the path filter matches multiple locations, list them and ask the user which one to document.

If `$ARGUMENTS` is empty, ask the user which block or component to document.

Do NOT modify any source files. This is documentation, not implementation.

## Method

### Step 1: Discover Files

Search the working directory for all files related to the block name from `$ARGUMENTS`. Do not assume a specific file structure — discover what exists.

Look for:
- **Registration files** — block metadata, config, or schema (JSON, YAML, PHP, JS)
- **Editor files** — edit components, sidebar controls, inspector panels, editor styles
- **Save / render files** — save components (static blocks), PHP render callbacks, server-side templates
- **Front-end behaviour** — JS that runs on page load for interactivity (toggles, carousels, modals, tabs)
- **Styles** — CSS/SCSS for both editor and front-end
- **Shared components** — any reusable pieces the block imports or depends on
- **Template partials** — theme-side templates that render the block's output

Use Grep and Glob to find files by name pattern and by references (imports, function calls, class names). Follow the dependency chain — if a file imports another, include it.

Present what was found:

```
## Discovered Files

| File | Role |
|---|---|
| path/to/block.json | Registration / attribute schema |
| path/to/edit.js | Editor component |
| path/to/frontend.js | Front-end toggle behaviour |
| ... | ... |
```

If no files are found, tell the user and stop.

### Step 2: Read and Map

Read each discovered file. Build a mental model of:

1. **Data model** — What attributes does the block store? What shape is the data?
2. **Editor interactions** — What can the editor do? What's inline vs sidebar? What inner blocks are allowed?
3. **Render pipeline** — How does saved data become HTML? Is it a static save (JS) or dynamic render (PHP)?
4. **Front-end behaviour** — What JS runs on page load? What DOM elements does it query? What state does it manage?
5. **DOM contract** — What classes, IDs, data attributes, and ARIA attributes connect the rendered HTML to front-end JS?

### Step 3: Write the Journey Document

Write to the **current project's** `.planning/journeys/` directory (relative to the working directory). Create the directory if it doesn't exist.

Write to `.planning/journeys/<block-name>.md` using the template below. Adapt sections to what actually exists — skip sections that don't apply (e.g., no "Front-End Journey" if the block has no interactive JS).

---

## Output Template

```
# <Block Name> — User Journeys

**Generated:** <YYYY-MM-DD>
**Source:** <plugin or directory where the block lives>

## Files

| File | Role |
|---|---|
| ... | ... |

## Data Model

List of attributes the block stores, their types, defaults, and purpose.

| Attribute | Type | Default | Purpose |
|---|---|---|---|
| ... | ... | ... | ... |

## Editorial Journey

Step-by-step description of what an editor does when using this block in the block editor. Cover:

1. How the block is inserted
2. What content is editable inline on the canvas (RichText, MediaUpload, etc.)
3. What controls live in the sidebar (InspectorControls)
4. How inner blocks work (if any) — what's allowed, how to add/remove
5. What the editor sees vs what the visitor sees (e.g., all items expanded in editor, collapsed on front-end)

Number each step. Be specific about which component or attribute is involved.

## Render Pipeline

How saved data becomes HTML. Describe the path:

- **Static save:** JS save component outputs markup directly
- **Dynamic render:** PHP callback receives attributes → sanitises → passes to template → template outputs HTML

Include the key markup structure (simplified) showing the wrapper, key child elements, and their classes/attributes.

## Front-End Journey

Step-by-step description of what a visitor experiences. Cover:

1. Initial page load state (what's visible, what's hidden)
2. Each interaction and what it triggers (click, hover, scroll, etc.)
3. State transitions (what changes in the DOM — classes, attributes, styles)
4. Whether multiple items can be active simultaneously
5. Animations or transitions

## DOM Contract

The classes, IDs, data attributes, and ARIA attributes that connect rendered HTML to front-end JS. This is the section that matters most for maintenance — if any of these change, something breaks.

| Selector / Attribute | Used By | Purpose |
|---|---|---|
| `.block-class-name` | frontend.js | Entry point query |
| `[aria-expanded]` | frontend.js | Toggle state |
| `[aria-controls]` → `[id]` | frontend.js | Button-to-content link |
| `data-open` | frontend.css | Animation trigger |
| ... | ... | ... |

## Accessibility

ARIA pattern used, keyboard interactions, screen reader announcements. Note whether the implementation follows a recognised WAI-ARIA pattern.
```

### Step 4: Present to User

After writing the file, summarise what was documented and note any gaps:

- Sections that were skipped and why
- Behaviours you couldn't determine from code alone (needs manual testing)
- Potential issues spotted during analysis (mismatched selectors, missing ARIA, etc.)

## Rules

- **Do NOT modify source files.** This skill is read-only analysis + one write to `.planning/journeys/` in the current project.
- **Always write to the current working directory's `.planning/journeys/`.** This skill is global but its output is project-local.
- **Do NOT assume file types.** Discover what exists. The block might use `.js`, `.jsx`, `.tsx`, `.php`, `.vue`, or anything else.
- **Do NOT hardcode plugin paths.** Search from the working directory. Use the directory scope from `$ARGUMENTS` if provided (e.g., `rtm-blocks/faq`), but fall back to broad search if nothing is found there.
- **Follow the dependency chain.** If a file imports a shared component, include that component in the analysis. Stop at two levels deep — note deeper dependencies without reading them.
- **Adapt the template.** Skip sections that don't apply. Add sections if the block has unusual patterns (e.g., a tab interface, drag-and-drop, real-time updates). The template is a guide, not a rigid format.
- **Flag unknowns.** If behaviour can't be determined from code alone (e.g., CSS animations, visual rendering, screen reader output), say so explicitly rather than guessing.
- **One block per invocation.** If the user wants multiple blocks documented, they run the skill multiple times.
