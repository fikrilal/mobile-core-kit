# Explicit Mutation Effects Refactor Proposal

## Context

The presentation docs now define a clearer rule:

- State is for persistent UI rendering.
- Effects are for one-shot commands.
- Mutation flows (`POST`, `PATCH`, `PUT`, `DELETE`) should expose explicit effects.
- Read flows (`GET`, list/detail loads, refresh, pagination) can stay state-only unless they have an exceptional one-shot command.

The current codebase still has several mutation flows where a `BlocListener` watches persistent status fields and then performs snackbars/navigation. Some of those flows also call `resetStatus()` only to re-arm the next snackbar. That works, but the mental model is weaker because status is doing two jobs: rendering state and command signaling.

## Goal

Refactor mutation-heavy presentation slices so one-shot UI commands are explicit and testable.

This should improve:

- command semantics: snackbars/navigation are emitted once
- testability: state transitions and effects can be asserted separately
- maintainability: less `resetStatus()` ceremony
- readability: mutation outcomes are visible as named effect classes

## Non-Goals

- Do not rewrite read/list/detail flows that only render state.
- Do not convert every `BlocListener` to an effect stream.
- Do not introduce a shared global effect bus.
- Do not migrate unrelated architecture or UI code.
- Do not change domain/repository behavior as part of this refactor.

## Proposed Pattern

For mutation Cubits/Blocs:

1. Keep state for renderable values:
   - form fields
   - validation errors
   - loading/submitting flags
   - inline failure data when the UI renders it persistently

2. Add a colocated effect file:

```text
lib/features/<feature>/<slice>/presentation/cubit/<slice>/<slice>_effect.dart
```

3. Expose an effect stream with one page-owned subscription:

```dart
final _effects = StreamController<SliceEffect>.broadcast();
Stream<SliceEffect> get effects => _effects.stream;
```

4. Emit effects for commands:
   - snackbar
   - dialog
   - navigation
   - pop-with-result
   - copy/share/open command
   - parent refresh command

5. Close the stream in `close()`.

6. Tests subscribe to `effects`, trigger the mutation, and assert exact effect order.

## Phase 0 Inventory

Completed on 2026-05-15.

### Mutation flows with snackbar/navigation commands

| Slice | Current command channel | Classification | Reset/re-arm method | Notes |
| --- | --- | --- | --- | --- |
| `RequestAccountDeletionCubit` | `BlocListener` watches `RequestAccountDeletionStatus` | mutation with snackbar | `resetStatus()` | Request/cancel success and failure snackbars should become explicit effects. |
| `ProfileImageCubit` | `BlocListener` watches `ProfileImageStatus` + `ProfileImageAction` | mutation with snackbar + follow-up refresh | `resetStatus()` | Upload/clear commands should become effects. Avatar reload can likely stay internal because it does not need UI context. |
| `MeSessionsCubit` | `BlocListener` watches `revokeStatus` | mutation with snackbar | `resetRevokeStatus()` | Revoke success/failure should become effects. List load failure can remain render-state. |
| `LogoutCubit` | Router-level `BlocListener` watches `failure` | mutation with snackbar | none | Logout success is handled by session/router redirect. Failure snackbar can become an effect. |
| `LoginCubit` | `BlocListener` watches `LoginStatus.failure` | mutation with snackbar | none | Success likely remains session/router-driven. Failure snackbar should become an effect. |
| `RegisterCubit` | `BlocListener` watches `RegisterStatus.failure` | mutation with snackbar | none | Failure snackbar should become an effect. Confirm whether success needs navigation or is session/router-driven before changing. |
| `ChangePasswordCubit` | `BlocListener` watches `ChangePasswordStatus` | mutation with snackbar + navigation/pop | none | Success snackbar and pop/home navigation should become explicit effects. Failure snackbar should become an effect. |
| `PasswordResetRequestCubit` | `BlocListener` watches `PasswordResetRequestStatus` | mutation with snackbar + navigation/pop | none | Success snackbar and pop/sign-in navigation should become explicit effects. Non-validation failures should become effects. |
| `PasswordResetConfirmCubit` | `BlocListener` watches `PasswordResetConfirmStatus.failure` | mutation with snackbar | none | Failure snackbar should become an effect. Success is mostly rendered by `AppAsyncStateView`; verify before adding success effects. |
| `EmailVerificationCubit` | `BlocListener` watches `EmailVerificationStatus.failure` | mutation/read hybrid with snackbar | none | Body rendering uses `AppAsyncStateView`; only snackbar failure should become an effect if it remains a one-shot command. |
| `CompleteProfileCubit` | `BlocListener` watches `CompleteProfileStatus.failure` | mutation with snackbar | none | Failure snackbar should become an effect. Confirm success behavior before adding success effects. |

### Flows to keep state/listener-driven for now

