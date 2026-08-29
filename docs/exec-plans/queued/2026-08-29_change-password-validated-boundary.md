# Strengthen The Change Password Validation Boundary

**Plan version:** 2
**Task ID:** change-password-validated-boundary
**Status:** queued
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only the authenticated change-password flow from a primitive request entity to ChangePasswordInput -> PasswordChangeCredentials -> ChangePasswordRequestModel, preserving password bytes, validation feedback, session behavior, and the backend payload.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_change-password-validated-boundary.md, docs/exec-plans/active/2026-08-29_change-password-validated-boundary.md, docs/exec-plans/completed/2026-08-29_change-password-validated-boundary.md, integration_test/auth_happy_path_test.dart, lib/features/auth/domain/entity/change_password_request_entity.dart, lib/features/auth/domain/entity/change_password_request_entity.freezed.dart, lib/features/auth/domain/input/change_password_input.dart, lib/features/auth/domain/value/password_change_credentials.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/change_password_usecase.dart, lib/features/auth/data/model/remote/change_password_request_model.dart, lib/features/auth/data/model/remote/change_password_request_model.freezed.dart, lib/features/auth/data/model/remote/change_password_request_model.g.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart, test/features/auth/domain/value/password_change_credentials_test.dart, test/features/auth/domain/usecase/change_password_usecase_test.dart, test/features/auth/data/model/remote/change_password_request_model_test.dart, test/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** auth.integration

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Make the change-password repository boundary valid by construction while
retaining the use case as the final gate for current-password presence, new
password policy, and the `newPassword != currentPassword` cross-field rule.

## Constraints

- Architecture constraints:
  - Use raw `ChangePasswordInput` at the application boundary.
  - Give `PasswordChangeCredentials` a private unchecked constructor and field VOs.
  - Let only the data layer unwrap credentials into the request model.
- Product/runtime constraints:
  - Preserve current and new password bytes exactly; passwords must not be trimmed.
  - Preserve inline field codes and server-failure mapping.
  - Preserve the backend payload and current-session behavior.
- Out of scope:
  - New password policy, password-reset flows, login/register changes, or shared generic validators.
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

1. Given empty current password and invalid new password, when submitted, then all deterministic field failures are returned and the repository is not called.
2. Given equal valid current and new passwords, when submitted, then `passwordSameAsCurrent` is returned and the repository is not called.
3. Given valid distinct passwords containing whitespace, when submitted, then the repository receives validated credentials with the exact original password bytes.
4. Given valid credentials, when serialized, then the backend request payload is unchanged.

## Acceptance Criteria

1. `ChangePasswordRequestEntity` and its generated file are removed from the flow.
2. `ChangePasswordInput` can represent raw invalid form values.
3. `PasswordChangeCredentials.create()` aggregates field and cross-field failures and exposes no public unchecked constructor.
4. `AuthRepository.changePassword` accepts only `PasswordChangeCredentials`.
5. `ChangePasswordRequestModel` maps from credentials in the data layer.
6. Use-case, aggregate, mapper, repository-facing, Cubit, and auth integration coverage preserve current behavior.

## Implementation Checklist

- [ ] Add `ChangePasswordInput` and `PasswordChangeCredentials`.
- [ ] Migrate use case, repository contract/implementation, request model, and Cubit.
- [ ] Remove the primitive request entity and generated source.
- [ ] Add aggregate and request-model tests; update existing focused tests and integration fakes.
- [ ] Run controlled full verification and collect auth runtime evidence where supported.
- [ ] Complete and archive this plan.

## Decision Log

- 2026-08-29: Use a cohesive aggregate rather than two VO parameters -> the operation owns a cross-field invariant.
- 2026-08-29: Preserve raw password bytes -> trimming credentials would be a behavioral and security regression.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task change-password-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task change-password-validated-boundary --env dev
```

Also run focused aggregate, use-case, mapper, repository, and Cubit tests during
the inner loop.

## Runtime Evidence

Exercise a successful password change and deterministic invalid submissions on
a supported mobile target following `docs/engineering/mobile_runtime_harness.md`.
Record artifacts or the precise environment limitation.

## Rollback

Restore `ChangePasswordRequestEntity`, repository and model mappings, and the
previous Cubit/use-case signatures. No persisted data or API rollback is needed.

## Risks And Mitigations

- Risk: password normalization changes.
- Mitigation: assert exact string preservation through credentials and JSON.
- Risk: the cross-field failure changes field or code.
- Mitigation: retain `newPassword` and `passwordSameAsCurrent` assertions.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
