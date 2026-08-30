# Strengthen The Register Validation Boundary

**Plan version:** 2
**Task ID:** register-validated-domain-boundary
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only the email/password registration flow from a primitive request entity to the approved RegisterInput -> RegistrationCredentials -> RegisterRequestModel boundary, preserving observable registration, session, and API behavior, and align the validation architecture documentation with the typed repository boundary.
**Allowed paths:** docs/exec-plans/active/2026-08-29_register-validated-domain-boundary.md, docs/exec-plans/completed/2026-08-29_register-validated-domain-boundary.md, docs/engineering/validation_architecture.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/register_request_entity.dart, lib/features/auth/domain/entity/register_request_entity.freezed.dart, lib/features/auth/domain/input/register_input.dart, lib/features/auth/domain/value/registration_credentials.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/register_user_usecase.dart, lib/features/auth/data/model/remote/register_request_model.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/registration/presentation/cubit/register/register_cubit.dart, test/features/auth/domain/value/registration_credentials_test.dart, test/features/auth/domain/usecase/register_user_usecase_test.dart, test/features/auth/data/model/remote/register_request_model_test.dart, test/features/auth/data/repository/auth_repository_device_identity_test.dart, test/features/auth/subfeatures/registration/presentation/cubit/register/register_cubit_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** auth.integration

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Make the register repository boundary valid by construction: presentation
submits raw `RegisterInput`, the use case validates it into
`RegistrationCredentials`, and the data layer alone unwraps those value
objects into `RegisterRequestModel`.

## Constraints

- Architecture constraints:
  - Keep raw form input outside the repository contract.
  - Reuse `EmailAddress`, `Password`, `ValidationError`, and stable codes.
  - Keep API serialization owned by the data layer.
- Product/runtime constraints:
  - Preserve email trimming and password bytes exactly.
  - Preserve the current API payload and device metadata behavior.
  - Preserve inline client/server validation, analytics, and session login flow.
- Out of scope:
  - Login, password recovery, profile, or other request-entity refactors.
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

1. Given an invalid email and short password, when registration is submitted, then all local field errors are returned and the repository is not called.
2. Given valid registration input with surrounding email whitespace and password whitespace, when registration is submitted, then the repository receives valid `RegistrationCredentials` with normalized email and unchanged password.
3. Given valid registration credentials, when the repository builds the remote request, then the serialized API payload remains unchanged and device metadata is still attached.
4. Given a server field-validation or email-taken failure, when it reaches the register Cubit, then existing inline errors and failure effects remain unchanged.

## Acceptance Criteria

1. `RegisterRequestEntity` is removed from the registration flow and repository.
2. `RegisterInput` is the raw use-case input and can represent invalid form values.
3. `RegistrationCredentials` has no public unchecked constructor and aggregates field errors from existing VOs.
4. `AuthRepository.register` accepts only `RegistrationCredentials`.
5. `RegisterRequestModel` maps from `RegistrationCredentials`, unwrapping primitives only in the data layer.
6. Focused tests cover invalid aggregation, normalization, repository typing, API mapping, device metadata, and existing Cubit behavior.
7. Validation architecture documentation describes aggregate factories and typed repository boundaries.
8. Controlled full verification succeeds, with auth runtime evidence recorded when the configured environment supports it.

## Implementation Checklist

- [x] Add raw `RegisterInput` and validated `RegistrationCredentials`.
- [x] Update the use case, repository contract/implementation, data mapper, and Cubit.
- [x] Remove `RegisterRequestEntity` and migrate integration fakes.
- [x] Update and add focused tests.
- [x] Update validation architecture documentation.
- [x] Run controlled verification and record evidence.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-29: Mirror the approved login three-stage input pattern -> establishes one scalable form boundary instead of introducing a register-specific architecture.
- 2026-08-29: Use `RegistrationCredentials` with `EmailAddress` and `Password` -> registration owns the stronger password policy while login keeps `LoginPassword`.
- 2026-08-29: Aggregate all local field errors -> preserves multi-field form feedback instead of fail-fast validation.

## Verification

Attempt 1 stopped at `codegen.drift` because the intentional deletion of
`register_request_entity.freezed.dart` was still unstaged. The generated
deletion was staged so the gate can distinguish the expected checked-in change
from new build-runner drift. No generated output was manually edited.

Attempt 2 reached analyzer and stopped on one directive-ordering lint in the
updated repository test. The import was reordered without changing behavior.

Executed:

```bash
fvm flutter test test/features/auth/domain/value/registration_credentials_test.dart test/features/auth/domain/usecase/register_user_usecase_test.dart test/features/auth/data/model/remote/register_request_model_test.dart test/features/auth/data/repository/auth_repository_device_identity_test.dart test/features/auth/subfeatures/registration/presentation/cubit/register/register_cubit_test.dart
# Passed: 14 tests.

dart run mobile_core_kit_cli:mobilekit task verify --task register-validated-domain-boundary --env dev
# Passed on attempt 3 with profile full: codegen, format, analyzer, custom lints,
# CLI/lint/application tests, contract/oracle checks, and duplication profiles.
# Application suite: 560 tests passed.
```

## Runtime Evidence

The registered `auth.integration` target was attempted on the available Linux
device. The runtime harness supplied `--flavor dev`, while Flutter supports
that flag only for Android, macOS, and iOS, so execution stopped before app
launch. Sanitized evidence:

- `_artifacts/mobile/20260829_132103/evidence.json`

No compatible Android/iOS device was connected. Static full verification and
the auth integration target's compile-time coverage remain available; device
runtime success is not claimed.

## Rollback

Restore `RegisterRequestEntity` as the use-case and repository input, restore
`RegisterRequestModel.fromEntity`, remove the two new domain types, and revert
the focused tests and documentation. No persisted data or external contract
needs rollback.

## Risks And Mitigations

- Risk: password normalization changes while crossing the new boundary.
- Mitigation: preserve the exact password string and assert it in unit tests.
- Risk: the remote payload or attached device identity changes.
- Mitigation: assert `fromCredentials(...).toJson()` and repository device metadata behavior.
- Risk: server validation or session behavior changes while presentation input changes type.
- Mitigation: retain existing failure handling and session tests; change only the submitted input type.

## Completion Notes

Implemented the approved raw-input to validated-domain boundary for the full
registration flow. `RegisterRequestEntity` and all of its source references
were removed. Registration now preserves its stronger `Password` policy while
sharing the same architectural pattern as login.

## Follow-ups

- [x] No product-code debt remains in this task. The existing Linux runtime
  flavor limitation is already recorded by the preceding login boundary task.
