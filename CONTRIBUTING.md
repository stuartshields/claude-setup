# Contributing

Thanks for taking the time to contribute.

This repo mirrors my `~/.claude/` setup, so changes should stay focused, practical, and easy to maintain.

## How To Propose Changes

1. Open an issue with the problem you are solving and the exact files you want to change.
2. Keep pull requests small and focused. One concern per PR is preferred.
3. Include before/after notes so the impact is easy to review.

## What Belongs In This Repo

- Global rules, hooks, agents, skills, docs, and settings that are intentionally versioned.
- Documentation updates that improve clarity or reduce drift.

## What Does Not Belong In This Repo

- Runtime logs or generated local artifacts.
- Local-only machine state.
- Unrelated project files copied from `~/.claude/` by accident.

## Mirror Sync Rules

- Copy only intentionally changed files.
- Do not bulk-sync unrelated folders.
- If a change is global-only and not useful as documentation, do not mirror it here.

## Docs Linking Standard

When adding a new doc, include a small navigation block at the bottom so readers can continue without jumping back to root docs. 

Use one of these headings:

- `## Continue Reading`
- `## Related Docs`

Link to at least two relevant docs from this set when they apply:

- `README.md`
- `docs/core-guide.md`
- `docs/governance-review-template.md`
- `hooks/README.md`
- `agents/README.md`
- `skills/README.md`

## Style

Match the existing tone in this repo:

- plain language
- practical examples
- no marketing wording
- no filler

## Final Check Before Opening PR

- Links work.
- Paths are correct.
- Any new docs include `Continue Reading` or `Related Docs`.
- Changes align with the mirror-sync rules above.