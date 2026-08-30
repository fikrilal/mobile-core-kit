# Strengthen The Change Password Validation Boundary

**Plan version:** 2
**Task ID:** change-password-validated-boundary
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only the authenticated change-password flow from a primitive request entity to ChangePasswordInput -> PasswordChangeCredentials -> ChangePasswordRequestModel, preserving password bytes, validation feedback, session behavior, and the backend payload.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_change-password-validated-boundary.md, docs/exec-plans/active/2026-08-29_change-password-validated-boundary.md, docs/exec-plans/completed/2026-08-29_change-password-validated-boundary.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/change_password_request_entity.dart, lib/features/auth/domain/entity/change_password_request_entity.freezed.dart, lib/features/auth/domain/input/change_password_input.dart, lib/features/auth/domain/value/password_change_credentials.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/change_password_usecase.dart, lib/features/auth/data/model/remote/change_password_request_model.dart, lib/features/auth/data/model/remote/change_password_request_model.freezed.dart, lib/features/auth/data/model/remote/change_password_request_model.g.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart, test/features/auth/domain/value/password_change_credentials_test.dart, test/features/auth/domain/usecase/change_password_usecase_test.dart, test/features/auth/data/model/remote/change_password_request_model_test.dart, test/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit_test.dart
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

- [x] Add `ChangePasswordInput` and `PasswordChangeCredentials`.
- [x] Migrate use case, repository contract/implementation, request model, and Cubit.
- [x] Remove the primitive request entity and generated source.
- [x] Add aggregate and request-model tests; update existing focused tests and integration fakes.
- [x] Run controlled full verification and collect auth runtime evidence where supported.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-29: Use a cohesive aggregate rather than two VO parameters -> the operation owns a cross-field invariant.
- 2026-08-29: Preserve raw password bytes -> trimming credentials would be a behavioral and security regression.
- 2026-08-29: Add `startup_deep_link_resume_test.dart` to allowed paths -> its fake implements the full `AuthRepository` contract, so the signature change must update it too.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task change-password-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task change-password-validated-boundary --env dev
```

Also run focused aggregate, use-case, mapper, repository, and Cubit tests during
the inner loop.

Result: `task verify` passed with profile full on attempt 2. Attempt 1 failed
on one analyzer finding (unused import in the new aggregate test); the repair
was recorded with `mobilekit task repair` (1/3 repair budget used). Final run
covered all application tests, analyzer and custom lints, codegen freshness,
knowledge validation, and the duplication advisory.

## Runtime Evidence

Not collected. No mobile device or emulator is attached to this environment
(`flutter devices` reports only linux/chrome hosts), so the `auth.integration`
oracle could not be exercised. Byte preservation and the cross-field rule
remain covered by the aggregate, use-case, mapper, and Cubit tests updated in
this change set.

## Rollback

Restore `ChangePasswordRequestEntity`, repository and model mappings, and the
previous Cubit/use-case signatures. No persisted data or API rollback is needed.

## Risks And Mitigations

- Risk: password normalization changes.
- Mitigation: assert exact string preservation through credentials and JSON.
- Risk: the cross-field failure changes field or code.
- Mitigation: retain `newPassword` and `passwordSameAsCurrent` assertions.

## Completion Notes

`ChangePasswordInput` now represents the raw form submission and
`PasswordChangeCredentials.create()` aggregates field failures plus the
`passwordSameAsCurrent` cross-field rule with no public unchecked constructor.
The use case is the final gate, `AuthRepository.changePassword` accepts only
the validated credentials, and `ChangePasswordRequestModel.fromCredentials`
unwraps them in the data layer. The primitive request entity is removed.
Password bytes are preserved end to end (VOs do not trim), presentation
submits the unchanged raw input, and the confirm-password field remains a
presentation-only concern. The startup deep-link integration fake was added
to scope by decision-log amendment and the task was re-baselined before
editing.

## Follow-ups

None. No unresolved debt recorded in `docs/exec-plans/tech_debt_tracker.md`.
