# Strengthen The Login Validation Boundary

**Plan version:** 2
**Task ID:** login-validated-domain-boundary
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only the email/password login flow from a primitive request entity to the approved LoginInput -> LoginCredentials -> LoginRequestModel boundary, preserving observable login and API behavior.
**Allowed paths:** docs/exec-plans/active/2026-08-28_login-validated-domain-boundary.md, docs/exec-plans/completed/2026-08-28_login-validated-domain-boundary.md, lib/features/auth/domain/entity/login_request_entity.dart, lib/features/auth/domain/entity/login_request_entity.freezed.dart, lib/features/auth/domain/input/login_input.dart, lib/features/auth/domain/value/login_credentials.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/login_user_usecase.dart, lib/features/auth/data/model/remote/login_request_model.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart, test/features/auth/domain/value/login_credentials_test.dart, test/features/auth/domain/usecase/login_user_usecase_test.dart, test/features/auth/data/model/remote/login_request_model_test.dart, test/features/auth/data/repository/auth_repository_device_identity_test.dart, test/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit_test.dart, test/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit_persistence_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** auth.integration

Date: 2026-08-28
Related issue/PR: N/A

## Objective

Make the login repository boundary valid by construction: the presentation
submits raw `LoginInput`, the use case validates it into `LoginCredentials`,
and the data layer alone unwraps those value objects into `LoginRequestModel`.

## Constraints

- Architecture constraints:
  - Keep raw form input outside the repository contract.
  - Reuse `EmailAddress`, `LoginPassword`, `ValidationError`, and stable codes.
  - Keep API serialization owned by the data layer.
- Product/runtime constraints:
  - Preserve email trimming and password bytes exactly.
  - Preserve the current API payload and device metadata behavior.
  - Preserve inline client/server validation behavior and session login flow.
- Out of scope:
  - Registration, password recovery, profile, or other request-entity refactors.
  - New validation rules or UI behavior.
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

1. Given an invalid email or blank password, when login is submitted, then all local field errors are returned and the repository is not called.
2. Given valid credentials with surrounding email whitespace and password whitespace, when login is submitted, then the repository receives a valid `LoginCredentials` with normalized email and unchanged password.
3. Given valid credentials, when the repository builds the remote request, then the serialized API payload remains unchanged and device metadata is still attached.
4. Given a server field-validation failure, when it reaches the login Cubit, then its field errors remain mapped into login state.

## Acceptance Criteria

1. `LoginRequestEntity` is removed from the login flow.
2. `LoginInput` is the raw use-case input and can represent invalid form values.
3. `LoginCredentials` has no public unchecked constructor and aggregates field errors from existing VOs.
4. `AuthRepository.login` accepts only `LoginCredentials`.
5. `LoginRequestModel` maps from `LoginCredentials`, unwrapping primitives only in the data layer.
6. Focused tests cover invalid aggregation, normalization, repository typing, API mapping, and existing Cubit behavior.
7. Controlled full verification succeeds, with auth runtime evidence recorded when the configured environment supports it.

## Implementation Checklist

- [x] Add raw `LoginInput` and validated `LoginCredentials`.
- [x] Update the use case, repository contract/implementation, data mapper, and Cubit.
- [x] Remove the obsolete generated `LoginRequestEntity` implementation; retain only a temporary compatibility alias for registered integration fakes.
- [x] Update and add focused tests.
- [x] Run controlled verification and record evidence.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-28: Use one explicit three-stage input pattern for login -> establishes the approved scalable boundary without widening the task to other flows.
- 2026-08-28: Keep `LoginInput` raw and make `LoginCredentials` privately constructed -> separates form/application input from repository-safe domain data.
- 2026-08-28: Aggregate all local field errors -> preserves multi-field form feedback instead of fail-fast validation.

## Verification

Executed:

```bash
fvm flutter test test/features/auth/domain/value/login_credentials_test.dart test/features/auth/domain/usecase/login_user_usecase_test.dart test/features/auth/data/model/remote/login_request_model_test.dart test/features/auth/data/repository/auth_repository_device_identity_test.dart test/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit_test.dart test/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit_persistence_test.dart
# Passed: 15 tests.

dart run mobile_core_kit_cli:mobilekit task verify --task login-validated-domain-boundary --env dev
# Passed on attempt 3 with profile full: codegen, format, analyzer, custom lints,
# CLI/lint/application tests, contract/oracle checks, and duplication profiles.
```

## Runtime Evidence

The registered `auth.integration` target was attempted twice on the available
Linux device. The runtime harness always supplied `--flavor dev`, while Flutter
supports that flag only for Android, macOS, and iOS, so both attempts stopped
before app launch. Sanitized evidence:

- `_artifacts/mobile/20260828_225858/evidence.json`
- `_artifacts/mobile/20260828_225910/evidence.json`

No compatible Android/iOS device was connected. Static full verification and
the existing auth integration target's compile-time coverage remain available;
device runtime success is not claimed.

## Rollback

Restore `LoginRequestEntity` as the use-case and repository input, restore
`LoginRequestModel.fromEntity`, remove the two new domain types, and revert the
focused tests. No persisted data or external contract needs rollback.

## Risks And Mitigations

- Risk: password normalization changes while crossing the new boundary.
- Mitigation: preserve the exact password string and assert it in unit tests.
- Risk: the remote payload changes while mapper ownership moves.
- Mitigation: assert `fromCredentials(...).toJson()` and device metadata behavior.
- Risk: callers bypass or cannot construct the repository input.
- Mitigation: expose only the validated factory result and update all compile-time call sites.

## Completion Notes

Implemented the approved raw-input to validated-domain boundary for production
login code. A temporary deprecated alias remains solely because the two
registered integration fakes were outside this task's immutable path authority;
a narrow follow-up will migrate those fakes and remove the alias.

## Follow-ups

- [x] Follow-up required: migrate registered integration fakes from the deprecated login alias, then delete the alias.
- [x] Follow-up required: teach runtime evidence not to pass `--flavor` to Linux devices; this needs a separately authorized harness task.
