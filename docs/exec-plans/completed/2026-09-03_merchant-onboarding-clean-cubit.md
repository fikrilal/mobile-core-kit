# Refactor Merchant Onboarding to Clean Cubit

**Plan version:** 2
**Task ID:** merchant-onboarding-clean-cubit
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Refactor the merchant onboarding presentation layer from an over-engineered 800-LOC BLoC back to a clean, minimal Cubit adhering to docs/engineering/ui_state_architecture.md §3 ('forms use Cubit'), eliminating 31 redundant event classes (YAGNI/KISS), moving step metadata to MerchantOnboardingStep extension, and keeping OwnerMoveDirection in presentation/models/ without altering business invariants or wire contracts.
**Allowed paths:** docs/exec-plans/active/2026-09-03_merchant-onboarding-clean-cubit.md, docs/exec-plans/completed/2026-09-03_merchant-onboarding-clean-cubit.md, lib/features/merchant_onboarding/, lib/navigation/merchant_onboarding/, test/features/merchant_onboarding/, test/core/di/registrars/registrars_smoke_test.dart, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-03
Related issue/PR: N/A

## Objective

Refactor the merchant onboarding multi-step form controller into a clean, concise Cubit:
1. Adhere to `docs/engineering/ui_state_architecture.md` §3 ("Keep it simple: lists and details use Bloc; forms use Cubit").
2. Delete `merchant_onboarding_event.dart` (eliminating 31 boilerplate event classes that violated YAGNI).
3. Move wizard step metadata (`stepFieldPaths`, `nextStep`, `previousStep`, `stepForPath`) into `MerchantOnboardingStep` extension on `merchant_onboarding_state.dart`.
4. Keep `OwnerMoveDirection` in `presentation/models/owner_move_direction.dart`.
5. Implement `MerchantOnboardingCubit` under `presentation/cubit/merchant_onboarding/` with concise arrow methods for inputs and clear navigation/submit orchestration.
6. Remove `presentation/bloc/` directory and test bloc directory.
7. Update DI, router, page, step widgets, and tests.
8. Maintain zero code comments across `merchant_onboarding` per user directive.
9. Verify via codegen, lint, feature tests, and full verification pipeline.

## Constraints

- Architecture constraints: Follow `docs/engineering/ui_state_architecture.md` (single immutable Freezed state, one-shot effects broadcast stream, concise Cubit).
- Zero comments policy: No single-line or doc comments in `merchant_onboarding` code.
- Out of scope: Wire payload changes, backend contract changes, UI layout/styling modifications.

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

1. Given `MerchantOnboardingCubit`, when created, then it starts in `initial` state with empty inputs.
2. Given `loadReferenceData()`, when called, then it loads catalog options and updates state.
3. Given input change methods (`businessLegalNameChanged`, `ownerAdded`, etc.), when invoked, then state updates and validates in real-time.
4. Given `nextTapped()` or `submitTapped()`, when invoked, then step preflight or submission use case executes and produces appropriate effects.
5. Given `mobilekit lint`, `flutter test test/features/merchant_onboarding`, and `mobilekit task verify`, when run, then all checks pass with 0 errors.

## Acceptance Criteria

1. `MerchantOnboardingCubit` replaces BLoC, eliminating 31 redundant event classes.
2. `presentation/cubit/merchant_onboarding/` contains `merchant_onboarding_cubit.dart`, `merchant_onboarding_state.dart`, `merchant_onboarding_effect.dart`.
3. `presentation/bloc/` is removed.
4. `MerchantOnboardingStep` extension in `merchant_onboarding_state.dart` encapsulates step routing and field path mappings.
5. DI registrar `MerchantOnboardingModule` registers `MerchantOnboardingCubit`.
6. Smoke test `registrars_smoke_test.dart` passes.
7. Full verification pipeline (`mobilekit task verify`) passes with `OK [verify.full]`.

## Implementation Checklist

- [x] Check risk with `mobilekit risk classify`.
- [x] Initialize task baseline with `mobilekit task begin`.
- [x] Update `merchant_onboarding_state.dart` with `MerchantOnboardingStep` extensions.
- [x] Create `presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart`.
- [x] Move `merchant_onboarding_effect.dart` to `presentation/cubit/merchant_onboarding/`.
- [x] Remove `presentation/bloc/` directory.
- [x] Run `build_runner build` for Freezed state.
- [x] Update `MerchantOnboardingPage` and all step widgets to call cubit methods directly.
- [x] Update DI in `merchant_onboarding_module.dart` and router in `merchant_onboarding_routes_list.dart`.
- [x] Update tests in `test/features/merchant_onboarding/` and `test/core/di/registrars/registrars_smoke_test.dart`.
- [x] Run `mobilekit fix --apply` and `mobilekit lint`.
- [x] Run `fvm flutter test test/features/merchant_onboarding`.
- [x] Run `mobilekit task verify --task merchant-onboarding-clean-cubit --env dev`.
- [x] Move plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-03: Revert to clean Cubit -> Eliminates 31 boilerplate events and 600 LOC of BLoC ceremony (YAGNI/KISS). Aligns with `ui_state_architecture.md` §3 ("forms use Cubit").
- 2026-09-03: Move step routing/paths to state extension -> Separation of concerns: step metadata belongs with the step enum, not bloating the controller.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build --delete-conflicting-outputs
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-clean-cubit --env dev
```

## Runtime Evidence

Cleaned-up Cubit architecture verified through unit tests, widget tests, DI smoke tests, and the full repository test suite (all 663 tests passing).

## Rollback

Revert working tree to baseline revision.

## Risks And Mitigations

- Risk: Missing input handlers in widgets.
  Mitigation: Comprehensive widget test suite (`merchant_onboarding_page_test.dart`) exercises all inputs and transitions.

## Completion Notes

- Refactored `MerchantOnboardingBloc` to `MerchantOnboardingCubit` adhering to `docs/engineering/ui_state_architecture.md` §3 ("forms use Cubit").
- Deleted 31 redundant event classes (`merchant_onboarding_event.dart`), eliminating over 500 lines of boilerplate indirection.
- Encapsulated step routing and field path metadata in `MerchantOnboardingStep` extensions within `merchant_onboarding_state.dart`.
- Removed `presentation/bloc/` directory and test bloc directory.
- Updated `MerchantOnboardingModule` DI registrar, GoRouter definitions, page, and step widgets.
- Maintained zero code comments policy across all files in `merchant_onboarding`.
- Ran full repository verification pipeline (`mobilekit task verify`): 663 tests passed, OpenAPI contract valid, clean lints.

## Follow-ups

- None.
