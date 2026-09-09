# Maestro flows

Black-box YAML against Semantics and visible text. Flutter `Key`s are
invisible to Maestro.

Kit CLI is the only completion run:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <emulator-id> \
  --flavor dev \
  --target maestro/login.yaml
```

Raw `maestro test` and Maestro MCP are iteration only. They do not
satisfy `handoff check`. See `docs/engineering/mobile_runtime_harness.md`.

## Device

- Install the `dev` package first. Evidence does not build or
  `flutter install`. `launchApp` fails if the package is missing.
- Do not pair evidence with `runtime logs --mode run`. Maestro
  `launchApp` kills that `flutter run` session.
- Use a unique register-then-login identity per run. A fresh password
  user has empty `profile.givenName`, so the app sends
  `/user/complete-profile` before `/home`. Reusing a completed profile
  skips that screen and fails the wait.

## Selectors

- Field labels are non-clickable Views. Tap the `EditText` below the
  label (`below: '^Email$'`), not the label text.
- Maestro `text` is regex. `Password` also matches `Forgot password?`.
  Anchor the password field as the parent of `Show password`.
- Do not use `hideKeyboard` on the current Android emulator. It sends
  BACK and leaves the app. Dismiss IME by tapping the app-bar title.

## `login.yaml`

Cold start with `clearState`: onboarding → sign-in → complete profile →
Home. Credentials come from `MAESTRO_TEST_EMAIL` /
`MAESTRO_TEST_PASSWORD` (not committed).
