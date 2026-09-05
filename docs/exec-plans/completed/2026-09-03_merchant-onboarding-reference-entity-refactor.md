# Refactor Merchant Reference Data into Canonical Entity and Value Objects

**Plan version:** 2
**Task ID:** merchant-onboarding-reference-entity-refactor
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Refactor non-standard merchant_onboarding reference data types into canonical Freezed domain entities under domain/entity/ and value objects under domain/value/, eliminating the non-standard domain/reference/ directory without altering validation invariants, wire schemas, or UI behavior.
**Allowed paths:** docs/exec-plans/active/2026-09-03_merchant-onboarding-reference-entity-refactor.md, docs/exec-plans/completed/2026-09-03_merchant-onboarding-reference-entity-refactor.md, lib/features/merchant_onboarding/, test/features/merchant_onboarding/, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-03
Related issue/PR: N/A

## Objective

Bring reference data modeling in `lib/features/merchant_onboarding` into strict compliance with the codebase guide docs (`docs/engineering/model_entity_guide.md` and `docs/engineering/project_architecture.md`):
1. Convert the manually written, verbose `MerchantReferenceData` class into a canonical `@freezed` entity in `lib/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart` (along with its option entities: `BusinessTypeOptionEntity`, `BankOptionEntity`, etc.).
2. Move the typed catalog ID value objects (`BusinessTypeId`, `BankId`, etc.) out of the entity file into `lib/features/merchant_onboarding/domain/value/merchant_reference_ids.dart`.
3. Delete the non-standard directory `lib/features/merchant_onboarding/domain/reference/`.
4. Update all dependent types, models, repositories, cubits, and tests.
5. Verify codegen, lints, and all tests.

## Constraints

- Architecture constraints:
  - Domain purity: Entities and value objects remain framework-free and pure Dart.
  - Entity standard: Follow `docs/engineering/model_entity_guide.md` (§3) using Freezed for immutable entities.
- Product/runtime constraints:
  - Backward compatibility: Retain convenient lookup helpers (e.g. `businessTypeById`, `bankById`) on the entity so existing callers in step widgets and aggregates remain concise and clear.
- Out of scope:
  - Changes to wire payloads, endpoints, or UI behavior.

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

1. Given `MerchantReferenceDataModel.toDomain()`, when invoked, then it produces an immutable `MerchantReferenceDataEntity` built with Freezed.
2. Given `BusinessTypeId`, `BankId`, and other catalog IDs, when created, then they reside in `domain/value/merchant_reference_ids.dart` and enforce catalog lookup rules.
3. Given `lib/features/merchant_onboarding/`, when searched, then `domain/reference/` no longer exists.
4. Given `fvm flutter test test/features/merchant_onboarding`, when run, then all unit and widget tests pass.

## Acceptance Criteria

1. `lib/features/merchant_onboarding/domain/reference/` is completely deleted.
2. `lib/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart` exists and uses `@freezed`.
3. `lib/features/merchant_onboarding/domain/value/merchant_reference_ids.dart` exists with all typed catalog ID value objects.
4. Codegen (`build_runner build`) succeeds with zero errors.
5. All feature tests pass.
6. Full verification pipeline (`mobilekit task verify`) passes.

## Implementation Checklist

- [x] Verify risk classification with `mobilekit risk classify`.
- [x] Initialize task baseline with `mobilekit task begin`.
- [x] Create `domain/value/merchant_reference_ids.dart` containing `BusinessTypeId`, `IndustryId`, `MonthlySalesRangeId`, `OwnerRoleId`, `BankId`, `AccountHolderTypeId`, `PayoutScheduleId`.
- [x] Create `domain/entity/merchant_reference_data_entity.dart` using `@freezed` with option entities and lookup helpers.
- [x] Update `lib/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart` to map to the new entity.
- [x] Update repository, cubit, aggregates, inputs, and widgets to import from `domain/entity/` and `domain/value/`.
- [x] Delete `lib/features/merchant_onboarding/domain/reference/`.
- [x] Run `dart run build_runner build --delete-conflicting-outputs`.
- [x] Update tests in `test/features/merchant_onboarding/` and `integration_test/`.
- [x] Run tests and verify with `mobilekit task verify`.
- [x] Move plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-03: Adopt Freezed entity and move to `domain/entity/` -> `model_entity_guide.md` requires domain entities to live in `domain/entity/` using Freezed when immutability matters.
- 2026-09-03: Extract typed IDs into `domain/value/` -> `project_architecture.md` specifies value objects live in `domain/value/`.
- 2026-09-03: No typedefs -> Direct explicit usage of entity types (`MerchantReferenceDataEntity`, `BankOptionEntity`, etc.) without type aliases.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build --delete-conflicting-outputs
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-reference-entity-refactor --env dev
```

## Runtime Evidence

Pure internal architectural refactoring of domain entities and value objects with zero wire schema or UI layout changes. Verified via OpenAPI contract oracle and complete unit/widget test suite across all 668 repo tests.

## Rollback

Revert the working tree to the baseline commit prior to task begin.

## Risks And Mitigations

- Risk: Freezed entity generation conflicts with manual constructors.
  Mitigation: Use `@freezed` factory constructor and private constructor `const MerchantReferenceDataEntity._();` for lookup helpers.
- Risk: Import churn breaks references across widgets.
  Mitigation: Updated all imports cleanly; static analysis and test suite verified 100% green.

## Completion Notes

Successfully refactored merchant onboarding reference data:
1. Created `lib/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart` using `@freezed` with clean option entities (`ReferenceOptionEntity`, `BusinessTypeOptionEntity`, `OwnerRoleOptionEntity`, `BankOptionEntity`, `AccountHolderTypeOptionEntity`).
2. Moved catalog ID value objects into `lib/features/merchant_onboarding/domain/value/merchant_reference_ids.dart`.
3. Deleted the non-standard `lib/features/merchant_onboarding/domain/reference/` directory.
4. Used explicit entity type names throughout the codebase without typedefs (`MerchantReferenceDataEntity`, etc.).
5. Ran `build_runner` and regenerated Freezed code cleanly.
6. Ran `mobilekit task verify --task merchant-onboarding-reference-entity-refactor --env dev` which verified all 668 tests passing with profile=full on attempt 2.

## Follow-ups

- None.