| Flow | Reason |
| --- | --- |
| `MeSessionsCubit.load/loadMore` list failures | Read/list state is rendered by collection UI; no mandatory one-shot command. |
| `ProfileImageCubit.loadAvatar` cache/load state | Avatar loading is render state; only mutation upload/clear commands need effects. |
| Static navigation taps in pages | Direct user navigation commands from button/tile taps are not Cubit mutation outcomes. |
| Session/startup router redirects | Global auth/session routing is already state-driven and not a per-slice snackbar command. |

### Reset methods found

- `RequestAccountDeletionCubit.resetStatus()` - removed in Phase 1 after request/cancel effects.
- `ProfileImageCubit.resetStatus()` - removed in Phase 3 after upload/clear effects.
- `MeSessionsCubit.resetRevokeStatus()` - removed in Phase 2 after revoke effects.
- `MeSessionsCubit.clearFailure()` - removed in Phase 2 after load-more failure snackbar moved to effects.

### Existing test baseline

Current Cubit tests mostly assert status transitions and failure fields. They do not yet assert explicit effects.

- `request_account_deletion_cubit_test.dart` includes `resetStatus` coverage.
- `me_sessions_cubit_test.dart` asserts revoke submitting/success/failure state.
- Auth form Cubit tests assert `submitting -> success/failure` state transitions.
- Mutation effect stream tests now exist for account deletion only.

### Phase 1 Implementation Notes

Completed on 2026-05-15.

- Added `request_account_deletion_effect.dart`.
- `RequestAccountDeletionCubit` now exposes a single-subscription `effects` stream and closes it in `close()`.
- Request/cancel failure and success commands now emit explicit effects.
- `RequestAccountDeletionPage` subscribes once to `effects` and no longer uses `BlocListener` for mutation snackbars.
- Removed `RequestAccountDeletionCubit.resetStatus()`.
- Updated account deletion Cubit tests to assert emitted effects and stream closure.

Implementation note: effect stream controllers are closed with `unawaited(_effects.close())` from Cubit `close()`. Awaiting a single-subscription controller close can hang when no listener was attached.

### Phase 2 Implementation Notes

Completed on 2026-05-15.

- Added `me_sessions_effect.dart`.
- `MeSessionsCubit` now exposes a single-subscription `effects` stream and closes it in `close()`.
- Session revoke success/failure commands now emit explicit effects.
- Revoke completion no longer stores success/failure command payloads in state.
- `MeSessionsPage` subscribes once to `effects` for revoke snackbars.
- Load-more failure snackbar handling also emits an explicit effect, while initial-load failure remains render-state.
- Removed the remaining `BlocListener` from `MeSessionsPage`.
- Removed `MeSessionsCubit.resetRevokeStatus()`.
- Removed `MeSessionsCubit.clearFailure()`.
- Updated session Cubit tests to assert emitted revoke effects and stream closure.

### Phase 3 Implementation Notes

Completed on 2026-05-15.

- Added `profile_image_effect.dart`.
- `ProfileImageCubit` now exposes a single-subscription `effects` stream and closes it in `close()`.
- Upload/clear success and failure commands now emit explicit effects.
- Upload/clear completion returns state to `initial` instead of storing success/failure commands in state.
- Avatar loading/cache failures remain render-state because they describe the avatar content state.
- Removed `ProfileImageCubit.resetStatus()`.
- `AccountPage` subscribes once to profile image effects and no longer uses `BlocListener` for profile image snackbars.
- Updated profile image Cubit tests to assert mutation effects and stream closure.

### Phase 4 Implementation Notes

Completed on 2026-05-15.

- Added auth/profile effect files for login, register, change password, password reset request, password reset confirm, complete profile, and email verification.
- Login/register failure snackbars now come from Cubit effects. Success remains session/router-driven.
- Change password success now emits an effect consumed by the page for success snackbar plus pop/home navigation.
- Password reset request success and non-validation failure commands now emit effects. Validation failures remain state-only because the existing UX intentionally renders field errors without a snackbar.
- Password reset confirm success remains render-state through `AppAsyncStateView`; non-validation failure snackbars now use effects.
- Complete profile failure snackbars now use effects. Success remains session/profile state-driven.
- Email verification failure snackbars now use effects, while success/failure bodies remain render-state.
- Removed the remaining auth/profile status-driven `BlocListener` snackbar/navigation handlers from Phase 4 pages.
- Updated Cubit tests to assert representative success/failure effects for the affected slices.

### Phase 5 Implementation Notes

Completed on 2026-05-15.

