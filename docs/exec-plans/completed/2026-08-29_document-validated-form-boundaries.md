# Document Validated Form Boundaries

**Plan version:** 2
**Task ID:** document-validated-form-boundaries
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Record the approved template-level raw input to validated aggregate form boundary in an ADR and align existing engineering guides with the implemented LoginInput/RegisterInput patterns, without changing production or test code.
**Allowed paths:** docs/exec-plans/active/2026-08-29_document-validated-form-boundaries.md, docs/exec-plans/completed/2026-08-29_document-validated-form-boundaries.md, ADR/records/0016-validated-form-boundaries.md, docs/engineering/validation_architecture.md, docs/engineering/value_objects_validation.md, docs/engineering/validation_cookbook.md, docs/engineering/testing_strategy.md, docs/engineering/data_domain_guide.md, docs/engineering/model_entity_guide.md, docs/engineering/api/api_usage_post.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 45m

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Make repository guidance agree with the validated form boundary already used by
login and registration, and preserve the architectural rationale as ADR 0016.

## Constraints

- Architecture constraints:
  - Distinguish raw application input, validated domain aggregates, and wire models.
  - Keep use cases as the final deterministic client-side gate.
  - Do not ban request entities for operations that have no validated form invariants.
- Product/runtime constraints:
  - Documentation only; no runtime behavior or API contract changes.
- Out of scope:
  - Further auth refactors, lint rules, shared validator abstractions, or source-local README files.
  - Commit, push, or PR creation.

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

1. Given a contributor implementing a validated form, when they read the ADR and engineering guides, then they see one consistent `XInput -> validated aggregate -> RequestModel` pattern.
2. Given a non-form operation without deterministic input invariants, when a contributor reads the decision, then they are not required to add an aggregate merely for ceremony.
3. Given the existing login/register examples, when documentation references concrete code, then it uses current types and paths rather than removed request entities.

## Acceptance Criteria

1. ADR 0016 records context, alternatives, decision, scope boundary, consequences, and confirmation.
2. Validation and VO guides explain aggregate factories and typed repository contracts.
3. Cookbook and testing examples use raw input plus validated aggregate rather than primitive request entities.
4. Data/model/API guides distinguish validated form submissions from ordinary entity/model mapping.
5. No `LoginRequestEntity` or `RegisterRequestEntity` references remain in active engineering documentation.
6. Repository knowledge and local-link validation succeed.

## Implementation Checklist

- [x] Add ADR 0016.
- [x] Align validation and testing guides.
- [x] Align data-domain, model/entity, and POST guides.
- [x] Verify links, stale references, and repository knowledge.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-29: Create one ADR and update existing guides -> separate rationale from how-to guidance without adding a duplicate validation guide.
- 2026-08-29: Scope the decision to validated form submissions -> avoid forcing aggregates onto pass-through operations with no invariants.

## Verification

- `dart run mobile_core_kit_cli:mobilekit task verify --task document-validated-form-boundaries --env dev`
  - Passed with the `fast` profile on attempt 1.
  - Included dependency and environment checks, build configuration, localization,
    repository knowledge, Dart formatting, Flutter analysis, custom lints, CLI tests,
    and lint-package tests.
- Stale-reference search confirmed that active engineering documentation no longer
  mentions `LoginRequestEntity`, `RegisterRequestEntity`, or
  `CreateBookReviewRequestEntity`.
- Markdown fence-balance and `git diff --check` checks passed.

## Runtime Evidence

Not required. This task changes documentation only.

## Rollback

Remove ADR 0016 and revert only the listed guide updates.

## Risks And Mitigations

- Risk: guidance overgeneralizes the pattern into mandatory ceremony.
- Mitigation: state explicit applicability and non-applicability criteria in the ADR and guides.
- Risk: examples drift from actual login/register code.
- Mitigation: use current searchable types and run stale-reference checks.

## Completion Notes

- Added ADR 0016 as the template-level decision for validated form boundaries.
- Updated seven engineering guides to distinguish raw application input,
  validated domain aggregates, and wire request models.
- Kept non-form and invariant-free operations outside the mandatory aggregate
  pattern to avoid ceremony.
- No production code, tests, or API contracts were changed by this task.

## Follow-ups

None. No unresolved debt was introduced by this documentation task.
