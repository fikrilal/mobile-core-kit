# E2E Agent Loop Findings: Google Sign-In (Emulator)

Date: 2026-02-24
Environment: Android emulator `emulator-5554`, app flavor `dev`, runtime session `e2e-google-3`

## Scope
- Run app from tooling and stream runtime logs.
- Drive UI with Mobile MCP.
- Test Google sign-in with:
  - `legiopapercloud@gmail.com` (expected success)
  - `legiozeroparadox@gmail.com` (expected backend rejection)

## Observed Outcomes
1. `legiopapercloud@gmail.com` succeeded.
- Flow reached authenticated profile screen.

2. `legiozeroparadox@gmail.com` did not authenticate.
- UI returned to Sign In screen.
- No field-level error was shown.
- No persistent detailed backend reason was visible from UI during capture.

## Evidence
- Flutter/runtime log stream: `_artifacts/runtime_logs/e2e-google-3/stream.log`
- Android logcat (key lines during failed attempt):
  - `CredManProvService: GetCredentialResponse error returned from framework` (earlier attempt)
  - Assisted sign-in flow completed successfully at Google credential layer, then app remained on Sign In.

## Potential Issues
1. Error detail is collapsed to generic messaging (or not surfaced reliably to user)
- Code path for OIDC exchange maps several cases to generic failure:
  - `lib/features/auth/data/error/auth_failure_mapper.dart`
    - OIDC status `403`/`409` -> `AuthFailure.unexpected()`
  - `lib/core/presentation/localization/auth_failure_localizer.dart`
    - `unexpected` -> `l10n.errorsUnexpected`
    - payload detail intentionally not shown by design.
- Impact: user cannot tell whether account is blocked, unverified, not allowed, or temporary backend issue.

2. Failure observability gap for sign-in exchange
- During negative flow, `flutter run` output had no app-level structured error record for the rejection path.
- Impact: difficult to debug whether failure is provider-side, API-side, mapping-side, or UI-side.

3. Cancelled provider flows are silent by design
- `LoginCubit.signInWithGoogle()` treats `AuthFailure.cancelled` as reset-to-initial with no snackbar.
- If credential manager exits as cancellation, user gets no explanation.
- Reference: `lib/features/auth/presentation/cubit/login/login_cubit.dart`

4. Noticeable auth-flow jank
- Multiple skipped-frame warnings in runtime logs around credential handoff.
- Impact: degraded perceived quality of login flow.

## Recommended Next Actions
1. Map backend OIDC rejection reasons to typed auth failures and localized UI messages
- Example: account not allowlisted / account blocked / account not verified.

2. Add structured auth failure logging for OIDC exchange
- Include status code, backend code, and mapping result (without sensitive token data).

3. Show explicit message for cancelled sign-in flows
- Example: "Google sign-in cancelled" to reduce ambiguity.

4. Add an integration test assertion for OIDC failure UX
- Ensure rejection shows deterministic, non-generic, user-actionable message.

## Update: Snackbar Capture Reliability
- Change applied: `AppSnackBar` error defaults were extended from `4s` to `20s`.
- File:
  - `lib/core/design_system/widgets/snackbar/app_snackbar.dart`
    - `error(... duration ...)` default: `Duration(seconds: 20)`
    - `showError(... duration ...)` default: `Duration(seconds: 20)`
- Verification:
  - Negative Google login with `legiozeroparadox@gmail.com` now yields a captureable snackbar window.
  - Screenshot evidence with visible error snackbar:
    - `_artifacts/e2e_snackbar_duration/t0_retry.png`
