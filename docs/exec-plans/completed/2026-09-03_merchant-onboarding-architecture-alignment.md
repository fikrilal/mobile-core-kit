# Refactor Merchant Onboarding to Align with Codebase Architecture

**Plan version:** 2
**Task ID:** merchant-onboarding-architecture-alignment
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Refactor the merchant-onboarding feature data and domain layers to strictly align with repository engineering guides (moving DTO mappers to model-owned methods and request-model factories, centralizing backend error codes and API failure mapping into data/error/, removing the pure pass-through reference data use case, renaming *Dto to *Model, and adopting the canonical repository pattern using toEitherWithFallback) without altering observable user flow, validation invariants, or network wire schemas.
**Allowed paths:** docs/exec-plans/active/2026-09-03_merchant-onboarding-architecture-alignment.md, docs/exec-plans/completed/2026-09-03_merchant-onboarding-architecture-alignment.md, lib/features/merchant_onboarding/, test/features/merchant_onboarding/, test/core/di/registrars/registrars_smoke_test.dart, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-03
Related issue/PR: N/A

## Objective

Bring `lib/features/merchant_onboarding` into compliance with the repository's engineering guides (`docs/engineering/data_domain_guide.md`, `docs/engineering/model_entity_guide.md`, and `docs/engineering/project_architecture.md`):
1. Eliminate standalone mapper files in `data/mapper/` by collocating model-to-domain conversion (`toDomain()`) on remote models and aggregate-to-request mapping (`fromApplication(...)`) as a factory on the submit request model.
2. Eliminate the pure pass-through `LoadMerchantReferenceDataUseCase` in accordance with `data_domain_guide.md` Section 11, having `MerchantOnboardingCubit` consume `MerchantOnboardingRepository.loadReferenceData()` directly.
3. Extract failure mapping and backend error codes out of `MerchantOnboardingRepositoryImpl` into `data/error/merchant_onboarding_failure_mapper.dart` and `data/error/merchant_onboarding_error_codes.dart`.
4. Refactor `MerchantOnboardingRepositoryImpl` to use the canonical `.toEitherWithFallback(...)` pipeline from `api_response_either.dart`.
5. Rename `*Dto` classes and files in `data/model/remote/` to follow the standard `*Model` / `*RequestModel` / `*ResponseModel` conventions.
6. Keep all domain aggregates, value objects, final-gate validation in `SubmitMerchantOnboardingUseCase`, wizard UI, cubit effects, and test coverage green.

## Constraints

- Architecture constraints:
  - Preserve the Clean Architecture and Vertical Slices boundary: `Domain` stays pure Dart and framework-free; `Data` owns serialization, network, and error mapping; `Presentation` consumes domain types and use cases/repositories via DI.
  - Follow `docs/engineering/model_entity_guide.md`: request models mirror backend schema, response models own `toDomain()` / `toEntity()`, Freezed + json_serializable with generated `*.freezed.dart` and `*.g.dart`.
  - Follow `docs/engineering/data_domain_guide.md`: no separate mapper files for pure structural conversions; no pass-through use cases; failure mapping belongs in `data/error/`.
  - Follow canonical repository error handling: use `toEitherWithFallback(...)` on `ApiResponse<T>`, map left using `mapMerchantOnboardingFailure`, catch unexpected errors with `MerchantUnexpectedFailure`.
- Product/runtime constraints:
  - Network wire schema must remain byte-identical with `backend.openapi.yaml` (integer basis points for ownership, string with leading zeroes for bank account, same JSON keys).
  - UI wizard behavior, step progression, touched paths, error localizations, discard confirmation dialog, and one-shot effects must remain unchanged.
- Out of scope:
  - Any change to the backend contract (`backend.openapi.yaml`), database migrations, or endpoint paths.
  - Changes to UI design system, styling, or localization strings.
  - Publication, commit, or push.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: yes
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given `MerchantReferenceDataModel`, when deserialized from JSON, then it exposes a model-owned `.toDomain()` method returning the immutable `MerchantReferenceData` snapshot.
2. Given a validated `MerchantOnboardingApplication`, when mapped for submission, then `MerchantOnboardingSubmitRequestModel.fromApplication(application)` losslessly converts basis points, unwraps value objects, and preserves leading-zero account numbers.
3. Given `MerchantOnboardingRepositoryImpl`, when `loadReferenceData()` or `submitApplication(...)` is called, then it uses `apiResponse.toEitherWithFallback(...)` and maps `ApiFailure` via `data/error/merchant_onboarding_failure_mapper.dart`.
4. Given `MerchantOnboardingCubit`, when created via DI, then it receives `MerchantOnboardingRepository` for loading reference data and `SubmitMerchantOnboardingUseCase` for the final validation gate, without `LoadMerchantReferenceDataUseCase`.
5. Given all unit, widget, and integration tests under `test/features/merchant_onboarding/`, when executed, then all pass without regressions.
6. Given `mobilekit lint` and `mobilekit contract openapi verify`, when executed, then they pass cleanly.

## Acceptance Criteria

1. `lib/features/merchant_onboarding/data/mapper/` is completely removed.
2. `lib/features/merchant_onboarding/data/error/` exists with `merchant_onboarding_error_codes.dart` and `merchant_onboarding_failure_mapper.dart`.
3. `LoadMerchantReferenceDataUseCase` is removed from `domain/usecase/`, `di/merchant_onboarding_module.dart`, and all test fixtures.
4. `MerchantOnboardingRepositoryImpl` is streamlined (~20-30 lines total) using `toEitherWithFallback(...)`.
5. Remote models are renamed from `*Dto` to `*Model` / `*RequestModel` / `*ResponseModel`.
6. Codegen (`build_runner build`) succeeds with zero errors and generated files are up to date.
7. All 85+ feature tests pass.
8. Controlled task verification (`mobilekit task verify`) passes with profile full on dev environment.

