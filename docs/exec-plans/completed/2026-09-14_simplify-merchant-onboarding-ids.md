# Simplify Merchant Onboarding IDs and Eliminate Redundant Value Objects

**Plan version:** 2
**Task ID:** simplify-merchant-onboarding-ids
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Simplify merchant onboarding domain by removing redundant ID Value Objects (AccountHolderTypeId, BankId, BusinessTypeId, IndustryId, MonthlySalesRangeId, OwnerRoleId, OwnerRowId, PayoutScheduleId, MerchantReferenceId) and replacing them with direct reference checks and primitives in aggregates.
**Allowed paths:** docs/exec-plans/active/2026-09-14_simplify-merchant-onboarding-ids.md, docs/exec-plans/completed/2026-09-14_simplify-merchant-onboarding-ids.md, lib/features/merchant_onboarding/, test/features/merchant_onboarding/, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-14
Related issue/PR: N/A

## Objective

Remove 9 redundant ID Value Object classes in `lib/features/merchant_onboarding/domain/value/` that violate repository policy (ADR 0017) and DDD principles by wrapping identifiers and performing external catalog lookups inside Value Objects. Update domain aggregates (`BusinessProfile`, `OwnershipStructure`, `SettlementAccount`, `OwnerRow`) to accept validated strings directly, utilize `UuidV4Utils.generate()` for owner row IDs, and delete the obsolete VO files without changing wire models or UI behavior.

## Constraints

- Architecture constraints:
  - Adhere strictly to ADR 0017: Identifiers without intrinsic deterministic regex/length invariants must remain plain scalars/strings.
  - Do not alter API request models (`MerchantOnboardingSubmitRequestModel`), wire JSON serialization, or backend contracts.
  - Value Objects must only enforce intrinsic invariants; referential lookups belong in aggregate factories / use cases.
- Product/runtime constraints:
  - All onboarding validation rules and error codes (`MerchantValidationCodes`) must be preserved identically.
  - UI state management (`MerchantOnboardingCubit`) and screen behavior remain functionally identical.
- Out of scope:
  - Changing other features (`auth`, `account`, etc.).
  - Backend API schema changes.
  - Git commit, push, or draft PR creation.

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

1. Given the merchant onboarding domain, when examining `lib/features/merchant_onboarding/domain/value/`, then `merchant_reference_id.dart`, `account_holder_type_id.dart`, `bank_id.dart`, `business_type_id.dart`, `industry_id.dart`, `monthly_sales_range_id.dart`, `owner_role_id.dart`, `owner_row_id.dart`, and `payout_schedule_id.dart` are removed.
2. Given a user filling out the onboarding form with valid or invalid reference IDs, when aggregate factories (`BusinessProfile.create`, `OwnershipStructure.create`, `SettlementAccount.create`) validate the inputs against `MerchantReferenceDataEntity`, then exact same error codes and field paths are returned as before.
3. Given `OwnerRowId.generate()`, when replaced with `UuidV4Utils.generate()`, then generated IDs conform to RFC 4122 v4 UUID format and list item operations function identically.
4. Given `mobilekit lint` and `fvm flutter test test/features/merchant_onboarding`, when executed, then all checks pass with 0 errors.

## Acceptance Criteria

1. Redundant 9 ID VO files deleted from `lib/features/merchant_onboarding/domain/value/`.
2. Aggregates (`BusinessProfile`, `OwnershipStructure`, `SettlementAccount`, `OwnerRow`) use plain `String` for ID fields and perform referential checks directly against `reference: MerchantReferenceDataEntity`.
3. `MerchantOnboardingSubmitRequestModel.fromApplication` maps the plain string IDs directly without `.value` property calls.
4. `MerchantOnboardingCubit` and integration tests generate row IDs via `UuidV4Utils.generate()`.
5. All existing merchant onboarding unit tests and integration tests pass without regression.
6. Full verification pipeline (`mobilekit task verify`) passes cleanly.

## Implementation Checklist

