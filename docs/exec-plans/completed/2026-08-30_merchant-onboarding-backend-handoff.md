# Write Merchant Onboarding Backend Handoff

**Plan version:** 2
**Task ID:** merchant-onboarding-backend-handoff
**Status:** completed
**Owner:** Codex
**Risk:** low
**Authority:** Create and index a backend handoff specification plus a reusable implementation-agent prompt for the four-step merchant-onboarding case, without changing either application's production code, backend contracts, branches, or Git history.
**Allowed paths:** docs/exec-plans/active/2026-08-30_merchant-onboarding-backend-handoff.md, docs/exec-plans/completed/2026-08-30_merchant-onboarding-backend-handoff.md, docs/explainers/features/README.md, docs/explainers/features/merchant_onboarding/backend_handoff.md, docs/explainers/features/merchant_onboarding/backend_implementation_agent_prompt.md
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 90m

Date: 2026-08-30
Related issue/PR: N/A

## Objective

Provide two self-contained artifacts that let another agent implement the
mobile case study in `backend-core-kit`: a backend-facing behavior/contract
handoff and an operational prompt that starts work on an isolated branch.

## Constraints

- Architecture constraints:
  - Ground the handoff in both repositories' current architecture and API standards.
  - Keep client validation, backend business rules, transport validation, and persistence ownership explicit.
  - Preserve the intentionally small four-step product scope.
- Product/runtime constraints:
  - Use stable backend IDs for dropdown/reference data.
  - Do not persist or echo the raw bank account number in the educational implementation.
  - Require authenticated, idempotent submission and deterministic field paths.
- Out of scope:
  - Backend code, Prisma/OpenAPI mutation, external bank integration, mobile implementation, creating a backend branch/worktree, commit, push, PR, migration execution, or deployment.

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

1. Given a backend engineer, when they read the handoff, then endpoint behavior, payloads, validation ownership, persistence, failures, privacy, and tests are implementable without reopening settled mobile decisions.
2. Given an implementation agent in the backend checkout, when it follows the prompt, then it creates an isolated branch/worktree before source edits and leaves the dirty development checkout untouched.
3. Given a retry or invalid request, when the backend implementation is complete, then idempotency and field-error routing match repository standards and the mobile blueprint.
4. Given sensitive settlement input, when submission is handled, then the raw account number is neither logged, returned, nor persisted by this educational scope.

## Acceptance Criteria

1. The handoff defines the two endpoints, request/response shapes, catalogs, error codes/paths, validation matrix, persistence model, and non-goals.
2. The implementation prompt identifies the repository, branch/worktree workflow, required reading, risk, phases, verification, and publication boundary.
3. Both artifacts link to the mobile blueprint and relevant backend sources of truth.
4. The feature index links both documents.
5. Controlled docs verification and repository knowledge checks pass.

## Implementation Checklist

- [x] Write the backend handoff.
- [x] Write the implementation-agent prompt.
- [x] Update the feature explainer index.
- [x] Verify and archive this plan.

## Decision Log

- 2026-08-30: Keep handoff artifacts in the mobile repository -> the backend development checkout must remain unchanged until its receiving agent creates an isolated branch.
- 2026-08-30: Use code-owned reference catalogs for the first implementation -> stable values without adding catalog administration or tables.
- 2026-08-30: Persist only bank last-four digits -> retain the validation exercise without introducing unsafe credential storage or a tokenization integration.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify \
  --task merchant-onboarding-backend-handoff --env dev
# Passed with profile fast on attempt 1.
```

The controlled profile passed dependencies, environment and localization
checks, repository knowledge validation, formatting, Flutter analysis, custom
lints, CLI tests, and lint-package tests. Focused application tests were not
required for this docs-only task.

## Runtime Evidence

Not required. This task changes documentation only.

## Rollback

Remove the two handoff artifacts and their index entries, then remove this plan.

## Risks And Mitigations

- Risk: the handoff is mistaken for an approved production banking design.
- Mitigation: label it educational and make production account tokenization a separate integration decision.
- Risk: the receiving agent edits the dirty backend development checkout.
- Mitigation: make isolated branch/worktree creation the first mutating instruction and require a clean candidate worktree.

## Completion Notes

Created a backend behavior handoff grounded in the current NestJS, Prisma,
OpenAPI, error, idempotency, and test conventions. Created a separate copy-ready
agent prompt that requires an isolated `agent/merchant-onboarding` worktree,
a high-risk backend execution plan, full implementation and runtime evidence,
and fresh authority for every publication or operational action. The backend
checkout and branch state were not changed.

## Follow-ups

None. Production account tokenization, payout integration, and post-submission
lifecycle are explicit non-goals rather than debt in this educational case.
