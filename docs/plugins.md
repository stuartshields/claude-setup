---
title: Plugins
---
<!-- Last updated: 2026-05-19T12:00+10:00 -->

## Plugins

> **TL;DR:** 6 plugins configured (5 enabled, 1 explicitly disabled) plus 1 extra marketplace. Plugins add tool definitions to every session whether or not you use them, so each enabled plugin has to earn its slot. The figma plugin is intentionally off because the repo's `/figma` skill calls Figma MCP directly.

This page exists because `docs/governance-workflow.md` Control 4 ("Plugin Budget") requires that every enabled plugin has a documented owner, use-case, and keep/remove decision. This file is the inventory.

### The problem

Each MCP server and plugin adds tool schemas to your context window even when unused. Plugins enabled in `~/.claude/settings.json` load in every session unless explicitly disabled per-project. Without an inventory, plugins accumulate, contexts inflate, and you can't tell which one is responsible for a behaviour.

The fix is boring: keep a list, give every plugin a reason, review on the governance cadence.

### Enabled

#### `superpowers@claude-plugins-official`

**Use-case:** workflow discipline — brainstorming → spec → plan → execution.

Provides the skill set this setup leans on for any non-trivial task: `superpowers:brainstorming`, `superpowers:writing-plans`, `superpowers:executing-plans`, `superpowers:subagent-driven-development`, `superpowers:systematic-debugging`, `superpowers:test-driven-development`, `superpowers:dispatching-parallel-agents`, `superpowers:using-git-worktrees`, `superpowers:requesting-code-review`, `superpowers:receiving-code-review`, `superpowers:verification-before-completion`, `superpowers:finishing-a-development-branch`, `superpowers:using-superpowers`, `superpowers:writing-skills`.

The `superpowers:brainstorming` skill has a hard gate: any creative work (new features, components, behavioural changes) must go through brainstorm → design → plan before implementation. This is intentional — it's the main behavioural shift this plugin gives you.

Plan artifacts live in `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`. Spec artifacts live in `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`. Both are committed.

**Keep/remove:** keep. Replaced the previous GSD-based planning system as the sole planning workflow.

#### `claude-hud@claude-hud`

**Use-case:** status line display.

Provides `claude-hud:configure` and `claude-hud:setup` skills for configuring the HUD/status line that shows session state, context usage, model, and other ambient info during a session.

**Keep/remove:** keep. Run `/claude-hud:setup` after first install if the status line isn't appearing as expected.

#### `frontend-design@claude-code-plugins`

**Use-case:** generating production-grade frontend interfaces with stronger design quality than the default model output.

Provides the `frontend-design:frontend-design` skill, which Claude invokes when asked to build web components, pages, or applications. Steers away from the generic AI aesthetic that vanilla Claude tends to produce.

**Keep/remove:** keep. Low cost, high value for any frontend work.

#### `swift-lsp@claude-plugins-official`

**Use-case:** language-server protocol integration for Swift.

Enables LSP-backed code navigation, diagnostics, and type information for Swift codebases. Use the `LSP` tool when working in `.swift` files.

**Keep/remove:** keep globally. If you don't work on Swift projects, disable per-project in `.claude/settings.json` to save the context cost.

#### `rust-analyzer-lsp@claude-plugins-official`

**Use-case:** language-server protocol integration for Rust via rust-analyzer.

Enables LSP-backed code navigation, diagnostics, and type information for Rust codebases.

**Keep/remove:** keep globally. Disable per-project for non-Rust projects if context budget is tight.

### Disabled

#### `figma@claude-plugins-official`

**Status:** explicitly `false` in `settings.json`.

**Why off:** the repo's `/figma` skill at `skills/figma/SKILL.md` wraps Figma MCP directly with a structured methodology (responsive gate, post-implementation spec audit). The plugin would duplicate that surface area and add tool definitions to every session — including sessions that have nothing to do with Figma.

**To enable:** flip to `true` in `~/.claude/settings.json` or in a per-project `.claude/settings.json`. The skill and plugin can coexist if you need both.

### Extra marketplaces

Marketplaces registered for plugin discovery. Registering a marketplace does not install plugins from it — install is a separate step.

#### `stuartshields/claude-co2-status-line`

Marketplace for the carbon-tracking status line variant used in this setup. The status line itself runs via `node "/Users/stuart/Personal/co2-status-line/src/update-check.js"` (registered as a `SessionStart` hook in `settings.json`) and `node "/Users/stuart/.claude/hooks/statusline-chain.js"` (configured under `statusLine`). The marketplace is registered for future plugin distribution from this repo.

### Adding or removing a plugin

1. Use `/plugin marketplace add <owner>/<repo>` to register a marketplace if needed.
2. Use `/plugin install <plugin>@<marketplace>` to install.
3. Edit `~/.claude/settings.json` `enabledPlugins` to toggle on or off — this is what determines whether the plugin's tools load each session.
4. Add or update the entry in this file (the doc you're reading) with use-case, owner, and keep/remove decision.
5. If disabling a plugin you previously used, scan the repo for skill references that might now resolve nowhere.

### Per-project overrides

Plugins enabled globally load in every session. Disable per-project in `.claude/settings.json` when:

- The plugin's tools aren't relevant (e.g. disable `swift-lsp` on a Node-only project).
- The plugin overlaps with a project-specific approach you'd rather use.
- Context budget is tight and a plugin you don't use is adding noticeable tool-definition overhead.

The disable looks the same as the global one — set the entry to `false` in `enabledPlugins` in the project's `.claude/settings.json`.

### Plugin-provided skills vs repo skills

Plugins ship their own skills (e.g. `superpowers:brainstorming`, `claude-hud:configure`). These are separate from the 17 skills documented in [skills/README.md](../skills/README.md), which live in this repo's `skills/` directory. When you invoke a skill with a `<plugin>:<skill>` prefix, you're using a plugin-provided skill; bare names refer to the repo's own.

---

[Previous: Skills & Memory](../skills/README.md) | [Next: Governance Workflow](governance-workflow.md)
