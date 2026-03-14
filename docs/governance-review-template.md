# Governance Review Template

Use this checklist to run a lightweight governance pass for your global Claude setup without changing implementation details during review.

## Recommended Cadence

- Weekly (10-15 min): quick check for release drift, stop-path behavior, and plugin budget changes.
- Monthly (45-60 min): full review across all controls in this template.
- Event-triggered (same day): run after Claude updates, hook rewiring, permission model changes, or major agent behavior regressions.
- Quarterly: policy refresh for `CLAUDE.md`, `settings.json`, and core rule files.

## How To Use This To Improve Claude

1. Gather evidence first: failures, noisy behavior, repeated overrides, and drift examples.
2. Score findings: `Score = Impact / Effort`.
3. Prioritize highest scores: fix high impact + low effort items first.
4. Convert recurring findings into standards:
	- Behavior/policy changes -> `CLAUDE.md` and `rules/`.
	- Runtime behavior changes -> `settings.json` and `hooks/`.
5. Verify in real projects: test changes in at least two different project types.
6. Record outcomes: capture what changed, why, owner, and next review date.

## Review Metadata

- Review Date:
- Reviewer:
- Scope (`~/.claude`, repo mirror, or both):
- Protocol Version (global):
- Protocol Version (repo):
- Last Review Date:
- Next Review Date:
- Overall Status: Pass / Conditional Pass / Fail

## Scoring Method

Use this simple score for prioritization:

`Score = Impact / Effort`

- Impact: 1 (low) to 5 (high)
- Effort: 1 (easy) to 5 (hard)

## Control 1: Release Drift Checklist

Objective: prevent silent divergence between global protocol and repo protocol.

Pass/Fail Gates:
- [ ] Checklist exists and includes version, owner, and review cadence.
- [ ] A section-by-section diff was performed between global and project protocol.
- [ ] Sign-off is captured for this cycle.

Evidence:
- Checklist path:
- Review record path:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 2: Docs Parity Control

Objective: keep top-level docs and folder docs in sync after restructures.

Pass/Fail Gates:
- [ ] A parity checklist covers root docs and all folder README files.
- [ ] Internal links were validated with zero unresolved links.
- [ ] Ownership is defined for updates when structure changes.

Evidence:
- Parity checklist path:
- Link validation output:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 3: Explicit Mode Policy

Objective: remove ambiguity in runtime behavior.

Pass/Fail Gates:
- [ ] A written mode policy exists (default behavior + override rules).
- [ ] Current settings were reviewed against policy and deviations documented.
- [ ] Rollback steps are documented if mode changes regress behavior.

Evidence:
- Mode policy path:
- Settings compliance record:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 4: Plugin Budget Policy

Objective: control token and latency overhead from plugin sprawl.

Pass/Fail Gates:
- [ ] Maximum plugin budget is documented with rationale.
- [ ] Each enabled plugin has owner, use-case, and keep/remove decision.
- [ ] Review cadence is defined and current cycle logged.

Evidence:
- Plugin inventory path:
- Budget policy path:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 5: Stop-Path Governance Check

Objective: ensure stop-time checks remain complete and intentional.

Pass/Fail Gates:
- [ ] Stop dispatcher targets are documented and mapped to failure conditions.
- [ ] Disabled or bypassed checks have explicit justification.
- [ ] A manual validation process exists for emergency bypass scenarios.

Evidence:
- Dispatcher mapping path:
- Last governance review path:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 6: Hook Observability Summary

Objective: make hook behavior measurable so regressions are visible before they impact workflow quality.

Pass/Fail Gates:
- [ ] A single observability summary exists for hook outcomes (allow, block, warn, error) by hook name/event.
- [ ] The current review includes baseline counts and trend comparison vs prior cycle.
- [ ] High-noise or high-failure hooks have an owner and remediation plan.

Evidence:
- Observability summary path:
- Baseline/trend report path:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Control 7: Memory Governance

Objective: keep persistent memory accurate, minimal, and aligned with current protocol behavior.

Pass/Fail Gates:
- [ ] Memory entries were reviewed for stale or duplicated guidance.
- [ ] Session-only notes are not promoted to persistent memory without recurring value.
- [ ] Memory changes include clear owner, rationale, and review date.

Evidence:
- Memory inventory path:
- Change log path:
- Notes:

Rating:
- Impact (1-5):
- Effort (1-5):
- Score:

Decision:
- Status: Pass / Partial / Fail
- Action Owner:
- Action Due Date:

## Summary and Sign-Off

- High Priority Actions:
- Medium Priority Actions:
- Low Priority Actions:
- Approved By:
- Approval Date:

## Optional Quarterly Rollup

- Trend vs last review:
- Recurring failures:
- Controls at risk:
- Recommended focus for next cycle:

## Related Docs

- Setup overview: [README](../README.md)
- Runtime and lifecycle details: [Core Guide](core-guide.md)
- Hook implementation details: [Hooks README](../hooks/README.md)
