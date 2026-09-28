# Write Merchant Onboarding Validation Blueprint

**Plan version:** 2
**Task ID:** merchant-onboarding-validation-blueprint
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Create one implementation-grade merchant-onboarding validation case-study specification and index it under feature explainers, without implementing production/test code, API contracts, or an ADR.
**Allowed paths:** docs/exec-plans/active/2026-08-30_merchant-onboarding-validation-blueprint.md, docs/exec-plans/completed/2026-08-30_merchant-onboarding-validation-blueprint.md, docs/explainers/features/README.md, docs/explainers/features/merchant_onboarding/validation_architecture_blueprint.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 90m

Date: 2026-08-30
Related issue/PR: N/A

## Objective

Provide the primary implementation reference for a realistic multi-step merchant
onboarding case study that exercises raw drafts, field VOs, nested validated
aggregates, cross-step rules, document uploads, server-authoritative checks,
privacy, persistence, error routing, and testing.

## Constraints

- Architecture constraints:
  - Follow ADR 0017's cardinality/cohesion/invariant policy.
  - Separate presentation draft state, final validated domain application, and wire models.
  - Keep server/dynamic validation authoritative and explicit.
- Product/runtime constraints:
  - Use fictional educational policy, not legal/compliance advice.
  - Define every field, conditional requirement, normalization, error path, and ownership decision needed for implementation.
- Out of scope:
  - Dart implementation, generated code, routes, API/OpenAPI mutation, backend implementation, commit, push, or PR creation.

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

1. Given an engineer starting the case study, when they read the blueprint, then every step and field has an implementable type, requirement, normalization, deterministic rule, and error path.
2. Given a rule spanning owners, settlement, documents, or consent, when implemented, then its final-gate owner and server-authoritative counterpart are unambiguous.
3. Given an interrupted mobile flow, when implementation is planned, then draft persistence, sensitive-data retention, file handling, and recovery behavior are defined.
4. Given validation and server failures, when mapped to UI, then the target step/field and stable code are defined.

## Acceptance Criteria

1. The blueprint covers product scope, lifecycle, all fields, rules, type architecture, state ownership, persistence, uploads, API assumptions, privacy, accessibility, analytics, testing, and acceptance scenarios.
2. A compact diagram clarifies raw-draft to validated-application and remote boundaries.
3. Proposed API surfaces are clearly marked as hypothetical and do not claim an existing OpenAPI contract.
4. The feature explainer index links the blueprint.
5. Repository knowledge, Markdown structure, and diff checks succeed.

## Implementation Checklist

- [x] Write the complete blueprint with field catalog and rule matrices.
- [x] Define architecture, lifecycle, failure mapping, persistence, and privacy.
- [x] Define test and acceptance matrices plus implementation sequencing.
- [x] Index the blueprint.
- [x] Verify and archive this plan.

## Decision Log

- 2026-08-30: Use fictional B2B merchant onboarding -> rich business invariants without claiming production compliance policy.
- 2026-08-30: Keep one comprehensive blueprint -> the user requested a primary build reference rather than fragmented notes.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-validation-blueprint --env dev
# Passed with profile fast on attempt 1.
```

The controlled profile passed dependency/environment checks, localization,
knowledge validation, Dart formatting, Flutter analysis, custom lints, and CLI/
lint-package tests. Focused application tests were not required for docs-only work.

## Runtime Evidence

Not required. This task creates documentation only.

## Rollback

Remove the blueprint and its feature-index entry.

## Risks And Mitigations

- Risk: illustrative rules are mistaken for legal or backend truth.
- Mitigation: label the policy fictional and proposed API contract explicitly.
- Risk: the document becomes exhaustive but not actionable.
- Mitigation: use field/rule tables, ownership boundaries, stable identifiers, and acceptance scenarios.

## Completion Notes

Created and indexed one implementation-grade blueprint covering six onboarding
steps, every editable/system field, conditional and cross-step invariants,
dynamic owner/document error paths, draft/upload/submission boundaries,
proposed API semantics, privacy, accessibility, analytics, testing, and phased
implementation. No production, test, or OpenAPI files changed.

## Follow-ups

None. Production legal policy and backend/OpenAPI adoption intentionally require
separate reviewed work rather than being tracked as debt in this case study.
