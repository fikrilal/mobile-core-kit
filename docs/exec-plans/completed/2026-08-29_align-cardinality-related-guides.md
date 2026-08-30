# Align Cardinality References In Related Guides

**Plan version:** 2
**Task ID:** align-cardinality-related-guides
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Align the API POST and testing guides with ADR 0017's scalar/VO/input/aggregate policy, without changing historical plans, production code, or tests.
**Allowed paths:** docs/exec-plans/active/2026-08-29_align-cardinality-related-guides.md, docs/exec-plans/completed/2026-08-29_align-cardinality-related-guides.md, docs/engineering/api/api_usage_post.md, docs/engineering/testing_strategy.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 1
**Task timeout:** 30m

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Remove the final active-guide assumptions that every validated request uses
`XInput -> aggregate`, and point API guidance to ADR 0017.

## Constraints

- Documentation only; preserve historical completed plans.
- Do not change examples whose multi-field aggregate remains valid.
- Commit, push, and PR creation are out of scope.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given a single-field flow, when testing guidance is read, then it covers raw scalar -> VO without requiring `XInput`.
2. Given an API request model, when POST guidance is read, then it permits mapping from VO, aggregate, or invariant-free command as appropriate.

## Acceptance Criteria

1. Testing and API POST guides agree with ADR 0017.
2. No active engineering guide points readers to ADR 0016 as current policy.
3. Documentation verification succeeds.

## Implementation Checklist

- [x] Update testing guidance.
- [x] Update API POST guidance and ADR link.
- [x] Verify and archive this plan.

## Decision Log

- 2026-08-29: Preserve historical execution-plan references -> completed plans record decisions valid at their execution time.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify --task align-cardinality-related-guides --env dev
# Passed with profile fast on attempt 1.
```

## Runtime Evidence

Not required for documentation-only changes.

## Rollback

Revert only these two guide edits.

## Risks And Mitigations

- Risk: generic wording weakens the concrete multi-field example.
- Mitigation: retain the example and label it as one valid branch of the matrix.

## Completion Notes

Testing and API POST guidance now cover raw scalar -> VO, multi-field aggregate,
and invariant-free input/command branches and link to ADR 0017.

## Follow-ups

None expected.