- [x] Update `BusinessProfile` aggregate to use `String` for `businessTypeId`, `industryId`, and `monthlySalesRangeId`, validating directly against `MerchantReferenceDataEntity`.
- [x] Update `SettlementAccount` aggregate to use `String` for `bankId`, `holderTypeId`, `ownerRowId`, and `payoutScheduleId`, performing catalog checks directly against `MerchantReferenceDataEntity`.
- [x] Update `OwnershipStructure` and `OwnerRow` to use `String` for `id` and `roleId`, validating against `reference.ownerRoleById()`.
- [x] Update `MerchantOnboardingApplication` and submit model mapper `MerchantOnboardingSubmitRequestModel.fromApplication` to use `String` IDs directly.
- [x] Update `MerchantOnboardingCubit` and `integration_test/merchant_onboarding_live_test.dart` to use `UuidV4Utils.generate()`.
- [x] Delete 9 obsolete VO files: `account_holder_type_id.dart`, `bank_id.dart`, `business_type_id.dart`, `industry_id.dart`, `monthly_sales_range_id.dart`, `owner_role_id.dart`, `owner_row_id.dart`, `payout_schedule_id.dart`, and `merchant_reference_id.dart`.
- [x] Update unit tests in `test/features/merchant_onboarding/` to remove references to the deleted VOs.
- [x] Run `dart run mobile_core_kit_cli:mobilekit lint` and `fvm flutter test test/features/merchant_onboarding`.
- [x] Run `dart run mobile_core_kit_cli:mobilekit task verify --task simplify-merchant-onboarding-ids`.

## Decision Log

- 2026-09-14: Remove ID Value Objects in favor of direct scalar identifiers in aggregates -> VOs wrapping external catalog checks violate VO purity and ADR 0017; OwnerRowId is an ephemeral UI key, not a domain rule.

## Verification

List exact commands and outcomes.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task simplify-merchant-onboarding-ids --action edit
# Result: Task preflight passed: simplify-merchant-onboarding-ids (action: edit, effective risk: high)

dart run mobile_core_kit_cli:mobilekit lint
# Result: Flutter analyze passed (No issues found), Custom lint passed (No issues found)

fvm flutter test test/features/merchant_onboarding
# Result: All 83 tests passed

dart run mobile_core_kit_cli:mobilekit task preflight --task simplify-merchant-onboarding-ids --action verify
# Result: Task preflight passed: simplify-merchant-onboarding-ids (action: verify, 19 task-owned paths)

dart run mobile_core_kit_cli:mobilekit task verify --task simplify-merchant-onboarding-ids
# Result: Task verification: verified (profile=full, attempt=1, 663 tests passed)

dart run mobile_core_kit_cli:mobilekit handoff check --task simplify-merchant-onboarding-ids
# Result: Local acceptance evidence passed
```

## Runtime Evidence

Runtime evidence is not required because this is a domain and aggregate refactoring that preserves existing behavioral semantics, public API contracts, and UI states. Maestro flow `maestro/merchant_onboarding.yaml` covers the runtime journey.

## Rollback

Revert the git working tree to the clean commit on `demo/merchant-onboarding-validation` via `git checkout -- . && git clean -fd`.

## Risks And Mitigations

- Risk: A missing or misaligned validation path/code in an aggregate could alter form error presentation.
- Mitigation: Existing aggregate and cubit unit tests check exact validation error codes and paths; tests were verified and all 83 passed.

## Completion Notes

- Removed 9 redundant ID Value Object classes from `lib/features/merchant_onboarding/domain/value/`: `account_holder_type_id.dart`, `bank_id.dart`, `business_type_id.dart`, `industry_id.dart`, `merchant_reference_id.dart`, `monthly_sales_range_id.dart`, `owner_role_id.dart`, `owner_row_id.dart`, `payout_schedule_id.dart`.
- Aggregates (`BusinessProfile`, `OwnershipStructure`, `SettlementAccount`, `OwnerRow`) now store plain `String` identifiers and validate referential constraints directly against `MerchantReferenceDataEntity`.
- `MerchantOnboardingCubit` and `merchant_onboarding_live_test.dart` generate UUIDs via `UuidV4Utils.generate()`.
- Full canonical verification pipeline verified cleanly on attempt 1.

## Follow-ups

- None. All acceptance criteria met.