## Implementation Checklist

- [x] Run `mobilekit risk classify --plan docs/exec-plans/active/2026-09-03_merchant-onboarding-architecture-alignment.md` to verify authority and oracles.
- [x] Initialize task baseline: `dart run mobile_core_kit_cli:mobilekit task begin --plan docs/exec-plans/active/2026-09-03_merchant-onboarding-architecture-alignment.md`.
- [x] Create `data/error/merchant_onboarding_error_codes.dart` containing backend error code constants (`VALIDATION_FAILED`, `MERCHANT_ONBOARDING_APPLICATION_ALREADY_EXISTS`, etc.).
- [x] Create `data/error/merchant_onboarding_failure_mapper.dart` containing `mapMerchantReferenceFailure(ApiFailure)` and `mapMerchantSubmitFailure(ApiFailure)`.
- [x] Rename `data/model/remote/merchant_reference_data_models.dart` to use `MerchantReferenceDataModel` and add `toDomain()` method.
- [x] Rename `data/model/remote/merchant_onboarding_submit_models.dart` to use `*Model` and add `MerchantOnboardingSubmitRequestModel.fromApplication(application)`.
- [x] Remove `data/mapper/merchant_reference_data_mapper.dart` and `data/mapper/merchant_onboarding_submit_mapper.dart`.
- [x] Update `MerchantOnboardingRemoteDataSource` to use the renamed models.
- [x] Refactor `MerchantOnboardingRepositoryImpl` to use `toEitherWithFallback(...)`, `toDomain()`, `MerchantOnboardingSubmitRequestModel.fromApplication()`, and error mappers.
- [x] Delete `LoadMerchantReferenceDataUseCase` from `domain/usecase/`.
- [x] Update `MerchantOnboardingCubit` to accept `MerchantOnboardingRepository` directly for reference data loading.
- [x] Update `MerchantOnboardingModule` in `di/` to remove `LoadMerchantReferenceDataUseCase` registration and pass repository to `MerchantOnboardingCubit`.
- [x] Run `dart run build_runner build --delete-conflicting-outputs`.
- [x] Update all tests in `test/features/merchant_onboarding/` and DI registrar smoke tests to reflect the refactoring.
- [x] Run feature tests: `fvm flutter test test/features/merchant_onboarding/`.
- [x] Run full verification profile: `dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-architecture-alignment --env dev`.
- [x] Update plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-03: Adopt model-owned mapping and request factory -> `data_domain_guide.md` and `model_entity_guide.md` state that 1-to-1 model mapping belongs on the model and standalone mappers are an anti-pattern.
- 2026-09-03: Delete `LoadMerchantReferenceDataUseCase` -> Section 11 of `data_domain_guide.md` explicitly forbids pure pass-through use cases that add no business logic over the repository call.
- 2026-09-03: Extract `data/error/` -> Section 10 of `data_domain_guide.md` requires failure mapping in `data/error/` to keep repository implementations orchestration-only.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-architecture-alignment --action verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build --delete-conflicting-outputs
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task verify \
  --task merchant-onboarding-architecture-alignment --env dev
```

## Runtime Evidence

Pure internal architectural refactoring of mobile data/domain layers with zero wire schema, UI layout, or routing change. Verified via OpenAPI contract snapshot verification (`mobilekit contract openapi verify`), all 88 unit and widget tests passing, and the full pipeline `mobilekit task verify` passing with 668 passing tests.

## Rollback

Revert the working tree to the baseline commit prior to `task begin`. Freezed/JSON generated files and deleted files are fully restored by `git checkout` / `git restore`.

## Risks And Mitigations

- Risk: Renaming `*Dto` to `*Model` breaks JSON serialization keys.
  Mitigation: Kept all JSON keys identical, verified via OpenAPI snapshot and remote datasource tests.
- Risk: Eliminating `data/mapper/` introduces subtle basis-point or leading-zero precision errors.
  Mitigation: Ported existing pure mapper unit tests to `test/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models_test.dart`.
- Risk: `toEitherWithFallback` changes error code routing.
  Mitigation: Verified every documented error code in `merchant_onboarding_repository_impl_test.dart` and `merchant_onboarding_failure_mapper_test.dart`.

## Completion Notes

Successfully completed full alignment of `merchant_onboarding` with the codebase standards:
1. Eliminated `lib/features/merchant_onboarding/data/mapper/` completely.
2. Collocated `toDomain()` on `MerchantReferenceDataModel` and `MerchantOnboardingSubmitRequestModel.fromApplication(...)` on the submit request model.
3. Created `lib/features/merchant_onboarding/data/error/merchant_onboarding_error_codes.dart` and `merchant_onboarding_failure_mapper.dart`.
4. Streamlined `MerchantOnboardingRepositoryImpl` to use `toEitherWithFallback(...)`.
5. Removed pure pass-through `LoadMerchantReferenceDataUseCase` and updated `MerchantOnboardingCubit` to call `MerchantOnboardingRepository.loadReferenceData()` directly.
6. Renamed remote types from `*Dto` to `*Model`.
7. Regenerated Freezed and JSON serialization files with `build_runner`.
8. Ran all feature tests (88/88 passed), DI smoke test, and full pipeline `mobilekit task verify --task merchant-onboarding-architecture-alignment --env dev` (668/668 tests passed).

## Follow-ups

- None. No architectural or technical debt introduced.
