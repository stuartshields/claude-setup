---
title: How This Differs From Community Practice
---
<!-- Last updated: 2026-05-19T14:30+10:00 -->

> **TL;DR:** This setup overlaps the May 2026 community baseline (superpowers plugin, hook-as-enforcement, ≤500-line CLAUDE.md) but diverges in a few deliberate directions:
>
> - **Ahead of common practice** - per-project `REVIEW.md` audit calibration, `audit-vs-fix-discipline` skill, doubled tab enforcement, indexed memory files.
> - **Different from community trend** - heavier hook layer than citypaul's dotfiles (~20 hooks vs ~2), some hook responsibilities the community would push into skills.
> - **Neither ahead nor behind, just different** - WordPress specialisation, educational-mirror-as-public-artifact, agent count tuned to single-developer multi-stack work.
>
> Read this if you're adopting this setup wholesale and want to know which decisions are mainstream, which are personal, and where I'm betting differently from the consensus.

This document captures how this configuration compares to what other people are publishing and recommending for Claude Code as of May 2026. It exists as a sanity check on my own choices, not as an argument that this setup is "correct" - several deliberate divergences are noted below.

## Reference points used

- **[obra/superpowers](https://github.com/obra/superpowers)** - the de-facto skills framework, accepted into Anthropic's official plugin marketplace in January 2026.
- **[citypaul/.dotfiles](https://github.com/citypaul/.dotfiles)** - the most-cloned personal Claude Code dotfiles repo.
- **[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** - the curated community list.
- **[rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)** - the comprehensive mega-bundle (135 agents, 35 curated skills, 20 hooks, 15 rules).
- **[Claude Code Best Practices 2026 - The Prompt Shelf](https://thepromptshelf.dev/blog/claude-code-best-practices-2026/)** - consensus article on length/structure guidance.
- **[Claude Code Hooks Complete Guide 2026 - lukaszfryc, dev.to](https://dev.to/lukaszfryc/claude-code-hooks-complete-guide-with-20-ready-to-use-examples-2026-dcg)** - 20 hook examples with must-have vs optional classification.
- **[Claude Code settings.json Deep Dive (Vincent Qiao)](https://blog.vincentqiao.com/en/posts/claude-code-settings-hooks/)** - the most-cited hooks system walkthrough.

## Where this setup is ahead of common practice

### Per-project audit calibration (`REVIEW.md`)

No published setup I could find ships a per-project file that overrides the audit-vs-fix discipline. The `awesome-claude-code-toolkit` ships generic agents and lets them flag whatever they want; superpowers has `requesting-code-review` but no per-repo calibration. Why this matters: an audit of a config repo should not flag "missing tests" the way an audit of a Vue app should. The `REVIEW.md` pattern lets you tier findings honestly for the codebase you actually have.

### `audit-vs-fix-discipline` skill

The community has multiple variations of "review my code" skills - superpowers' `requesting-code-review`, the awesome-toolkit's review agents. None of them encode the rule that an audit produces findings, fixes only happen on explicit user request, and rationalisations like "pre-existing" or "out of scope" are forbidden. This is one of the most common failure modes when asking an LLM to review code (it silently fixes things you didn't ask it to fix), and nobody else has packaged the discipline as a reusable skill.

### Instruction budget concept explicit in docs

`docs/core-guide.md` opens with a TL;DR pointing out the ~70-bullet ceiling for always-on instructions. The Prompt Shelf article cites "under 500 lines" as the consensus 2026 number. citypaul violates this - their CLAUDE.md is "substantial, multi-section, decision-framework depth" per public summaries. My ~3 KB CLAUDE.md stays well inside the budget. The discipline matters more than the number - "more rules doesn't mean better behaviour" is the lesson, and very few personal setups state it.

### Tab enforcement at write and read time

`hooks/tab-edit-guard.sh`, `hooks/tab-read-reminder.sh`, and `hooks/bash-tab-warn.sh` cover indent enforcement at three lifecycle points. No published setup doubles up like this. It looks excessive on paper - indentation is a style preference - but indent drift is the single most common cause of silent file rewrites by AI, and the cost of one extra hook fire is much smaller than the cost of recovering from a tab-vs-space cascade.

### Indexed memory file structure

`MEMORY.md` is an index. Each memory entry is its own file under `memory/`. The dev.to guide recommends this shape but rarely shows it. Most setups dump everything into a single `MEMORY.md` and let it grow until it hits the 200-line auto-load cap - at which point newer entries silently drop off.

### Hook-as-enforcement framing made explicit

The lesson from the Prompt Shelf article is "hooks give deterministic control over a probabilistic system." `docs/core-guide.md` says the same thing in its own words: "A rule says 'no console.log.' A hook makes it impossible to write one." Most dotfiles ship hooks without naming the philosophy, which is why people unfamiliar with the system don't know when to reach for a hook vs a rule. Writing it down is the difference between a config and a teachable system.

### Coordinated skill + hook pairs

The `handoff` skill is paired with the `remind-handoff` hook. The `audit-vs-fix-discipline` skill is paired with `REVIEW.md`. The community talks about this lifecycle ("hooks enforce rules, skills capture procedures") but rarely demonstrates a working pair. These are the integration points where the system stops being a folder of files and starts being a workflow.

## Where the community has moved differently

### Hook leanness

Both the Prompt Shelf article and the dev.to guide make this point: *"hooks should be fast, simple shell commands. If your hook needs conditional logic or takes more than a few seconds, it belongs in a skill instead."* Several hooks here push that limit:

- `hooks/memory-review-prompt.sh` (~70 lines, runs at SessionStart, UserPromptSubmit, clear, and compact - fires very often)
- `hooks/posttool-dispatcher.sh` (~54 lines, on every PostToolUse)
- `hooks/stop-quality-check.sh`
- `hooks/hook-observability-summary.sh`

citypaul - the most-cloned personal setup - registers ~2 hooks total. This setup registers ~20. That gradient is real and worth being aware of, even if you decide (as I have, mostly) that the enforcement value is worth the extra weight.

### Skill-first vs hook-first

The 2026 trend driven by superpowers is: hooks for hard guards (block-commit, block-destructive, protect-sensitive-files), skills for everything procedural. This setup blends, leaning hook-heavy. `verify-before-stop.sh` and `check-unfinished-tasks.sh` registered at UserPromptSubmit are doing skill-shaped advisory work in a hook. The reason they're hooks: they fire deterministically every prompt. The reason they could be skills: the model can self-invoke them when relevant, paying no cost when not. There's a real trade-off here and the community has converged on "skill unless it must be deterministic."

### CLAUDE.md priority ordering

The Prompt Shelf recommended order is: build/test commands first, then critical constraints, then architecture, then style, then optional guidelines. This setup leads with shortcuts/triggers and workflow rather than build commands - which is fine for an educational meta-repo (there's no build), but worth noting if you adopt it for an application codebase.

### Plugin philosophy

The community now distrusts heavy plugin inventories: *"each enabled plugin loads tool definitions into every session whether or not you use them."* `docs/core-guide.md` flags this exact concern. This setup runs 5 active plugins (`superpowers`, `frontend-design`, `claude-hud`, `swift-lsp`, `rust-analyzer-lsp`) - moderate, not concerning. The discipline: every enabled plugin should justify its always-on cost.

### Subagent-driven workflow not surfaced

Superpowers' canonical flow is `brainstorm → plan → worktree → subagent execution → review → merge` (the `subagent-driven-development` skill makes it the default for any non-trivial task). It's available here because the plugin is enabled, but no project doc surfaces it as the recommended default. If you adopt this setup, knowing that flow exists is worth more than reading any single skill file.

## Where this is neither ahead nor behind, just different

- **Agent count.** 27 agents. rohitg00's toolkit has 135. citypaul has 10. The variance across the community is huge and there's no canonical number. 27 fits a single-developer multi-stack workflow (TypeScript, PHP/WordPress, Swift).
- **Educational mirror as public artifact.** Few people maintain their dotfiles as a documentation project. Tone conventions (`.claude/CLAUDE.md` - no em-dashes, no AI filler) and TL;DR structure are quality bar moves that help the repo as a reference but don't change Claude's behaviour in any given session.
- **WordPress specialisation.** `agents/wp-reviewer.md`, `agents/wp-perf.md`, `agents/wp-security.md`, `rules/php-wordpress.md`. Nobody publishes this. Niche, but tight and correct for my domain.

## Lessons worth flagging

If you're adopting this setup wholesale, three things to know:

1. **Hooks are heavier than the community baseline.** This is deliberate (enforcement is what hooks are for) but if you find the constant advisory output noisy, the UserPromptSubmit hooks are the first to ease back on. They're already rate-limited (30-minute heartbeat on `verify-before-stop.sh`, 15-minute on `check-unfinished-tasks.sh`), but you could convert them to skills that self-invoke when relevant.
2. **The superpowers plugin covers a lot of ground.** When it was first added, several local skills duplicated its work (`brainstorm`, `review`, parts of `clean-worktrees`). The duplicates were deleted in May 2026; only `clean-worktrees` survived because superpowers' `using-git-worktrees` is about creation, not cleanup. If you enable superpowers, check your own local skills for the same overlap before keeping them.
3. **`REVIEW.md` and `audit-vs-fix-discipline` together are the most opinionated part of this setup.** They constrain how LLM-driven review behaves - findings only, severity-tiered, location-cited, fix only on explicit ask. If you're used to "review and clean up" workflows, this will feel slow at first; the trade is that nothing silently changes.

---

[Previous: Plugins](plugins.md) | [Next: Governance Workflow](governance-workflow.md)