- Scanned remaining `BlocListener`, `resetStatus`, `resetRevokeStatus`, `clearFailure`, snackbar, and navigation usages under `lib`, `test`, `docs`, and `_WIP`.
- Found one remaining mutation command channel: logout failure snackbar was still driven by router-level `BlocListener` watching `LogoutState.failure`.
- Added `logout_effect.dart`; `LogoutCubit` now emits `LogoutFailureEffect` for failed logout commands and no longer stores logout failure as persistent state.
- Replaced the router-level logout `BlocListener` with `_AccountRoutePage`, which subscribes once to logout effects and keeps logout loading state in `BlocBuilder`.
- Updated `docs/engineering/ui_state_architecture.md` examples so mutation snackbar/navigation commands use explicit effects, while `BlocListener` examples are limited to read-flow/dependent-load cases.
- No reset/re-arm methods remain in the migrated mutation slices.

## Current Candidate Slices

### High priority

- `RequestAccountDeletionCubit`
  - Current behavior: request/cancel success and failure snackbars are driven from `RequestAccountDeletionStatus`.
  - Smell: `resetStatus()` exists mainly to re-arm snackbar behavior.
  - Desired effect examples:
    - `ShowRequestAccountDeletionFailure(AuthFailure failure)`
    - `ShowAccountDeletionRequested()`
    - `ShowAccountDeletionCanceled()`

- `ProfileImageCubit`
  - Current behavior: upload/remove success and failure snackbars are driven from `ProfileImageStatus` + `ProfileImageAction`.
  - Smell: listener calls `loadAvatar()` and `resetStatus()` after success.
  - Desired effect examples:
    - `ShowProfileImageFailure(AuthFailure failure)`
    - `ShowProfileImageUpdated()`
    - `ShowProfileImageRemoved()`
    - `RefreshProfileAvatar()`

- `MeSessionsCubit`
  - Current behavior: session revoke success/failure snackbars are driven from `revokeStatus`.
  - Smell: `resetRevokeStatus()` exists to re-arm revoke snackbar behavior.
  - Desired effect examples:
    - `ShowRevokeSessionFailure(AuthFailure failure)`
    - `ShowRevokeSessionSuccess(String sessionId)`

### Medium priority

- `LoginCubit`
  - Current behavior: failure snackbar is driven from `LoginStatus.failure`.
  - Desired effect examples:
    - `ShowLoginFailure(AuthFailure failure)`
  - Note: successful login may not need a snackbar; route changes likely come from session/startup redirect behavior.

- `RegisterCubit`
  - Current behavior should be checked before changing.
  - Desired effect examples:
    - `ShowRegisterFailure(AuthFailure failure)`
    - `NavigateToEmailVerification(...)` or `ShowRegisterSuccess(...)`, depending on current UX.

- `ChangePasswordCubit`
  - Desired effect examples:
    - `ShowChangePasswordFailure(AuthFailure failure)`
    - `ShowChangePasswordSuccess()`
    - optional `PopAfterPasswordChanged()`

- `PasswordResetRequestCubit`
  - Desired effect examples:
    - `ShowPasswordResetRequestFailure(AuthFailure failure)`
    - `ShowPasswordResetRequestSuccess()`

- `PasswordResetConfirmCubit`
  - Desired effect examples:
    - `ShowPasswordResetConfirmFailure(AuthFailure failure)`
    - `ShowPasswordResetConfirmSuccess()`
    - optional navigation effect back to sign-in

- `CompleteProfileCubit`
  - Current behavior should be checked for failure snackbar and success navigation.
  - Desired effect examples:
    - `ShowCompleteProfileFailure(AuthFailure failure)`
    - `CompleteProfileSucceeded()`

- `EmailVerificationCubit`
  - Verify whether it behaves more like a mutation submit flow or a render-only verification screen.
  - Use effects only for snackbars/navigation, not for normal body rendering.

### Keep as state/listener unless proven otherwise

- Read/list/detail load failures rendered inline.
- Dependent-load listeners, for example listening to an ID change and fetching child data.
- Startup/auth redirect behavior handled by router/session state.

## Migration Order

Start with slices where the smell is strongest and the blast radius is small.

1. `RequestAccountDeletionCubit`
2. `MeSessionsCubit`
3. `ProfileImageCubit`
4. Auth form Cubits one by one

Reasoning:

- Account deletion and session revoke have obvious mutation commands and reset methods.
- Profile image is more complex because success currently triggers avatar reload as a follow-up command.
- Auth forms are broader and may interact with routing/session redirects, so they should come after the pattern is proven.

## TODO

### Phase 0 — Baseline inventory

- [x] List every presentation mutation flow under `lib/features/**/presentation`.
- [x] Classify each flow as:
  - [x] read/render-only
  - [x] mutation with snackbar
  - [x] mutation with navigation/pop result
  - [x] mutation with parent refresh command
- [x] Identify reset methods used only for one-shot command re-arming.
- [x] Record current tests that assert status-driven side effects.

### Phase 1 — Account deletion pilot

