# Document Input Cardinality And Validation Boundaries

**Plan version:** 2
**Task ID:** document-input-cardinality-policy
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Record the approved cardinality, cohesion, and invariant decision policy in a new ADR that supersedes ADR 0016; align related validation/data/model guides and the queued single-field refactor plans without changing production or test code.
**Allowed paths:** docs/exec-plans/active/2026-08-29_document-input-cardinality-policy.md, docs/exec-plans/completed/2026-08-29_document-input-cardinality-policy.md, ADR/records/0016-validated-form-boundaries.md, ADR/records/0017-input-cardinality-and-validation-boundaries.md, docs/engineering/validation_architecture.md, docs/engineering/value_objects_validation.md, docs/engineering/validation_cookbook.md, docs/engineering/data_domain_guide.md, docs/engineering/model_entity_guide.md, docs/exec-plans/queued/2026-08-29_request-password-reset-validated-boundary.md, docs/exec-plans/queued/2026-08-29_verify-email-token-boundary.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 60m

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Replace the overly universal `XInput -> validated aggregate` guidance with an
explicit decision matrix that chooses scalar, VO, named input/command, or
validated aggregate based on cardinality, cohesion, and deterministic invariants.

## Constraints

- Architecture constraints:
  - Preserve use cases as the final gate whenever raw values require deterministic validation.
  - Preserve validated repository boundaries without creating one-field wrapper aggregates.
  - Keep data request models responsible for wire primitives.
- Product/runtime constraints:
  - Documentation and queued-plan changes only; no runtime or API behavior changes.
- Out of scope:
  - Implementing any queued refactor, generic validator abstractions, commit, push, or PR creation.

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

1. Given a single raw parameter with an invariant, when a contributor reads the policy, then they choose raw scalar -> use case -> VO -> repository without a wrapper aggregate.
2. Given multiple cohesive parameters without deterministic invariants, when a contributor reads the policy, then they may group them in a named input/command without inventing VOs or a validated aggregate.
3. Given multiple fields with field or cross-field invariants, when a contributor reads the policy, then they choose raw input -> validated aggregate -> repository.
4. Given the queued reset-request and verify-email plans, when reviewed, then their authority matches the single-field policy.

## Acceptance Criteria

1. ADR 0017 records the complete policy, tradeoffs, examples, and confirmation rules and supersedes ADR 0016.
2. ADR 0016 is marked superseded without rewriting its historical decision body.
3. Validation, VO, cookbook, data/domain, and model/entity guides contain consistent cardinality guidance.
4. Single-field queued plans no longer require one-field `XInput` types.
5. Repository knowledge, plan parsing/risk classification, stale-language checks, and Markdown structure succeed.

## Implementation Checklist

- [x] Add ADR 0017 and mark ADR 0016 superseded.
- [x] Add the decision matrix to validation and VO guidance.
- [x] Align cookbook and data/model mapping guidance.
- [x] Adjust the two queued single-field plans.
- [x] Verify consistency and archive this plan.

## Decision Log

- 2026-08-29: Supersede rather than rewrite ADR 0016 -> preserve historical architectural decisions per repository policy.
- 2026-08-29: Separate grouping from validity -> `XInput` solves signature cohesion while VO/aggregate solves invariant enforcement.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify --task document-input-cardinality-policy --env dev
# Passed with profile fast on attempt 1.
```

The controlled profile passed dependency/environment checks, localization,
knowledge validation, Dart formatting, Flutter analysis, custom lints, and CLI/
lint-package tests. Focused application tests were not required for docs-only work.

## Runtime Evidence

Not required. This task changes documentation and queued implementation plans only.

## Rollback

Remove ADR 0017, restore ADR 0016 status, and revert only the listed guide and
queued-plan edits.

## Risks And Mitigations

- Risk: contributors interpret primitive repository parameters as acceptable even when invariants exist.
- Mitigation: state that repositories accept primitives only when no deterministic invariant needs proof.
- Risk: cardinality thresholds become rigid rules.
- Mitigation: make cohesion and semantic meaning primary, with counts documented as heuristics.

## Completion Notes

ADR 0017 now separates grouping from validity and supersedes ADR 0016. Five
engineering guides and the two queued single-field auth plans use the same
cardinality/cohesion/invariant policy. No production or test code changed.

## Follow-ups

None. The API POST guide's historical ADR link is handled by a separate
docs-only alignment task because it was outside this task's authorized paths.
