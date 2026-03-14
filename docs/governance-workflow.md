# Governance Workflow

This is the operational workflow for keeping your global Claude setup healthy over time.

## Purpose

Use governance to catch drift early and make incremental improvements instead of one-off cleanup sweeps.

## Workflow

1. Run reviews on a fixed cadence.
2. Collect evidence before making changes.
3. Score findings by impact and effort.
4. Prioritise high-impact, low-effort fixes first.
5. Apply updates in the correct layer:
   - policy and behaviour rules -> `CLAUDE.md` and `rules/`
   - runtime behaviour and automation -> `settings.json` and `hooks/`
6. Validate changes across at least two different project types.
7. Record outcomes and schedule the next cycle.

## Cadence

- Weekly (10-15 min): quick drift and runtime checks.
- Monthly (45-60 min): full control-by-control review.
- Event-triggered: after Claude updates, hook rewiring, permission model changes, or major behaviour regressions.
- Quarterly: broader policy refresh.

## Evidence And Scoring

Use the review template to capture evidence and assign scores.

- Template: [Governance Review Template](governance-review-template.md)
- Suggested score model: `Score = Impact / Effort`

## Mirror Sync Reminder

This repo is a curated mirror. Copy only intentionally changed files and do not bulk-sync unrelated runtime state.

## Continue Reading

- [Governance Review Template](governance-review-template.md)
- [Core Guide](core-guide.md)
- [Repository README](../README.md)
