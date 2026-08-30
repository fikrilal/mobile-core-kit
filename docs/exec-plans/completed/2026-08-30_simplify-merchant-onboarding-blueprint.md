# Simplify Merchant Onboarding Validation Blueprint

**Plan version:** 2
**Task ID:** simplify-merchant-onboarding-blueprint
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Revise the existing merchant-onboarding validation case study into a concise four-step, mobile-first implementation blueprint and update its feature-index description, without changing production code or contracts.
**Allowed paths:** docs/exec-plans/active/2026-08-30_simplify-merchant-onboarding-blueprint.md, docs/exec-plans/completed/2026-08-30_simplify-merchant-onboarding-blueprint.md, docs/explainers/features/README.md, docs/explainers/features/merchant_onboarding/validation_architecture_blueprint.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 90m

Date: 2026-08-30
Related issue/PR: N/A

## Objective

Replace the oversized merchant-onboarding specification with a realistic
four-step mobile case study that remains rich enough to teach field-level,
conditional, cross-row, cross-step, final-gate, and server validation.

## Constraints

- Architecture constraints:
  - Follow ADR 0017's cardinality, cohesion, and invariant policy.
  - Keep presentation input, validated domain aggregates, and request models distinct.
  - Keep the use case as the final local validation gate.
- Product/runtime constraints:
  - Use exactly four user-facing steps: business profile, owners, settlement, and review.
  - Use backend reference-data IDs for selectable values and treat labels as presentation data.
  - Define each retained field and identify its validation owner.
- Out of scope:
  - Image or document upload, address/country/city fields, persistent drafts, production compliance lifecycle, detailed API design, Dart implementation, API/OpenAPI changes, commit, push, or PR creation.

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

1. Given an engineer learning the architecture, when they read the blueprint, then they can trace raw input through field validation, aggregate construction, the use-case gate, mapping, and server validation.
2. Given a mobile user completing the flow, when they move through it, then only four compact steps are required and no file, location, or persistent-draft workflow exists.
3. Given selectable business values, when a selection is stored or submitted, then the stable backend ID is used rather than a display label.
4. Given owner or settlement relationships, when final validation runs, then cross-row and cross-step failures have deterministic, routable error paths.

## Acceptance Criteria

1. The blueprint defines exactly four mobile-first steps and every retained field.
2. It contains concrete examples of field, conditional, cross-row, cross-step, final-gate, and server-authoritative validation.
3. It defines reference-data handling, presentation state, domain aggregates, request mapping, failure routing, privacy, tests, and phased implementation without production-scale ceremony.
4. Image/document upload, geographic fields, persistent drafts, and compliance workflow are excluded.
5. The feature explainer index reflects the simplified scope.
6. Controlled docs verification, knowledge validation, and diff checks pass.

## Implementation Checklist

- [x] Rewrite the field catalog and rule matrix around four steps.
- [x] Simplify state, domain, repository, privacy, and test guidance.
- [x] Update the feature explainer index.
- [x] Verify and archive this plan.

## Decision Log

- 2026-08-30: Use four steps -> enough complexity to demonstrate the architecture while remaining plausible on mobile.
- 2026-08-30: Use reference-data IDs for dropdowns -> stable backend values without free-text inconsistency.
- 2026-08-30: Keep drafts in memory only -> persistence and recovery obscure the validation lesson.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify \
  --task simplify-merchant-onboarding-blueprint --env dev
# Passed with profile fast on attempt 1.
```

The controlled profile passed dependency and environment checks, localization,
repository knowledge validation, Dart formatting, Flutter analysis, custom
lints, CLI tests, and lint-package tests. Focused application tests were not
required for this docs-only change.

## Runtime Evidence

Not required. This task changes documentation only.

## Rollback

Restore the prior blueprint content and feature-index description, then remove this plan.

## Risks And Mitigations

- Risk: simplification removes the rules needed to demonstrate aggregate validation.
- Mitigation: retain owner totals, unique primary contact, conditional settlement ownership, declarations, and server checks.
- Risk: illustrative rules are mistaken for production policy.
- Mitigation: label the scenario fictional and keep dynamic or authoritative decisions at the server boundary.

## Completion Notes

Replaced the six-step, production-shaped specification with a four-step
mobile-first case. The revised blueprint retains detailed fields and meaningful
validation examples while removing uploads, geographic address data,
persistent drafts, and post-submission compliance lifecycle. The feature index
now describes the smaller scope.

## Follow-ups

None. Implementing the fictional case remains a separate, explicitly authorized
task rather than repository debt.
