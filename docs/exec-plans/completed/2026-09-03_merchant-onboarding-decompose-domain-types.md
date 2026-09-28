# Decompose Merchant Onboarding Domain Entities and Value Objects into 1-to-1 Files

**Plan version:** 2
**Task ID:** merchant-onboarding-decompose-domain-types
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Decompose monolithic domain value object and entity grab-bag files into discrete, single-concept files adhering to the repository conventions in docs/engineering/architecture/model_entity_guide.md and docs/engineering/architecture/project_architecture.md, without altering domain invariants, wire contracts, or UI behavior.
**Allowed paths:** docs/exec-plans/active/2026-09-03_merchant-onboarding-decompose-domain-types.md, docs/exec-plans/completed/2026-09-03_merchant-onboarding-decompose-domain-types.md, lib/features/merchant_onboarding/, test/features/merchant_onboarding/, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-03
Related issue/PR: N/A

## Objective

Decompose bundled domain types in `lib/features/merchant_onboarding` into one-type-per-file structures matching the rest of the codebase (`lib/features/auth/domain/value/` and `lib/core/domain/user/entity/`):
1. Decompose `domain/entity/merchant_reference_data_entity.dart` into discrete option entities:
   - `domain/entity/reference_option_entity.dart`
   - `domain/entity/business_type_option_entity.dart`
   - `domain/entity/owner_role_option_entity.dart`
   - `domain/entity/bank_option_entity.dart`
   - `domain/entity/account_holder_type_option_entity.dart`
   - `domain/entity/merchant_reference_data_entity.dart` (root catalog entity composing the above)
2. Decompose `domain/value/merchant_value_objects.dart` and `domain/value/merchant_reference_ids.dart` into discrete single-concept value object files:
   - `legal_business_name.dart`, `person_name.dart`, `email_address.dart`, `phone_number.dart`, `registration_number.dart`, `ownership_percentage.dart`, `bank_account_number.dart`, `bank_account_holder_name.dart`, `owner_row_id.dart`, `terms_version.dart`, `trimmed_name_validator.dart`
   - `merchant_reference_id.dart`, `business_type_id.dart`, `industry_id.dart`, `monthly_sales_range_id.dart`, `owner_role_id.dart`, `bank_id.dart`, `account_holder_type_id.dart`, `payout_schedule_id.dart`
3. Update imports across data, domain, presentation, and test files.
4. Run codegen (`build_runner build`), lint, feature tests, and full verification pipeline.

## Constraints

- Domain purity: Decomposed types remain pure Dart without framework leakage.
- Clean boundaries: No changes to validation rules, error codes, wire serialization, or UI state management.
- Freezed standards: Entity option models continue using Freezed (with BankOptionEntity using defensive Set copying).
- Out of scope: Backend contract changes, UI layout changes, publishing, commit, or push.

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

1. Given `lib/features/merchant_onboarding/domain/entity/`, when listed, then each entity concept exists in its own `*_entity.dart` file.
2. Given `lib/features/merchant_onboarding/domain/value/`, when listed, then each value object exists in its own `*.dart` file matching its class name in snake_case.
3. Given `mobilekit lint` and `fvm flutter test test/features/merchant_onboarding`, when run, then all lints pass and all feature tests succeed.
4. Given `mobilekit task verify`, when run, then full verification pipeline passes.

## Acceptance Criteria

1. Monolithic grab-bag files `merchant_value_objects.dart` and `merchant_reference_ids.dart` are removed in favor of discrete value object files.
2. Each option entity is in its own `*_entity.dart` file under `domain/entity/`.
3. Generated Freezed files exist for each Freezed entity and are up-to-date.
4. All unit, widget, and integration tests pass cleanly.
5. `mobilekit task verify` completes with zero errors on the dev environment.

## Implementation Checklist

- [x] Run `mobilekit risk classify --plan docs/exec-plans/active/2026-09-03_merchant-onboarding-decompose-domain-types.md`.
- [x] Initialize task baseline: `mobilekit task begin`.
- [x] Split option entities into individual files under `domain/entity/`.
- [x] Split value objects into individual files under `domain/value/`.
- [x] Update imports across `lib/features/merchant_onboarding/` and `test/features/merchant_onboarding/`.
- [x] Delete `merchant_value_objects.dart` and `merchant_reference_ids.dart`.
- [x] Run `build_runner build` to generate Freezed code for the new entity files.
- [x] Run `mobilekit fix --apply` and `mobilekit lint`.
- [x] Run feature tests: `fvm flutter test test/features/merchant_onboarding`.
- [x] Run full verification pipeline: `mobilekit task verify --task merchant-onboarding-decompose-domain-types --env dev`.
- [x] Move plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-03: Decompose domain types 1-to-1 -> Follows standard repository pattern seen in `features/auth/domain/value/` and `core/domain/user/entity/` for searchability, SRP, and agent legibility.
- 2026-09-03: Export option entities from `merchant_reference_data_entity.dart` -> Allows the root entity to expose its component entities cleanly without callers needing to individually import all 6 option entities when dealing with the aggregate catalog.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build --delete-conflicting-outputs
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-decompose-domain-types --env dev
```

## Runtime Evidence

Pure internal file decomposition with zero behavioral or contract changes. Verified by passing all 88 feature tests and the complete repo test suite across 668 tests.

## Rollback

Revert the working tree to the baseline commit prior to task begin.

## Risks And Mitigations

- Risk: Broken imports from scattered renames.
  Mitigation: Update imports methodically, run `dart fix --apply` and static analysis until 0 issues remain.
- Risk: Freezed part file naming errors.
  Mitigation: Ensure each `@freezed` file contains `part '<filename>.freezed.dart';` matching its file name.

## Completion Notes

Successfully decomposed domain entities and value objects into discrete, single-concept files matching the rest of the repository:
1. Decomposed option entities into:
   - `reference_option_entity.dart` (+ `.freezed.dart`)
   - `business_type_option_entity.dart` (+ `.freezed.dart`)
   - `owner_role_option_entity.dart` (+ `.freezed.dart`)
   - `bank_option_entity.dart`
   - `account_holder_type_option_entity.dart` (+ `.freezed.dart`)
   - `merchant_reference_data_entity.dart` (+ `.freezed.dart`)
2. Decomposed value objects into individual files under `domain/value/`:
   - `legal_business_name.dart`, `person_name.dart`, `email_address.dart`, `phone_number.dart`, `registration_number.dart`, `ownership_percentage.dart`, `bank_account_number.dart`, `bank_account_holder_name.dart`, `owner_row_id.dart`, `terms_version.dart`, `trimmed_name_validator.dart`
   - `merchant_reference_id.dart`, `business_type_id.dart`, `industry_id.dart`, `monthly_sales_range_id.dart`, `owner_role_id.dart`, `bank_id.dart`, `account_holder_type_id.dart`, `payout_schedule_id.dart`
3. Monolithic files `merchant_value_objects.dart` and `merchant_reference_ids.dart` removed.
4. All lints passed with 0 issues (`flutter analyze` and `custom_lint`).
5. All 88 feature tests and 668 repository tests verified via `mobilekit task verify`.

## Follow-ups

- None.
