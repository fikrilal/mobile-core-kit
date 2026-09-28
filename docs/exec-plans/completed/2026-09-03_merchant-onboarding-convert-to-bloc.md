# Convert Merchant Onboarding Presentation Layer to BLoC

**Plan version:** 2
**Task ID:** merchant-onboarding-convert-to-bloc
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Convert the multi-step merchant onboarding presentation layer from a monolithic Cubit to an event-driven BLoC (MerchantOnboardingBloc) following docs/engineering/architecture/ui_state_architecture.md §3 and §5, extracting OwnerMoveDirection to its own file, and updating DI, router, page, step widgets, and tests without changing wire contracts or UI behavior.
**Allowed paths:** docs/exec-plans/active/2026-09-03_merchant-onboarding-convert-to-bloc.md, docs/exec-plans/completed/2026-09-03_merchant-onboarding-convert-to-bloc.md, lib/features/merchant_onboarding/, lib/navigation/merchant_onboarding/, test/features/merchant_onboarding/, test/core/di/registrars/registrars_smoke_test.dart, integration_test/merchant_onboarding_live_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** contract.openapi.snapshot

Date: 2026-09-03
Related issue/PR: N/A

## Objective

Convert the merchant onboarding multi-step form to an event-driven `MerchantOnboardingBloc` under `lib/features/merchant_onboarding/presentation/bloc/merchant_onboarding/`:
1. Follow `docs/engineering/architecture/ui_state_architecture.md` (§3 and §5) which prescribes `Bloc` for multi-step wizards and branching flows.
2. Define explicit typed events in `merchant_onboarding_event.dart`.
3. Extract `OwnerMoveDirection` to `presentation/models/owner_move_direction.dart`.
4. Migrate `merchant_onboarding_state.dart` and `merchant_onboarding_effect.dart` into `presentation/bloc/merchant_onboarding/`.
5. Remove `presentation/cubit/merchant_onboarding/`.
6. Update DI registration in `merchant_onboarding_module.dart`, route setup in `merchant_onboarding_routes_list.dart`, page and step widgets in `presentation/`.
7. Update unit, widget, and integration tests to dispatch events.
8. Maintain zero comments in code per user directive.
9. Verify via codegen, lint, feature tests, and full verification pipeline.

## Constraints

- Architecture constraints: Follow `docs/engineering/architecture/ui_state_architecture.md` (single immutable state snapshot, one-shot effects broadcast stream, explicit typed events).
- Zero comments policy: No single-line or doc comments in `merchant_onboarding` code.
- Out of scope: Wire payload changes, backend contract changes, UI theme or layout modifications.

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

1. Given `MerchantOnboardingBloc`, when created, then it starts in `initial` state with empty inputs.
2. Given `MerchantOnboardingStarted`, when dispatched, then it loads reference data and emits updated reference state.
3. Given field change events (`BusinessLegalNameChanged`, `OwnerAdded`, etc.), when dispatched, then state updates touched fields and validates rules.
4. Given `NextStepTapped` or `SubmitTapped`, when dispatched, then step preflight or submission use case executes and produces appropriate effects.
5. Given `mobilekit lint`, `flutter test test/features/merchant_onboarding`, and `mobilekit task verify`, when run, then all checks pass with 0 errors.

## Acceptance Criteria

1. `MerchantOnboardingBloc` replaces `MerchantOnboardingCubit`.
2. `lib/features/merchant_onboarding/presentation/bloc/merchant_onboarding/` contains `merchant_onboarding_bloc.dart`, `merchant_onboarding_event.dart`, `merchant_onboarding_state.dart`, `merchant_onboarding_effect.dart`.
3. `presentation/cubit/` is removed.
4. `OwnerMoveDirection` is in its own dedicated model file.
5. DI registrar `MerchantOnboardingModule` registers `MerchantOnboardingBloc`.
6. Smoke test `registrars_smoke_test.dart` passes.
7. Full verification pipeline (`mobilekit task verify`) passes with `OK [verify.full]`.

## Implementation Checklist

- [x] Check risk with `mobilekit risk classify`.
- [x] Initialize task baseline with `mobilekit task begin`.
- [x] Create `presentation/models/owner_move_direction.dart`.
- [x] Create `presentation/bloc/merchant_onboarding/merchant_onboarding_event.dart`.
- [x] Move/create `merchant_onboarding_state.dart` and `merchant_onboarding_effect.dart` in `presentation/bloc/merchant_onboarding/`.
- [x] Create `presentation/bloc/merchant_onboarding/merchant_onboarding_bloc.dart`.
- [x] Update `MerchantOnboardingPage` and all step widgets to use `MerchantOnboardingBloc`.
- [x] Update DI in `merchant_onboarding_module.dart` and routes in `merchant_onboarding_routes_list.dart`.
- [x] Delete `presentation/cubit/` directory.
- [x] Run `build_runner build` for any Freezed updates.
- [x] Update tests in `test/features/merchant_onboarding/` and `test/core/di/registrars/registrars_smoke_test.dart`.
- [x] Run `mobilekit fix --apply` and `mobilekit lint`.
- [x] Run `fvm flutter test test/features/merchant_onboarding`.
- [x] Run `mobilekit task verify --task merchant-onboarding-convert-to-bloc --env dev`.
- [x] Move plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-03: Multi-step wizard to Bloc -> `ui_state_architecture.md` §5 prescribes BLoC for multi-step wizards with branching and many intents.
- 2026-09-03: Extract `OwnerMoveDirection` -> Enums must not be declared inline inside bloc/cubit files.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build --delete-conflicting-outputs
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-convert-to-bloc --env dev
```

## Runtime Evidence

Refactor of the multi-step form controller from Cubit to BLoC. Verified through unit, widget, DI smoke, and full verification test suites (all 668 tests passing).

## Rollback

Revert working tree to baseline revision.

## Risks And Mitigations

- Risk: Widget event dispatch mismatches causing UI freezes.
  Mitigation: Comprehensive widget test suite (`merchant_onboarding_page_test.dart`) exercises all steps and transitions.
- Risk: Lost state during Freezed regeneration.
  Mitigation: State shape and fields remain identical, preserving existing serialization and tests.

## Completion Notes

- Converted `MerchantOnboardingCubit` to event-driven `MerchantOnboardingBloc` matching `docs/engineering/architecture/ui_state_architecture.md` §3 & §5.
- Created `lib/features/merchant_onboarding/presentation/models/owner_move_direction.dart`.
- Created discrete events in `lib/features/merchant_onboarding/presentation/bloc/merchant_onboarding/merchant_onboarding_event.dart`.
- Migrated state and effect files to `lib/features/merchant_onboarding/presentation/bloc/merchant_onboarding/`.
- Deleted legacy `presentation/cubit/` directory and its unit tests.
- Updated DI module, routes list, page widget, step widgets, and cards to interact via BLoC events.
- Updated `registrars_smoke_test.dart`, `merchant_onboarding_page_test.dart`, `merchant_onboarding_bloc_test.dart`, and `merchant_onboarding_live_test.dart`.
- Adhered strictly to zero code comments in `merchant_onboarding`.
- Ran full verification pipeline (`mobilekit task verify`): 668 passing tests, clean lints, valid OpenAPI contract snapshot.

## Follow-ups

- None.
