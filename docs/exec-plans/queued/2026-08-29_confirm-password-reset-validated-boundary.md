# Strengthen The Password Reset Confirmation Boundary

**Plan version:** 2
**Task ID:** confirm-password-reset-validated-boundary
**Status:** queued
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only password-reset confirmation from a primitive request entity to PasswordResetConfirmationInput -> PasswordResetCredentials -> PasswordResetConfirmRequestModel, preserving token normalization, password bytes, deep-link behavior, errors, session revocation semantics, and payload shape.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_confirm-password-reset-validated-boundary.md, docs/exec-plans/active/2026-08-29_confirm-password-reset-validated-boundary.md, docs/exec-plans/completed/2026-08-29_confirm-password-reset-validated-boundary.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/password_reset_confirm_request_entity.dart, lib/features/auth/domain/entity/password_reset_confirm_request_entity.freezed.dart, lib/features/auth/domain/input/password_reset_confirmation_input.dart, lib/features/auth/domain/value/password_reset_credentials.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/confirm_password_reset_usecase.dart, lib/features/auth/data/model/remote/password_reset_confirm_request_model.dart, lib/features/auth/data/model/remote/password_reset_confirm_request_model.freezed.dart, lib/features/auth/data/model/remote/password_reset_confirm_request_model.g.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart, test/features/auth/domain/value/password_reset_credentials_test.dart, test/features/auth/domain/usecase/confirm_password_reset_usecase_test.dart, test/features/auth/data/model/remote/password_reset_confirm_request_model_test.dart, test/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit_test.dart, test/navigation/app_redirect_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** auth.integration, startup.integration

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Make reset confirmation valid by construction at the repository boundary while
keeping raw deep-link/form values at the application boundary.

## Constraints

- Architecture constraints:
  - Validate with existing `ResetToken` and `Password` VOs.
  - Use a private `PasswordResetCredentials` aggregate because token and password form one command.
  - Unwrap primitives only in the data-layer request model.
- Product/runtime constraints:
  - Trim the token exactly as today and preserve new-password bytes exactly.
  - Preserve token ingestion, redirect/resume behavior, inline errors, payload, and all-session revocation semantics.
- Out of scope:
  - Reset-request email delivery, new password rules, or navigation redesign.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: yes
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given invalid token and password, when submitted, then both deterministic errors are returned and the repository is not called.
2. Given a valid token with whitespace and a password containing whitespace, when submitted, then only the token is normalized.
3. Given valid credentials received through the reset deep link, when serialized, then navigation and wire payload remain unchanged.
4. Given backend token or password rejection, when returned, then existing field/failure behavior is preserved.

## Acceptance Criteria

1. The primitive reset-confirm request entity and generated file are removed.
2. `PasswordResetConfirmationInput` can represent raw invalid values.
3. `PasswordResetCredentials.create()` aggregates failures and has no public unchecked constructor.
4. Repository and request model accept/map only validated credentials.
5. Unit, Cubit, auth integration, redirect, and startup/deep-link tests preserve behavior.

## Implementation Checklist

- [ ] Add raw input and validated credentials.
- [ ] Migrate use case, repository contract/implementation, request model, and Cubit.
- [ ] Remove the old entity and generated source.
- [ ] Add aggregate and mapper tests; update existing focused and navigation tests.
- [ ] Run controlled full verification and collect auth/startup runtime evidence where supported.
- [ ] Complete and archive this plan.

## Decision Log

- 2026-08-29: Use one validated aggregate -> reset token and new password form a cohesive security command.
- 2026-08-29: Keep password unnormalized -> password whitespace is intentional input.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task confirm-password-reset-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task confirm-password-reset-validated-boundary --env dev
```

Run focused aggregate, use-case, mapper, Cubit, redirect, and deep-link tests in
the inner loop.

## Runtime Evidence

Exercise reset-link ingestion, invalid submission, and successful confirmation
on a supported mobile target. Record sanitized auth/startup evidence or the
precise environment limitation.

## Rollback

Restore the request entity and previous signatures/mappers. No persisted-data
or API migration requires reversal.

## Risks And Mitigations

- Risk: deep-link token normalization or password bytes change.
- Mitigation: assert each independently through input, credentials, and JSON.
- Risk: navigation or session-revocation behavior regresses.
- Mitigation: retain startup, redirect, auth integration, and failure-path coverage.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
