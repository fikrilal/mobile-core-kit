# Strengthen The Password Reset Request Boundary

**Plan version:** 2
**Task ID:** request-password-reset-validated-boundary
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only the password-reset email request flow so the use case accepts one raw email String, validates it into EmailAddress, and the repository accepts that VO, preserving anti-enumeration behavior, normalization, errors, and payload shape.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_request-password-reset-validated-boundary.md, docs/exec-plans/active/2026-08-29_request-password-reset-validated-boundary.md, docs/exec-plans/completed/2026-08-29_request-password-reset-validated-boundary.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/password_reset_request_entity.dart, lib/features/auth/domain/entity/password_reset_request_entity.freezed.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/request_password_reset_usecase.dart, lib/features/auth/data/model/remote/password_reset_request_model.dart, lib/features/auth/data/model/remote/password_reset_request_model.freezed.dart, lib/features/auth/data/model/remote/password_reset_request_model.g.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_cubit.dart, test/features/auth/domain/usecase/request_password_reset_usecase_test.dart, test/features/auth/data/model/remote/password_reset_request_model_test.dart, test/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_cubit_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 75m
**Oracle IDs:** auth.integration

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Prevent raw or invalid email strings from reaching the password-reset repository
without adding a one-field aggregate that duplicates `EmailAddress`.

## Constraints

- Architecture constraints:
  - Presentation submits one raw email `String`; the use case remains the final gate.
  - `AuthRepository.requestPasswordReset` accepts `EmailAddress` directly.
  - The request model owns conversion from the VO to the wire primitive.
- Product/runtime constraints:
  - Preserve email trimming/normalization and field error codes.
  - Preserve the no-account-enumeration success behavior and payload shape.
- Out of scope:
  - Confirm-reset, email-verification, or email-delivery behavior.
  - A dedicated aggregate for a single email VO.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given an invalid email, when reset is requested, then validation fails and the repository is not called.
2. Given an email with surrounding whitespace, when reset is requested, then the repository receives the normalized `EmailAddress`.
3. Given a valid email, when serialized, then the existing `{email: ...}` payload and anti-enumeration response behavior remain unchanged.

## Acceptance Criteria

1. `PasswordResetRequestEntity` and its generated file are removed from this flow.
2. The use case accepts one raw `String`; `EmailAddress` represents the validated state.
3. The repository contract cannot accept an arbitrary email `String`.
4. Mapper, use-case, Cubit, and auth integration tests preserve observable behavior.

## Implementation Checklist

- [x] Migrate presentation/use-case input to one raw email `String` and the repository to `EmailAddress`.
- [x] Map `EmailAddress` in `PasswordResetRequestModel` and remove the old entity.
- [x] Update focused tests and integration fakes.
- [x] Run controlled full verification and collect auth runtime evidence where supported.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-29: Use a raw `String` at the use-case boundary and `EmailAddress` at the repository boundary -> one-field `XInput` and aggregate wrappers add no grouping or validity semantics.
- 2026-08-29: Add `startup_deep_link_resume_test.dart` to allowed paths -> its fake implements the full `AuthRepository` contract, so the signature change must update it too.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task request-password-reset-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task request-password-reset-validated-boundary --env dev
```

Run focused use-case, request-model, Cubit, and auth integration tests in the
inner loop.

Result: `task verify` passed with profile full on attempt 1, including 561
application tests, analyzer and custom lints, codegen freshness, knowledge
validation, and the duplication advisory.

## Runtime Evidence

Not collected. No mobile device or emulator is attached to this environment
(`flutter devices` reports only linux/chrome hosts), so the `auth.integration`
oracle could not be exercised. The invalid/valid request behavior remains
covered by the focused use-case, mapper, and Cubit tests updated in this
change set.

## Rollback

Restore the request entity and previous repository/model/Cubit signatures. No
backend or persisted-data rollback is required.

## Risks And Mitigations

- Risk: normalized email or anti-enumeration behavior changes.
- Mitigation: assert normalized payload and identical success handling for backend responses.

## Completion Notes

`RequestPasswordResetUseCase` now accepts one raw email `String`,
`EmailAddress` is the validated state, and `AuthRepository.requestPasswordReset`
accepts that VO directly. `PasswordResetRequestModel.fromEmail` owns the wire
mapping and the primitive request entity is removed. Presentation submits the
unchanged raw scalar; normalization happens in the VO. Anti-enumeration
success handling and the `{email: ...}` payload are unchanged. The startup
deep-link integration fake was added to scope by decision-log amendment and
the task was re-baselined before editing.

## Follow-ups

None. No unresolved debt recorded in `docs/exec-plans/tech_debt_tracker.md`.