- [x] Add `request_account_deletion_effect.dart`.
- [x] Add single-subscription effect stream to `RequestAccountDeletionCubit`.
- [x] Emit failure and success effects from `request()` / `cancel()` result handling.
- [x] Keep status for submit button/loading only.
- [x] Remove `resetStatus()` if no longer needed.
- [x] Update `RequestAccountDeletionPage` to subscribe to `effects`.
- [x] Update cubit tests to assert state transitions and emitted effects.
- [x] Run targeted tests for account deletion.

### Phase 2 — Session revoke

- [x] Add `me_sessions_effect.dart`.
- [x] Emit revoke success/failure effects from `MeSessionsCubit`.
- [x] Keep list loading/failure rendering in state.
- [x] Remove `resetRevokeStatus()` if no longer needed.
- [x] Keep initial-load failure handling as state-only; move load-more snackbar command to effects.
- [x] Update `MeSessionsPage` to subscribe to `effects`.
- [x] Update cubit tests to assert revoke effects.
- [x] Run targeted tests for security/session presentation.

### Phase 3 — Profile image

- [x] Add `profile_image_effect.dart`.
- [x] Emit upload/clear failure effects for mutation failures only.
- [x] Emit upload/clear success effects.
- [x] Represent follow-up avatar refresh as either:
  - [ ] an explicit effect consumed by the page, or
  - [x] an internal Cubit step if it is not a UI command.
- [x] Keep `loadAvatar()` cache/load failures state-driven unless the UI needs a snackbar.
- [x] Remove `resetStatus()` if no longer needed for mutation commands.
- [x] Update `AccountPage` effect consumption.
- [x] Update profile image tests for effect order and no duplicate emissions.
- [x] Run targeted profile tests.

### Phase 4 — Auth forms

- [x] Add effects to `LoginCubit` for submit failures.
- [x] Add effects to `RegisterCubit` for submit success/failure commands.
- [x] Add effects to `ChangePasswordCubit`.
- [x] Add effects to `PasswordResetRequestCubit`.
- [x] Add effects to `PasswordResetConfirmCubit`.
- [x] Add effects to `CompleteProfileCubit` if success/failure commands exist.
- [x] Review `EmailVerificationCubit` and only add effects for true one-shot commands.
- [x] Update pages from status-driven snackbars/navigation to effect consumption.
- [x] Update tests per Cubit.

### Phase 5 — Cleanup and safeguards

- [x] Search for remaining mutation status listeners:
  - [x] `BlocListener`
  - [x] `resetStatus`
  - [x] `resetRevokeStatus`
  - [x] status-driven snackbar/navigation
- [x] Confirm remaining listeners are read-flow, dependent-load, or legacy exceptions.
- [x] Update any docs/examples that still show status-driven mutation commands as default.
- [x] Consider adding a custom lint or harness check later if the pattern keeps regressing.

Decision: defer a lint/harness rule for now. The pattern is now documented and the remaining command channels are searchable; add a guard only if this regresses in future reviews.

### Phase 6 — Verification

- [x] Run targeted tests after each slice.
- [x] Run `dart run custom_lint`.
- [x] Run `fvm flutter analyze`.
- [x] Run `fvm flutter test`.
- [x] For the full migration, run `dart run tool/verify.dart --env dev`.

Verification completed on 2026-05-15.

- Targeted Cubit tests passed for each migrated mutation slice.
- `dart run build_runner build --delete-conflicting-outputs` completed after the logout state change.
- `fvm flutter analyze` passed.
- `dart run custom_lint` passed.
- `./tool/check_duplication.sh` passed with no actionable duplicate groups.
- `./tool/check_small_helper_duplication.sh` passed with no actionable duplicate groups.
- `dart run tool/verify.dart --env dev` passed, including the full Flutter test suite.
- Final scan found no remaining `BlocListener`, `resetStatus`, `resetRevokeStatus`, or `clearFailure` hits under `lib/features` or `lib/navigation`.

## Review Checklist Per Slice

- [ ] State no longer stores a command just to trigger snackbar/navigation.
- [ ] Effect names describe user-visible commands clearly.
- [ ] Effect stream has one page-owned subscription.
- [ ] Effect stream is closed in `close()`.
- [ ] Page subscribes once and cancels the subscription.
- [ ] No side effects are performed in `build`.
- [ ] Tests assert both state transitions and effect emissions.
- [ ] No `resetStatus()` method remains unless it has a real persistent-state purpose.

## Open Questions

- Should page-level effect subscriptions be implemented manually with `StreamSubscription`, or should the repo introduce a tiny reusable `CubitEffectListener` widget after two or three slices prove the shape?
- For profile image success, should `loadAvatar()` be an internal Cubit follow-up or an explicit UI effect? Prefer internal if no UI context is needed.
- Should success effects carry localization-ready enum/action data instead of raw strings? Prefer domain-neutral effect values and localize in the UI.
