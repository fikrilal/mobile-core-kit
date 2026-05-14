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

3. Expose a single-subscription stream:

```dart
final _effects = StreamController<SliceEffect>();
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
- `ProfileImageCubit.resetStatus()` - likely removable after upload/clear effects, unless still needed for avatar load state.
- `MeSessionsCubit.resetRevokeStatus()` - likely removable after revoke effects.
- `MeSessionsCubit.clearFailure()` - tied to list/load failure snackbar behavior; review separately because list failures may stay state-driven.

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

- [ ] Add `me_sessions_effect.dart`.
- [ ] Emit revoke success/failure effects from `MeSessionsCubit`.
- [ ] Keep list loading/failure rendering in state.
- [ ] Remove `resetRevokeStatus()` if no longer needed.
- [ ] Keep load failure handling as state-only unless it needs a snackbar command.
- [ ] Update `MeSessionsPage` to subscribe to `effects`.
- [ ] Update cubit tests to assert revoke effects.
- [ ] Run targeted tests for security/session presentation.

### Phase 3 — Profile image

- [ ] Add `profile_image_effect.dart`.
- [ ] Emit upload/clear failure effects for mutation failures only.
- [ ] Emit upload/clear success effects.
- [ ] Represent follow-up avatar refresh as either:
  - [ ] an explicit effect consumed by the page, or
  - [ ] an internal Cubit step if it is not a UI command.
- [ ] Keep `loadAvatar()` cache/load failures state-driven unless the UI needs a snackbar.
- [ ] Remove `resetStatus()` if no longer needed for mutation commands.
- [ ] Update `AccountPage` effect consumption.
- [ ] Update profile image tests for effect order and no duplicate emissions.
- [ ] Run targeted profile tests.

### Phase 4 — Auth forms

- [ ] Add effects to `LoginCubit` for submit failures.
- [ ] Add effects to `RegisterCubit` for submit success/failure commands.
- [ ] Add effects to `ChangePasswordCubit`.
- [ ] Add effects to `PasswordResetRequestCubit`.
- [ ] Add effects to `PasswordResetConfirmCubit`.
- [ ] Add effects to `CompleteProfileCubit` if success/failure commands exist.
- [ ] Review `EmailVerificationCubit` and only add effects for true one-shot commands.
- [ ] Update pages from status-driven snackbars/navigation to effect consumption.
- [ ] Update tests per Cubit.

### Phase 5 — Cleanup and safeguards

- [ ] Search for remaining mutation status listeners:
  - [ ] `BlocListener`
  - [ ] `resetStatus`
  - [ ] `resetRevokeStatus`
  - [ ] status-driven snackbar/navigation
- [ ] Confirm remaining listeners are read-flow, dependent-load, or legacy exceptions.
- [ ] Update any docs/examples that still show status-driven mutation commands as default.
- [ ] Consider adding a custom lint or harness check later if the pattern keeps regressing.

### Phase 6 — Verification

- [ ] Run targeted tests after each slice.
- [ ] Run `dart run custom_lint`.
- [ ] Run `fvm flutter analyze`.
- [ ] Run `fvm flutter test`.
- [ ] For the full migration, run `dart run tool/verify.dart --env dev`.

## Review Checklist Per Slice

- [ ] State no longer stores a command just to trigger snackbar/navigation.
- [ ] Effect names describe user-visible commands clearly.
- [ ] Effect stream is single-subscription.
- [ ] Effect stream is closed in `close()`.
- [ ] Page subscribes once and cancels the subscription.
- [ ] No side effects are performed in `build`.
- [ ] Tests assert both state transitions and effect emissions.
- [ ] No `resetStatus()` method remains unless it has a real persistent-state purpose.

## Open Questions

- Should page-level effect subscriptions be implemented manually with `StreamSubscription`, or should the repo introduce a tiny reusable `CubitEffectListener` widget after two or three slices prove the shape?
- For profile image success, should `loadAvatar()` be an internal Cubit follow-up or an explicit UI effect? Prefer internal if no UI context is needed.
- Should success effects carry localization-ready enum/action data instead of raw strings? Prefer domain-neutral effect values and localize in the UI.
