# Maestro flows

Black-box YAML against Semantics and visible text. Flutter `Key`s are
invisible to Maestro.

Kit CLI is the only completion run. Omit `--task` to iterate:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device <emulator-id> \
  --flavor dev \
  --target maestro/<flow>.yaml

dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <emulator-id> \
  --flavor dev \
  --target maestro/<flow>.yaml
```

Raw `maestro test` and Maestro MCP do not satisfy `handoff check`.
See `docs/engineering/mobile_runtime_harness.md`.

## Device

- Install the `dev` package first. Evidence does not build or
  `flutter install`. `launchApp` fails if the package is missing.
- Evidence attaches `flutter logs` while Maestro runs. Do not
  `fvm flutter run` at the same time: `launchApp` kills it.
- Use a unique register-then-login identity per run. A fresh password
  user has empty `profile.givenName`, so the app sends
  `/user/complete-profile` before `/home`. Reusing a completed profile
  skips that screen and fails the wait.

## Selectors

- Field labels are non-clickable Views. Tap the `EditText` below the
  label (`below: '^Email$'`), not the label text.
- Maestro `text` is a full-string regex. `Create one` does not match
  `Don’t have an account? Create one`; use `.*Create one`. `Password`
  still matches `Forgot password?`. Anchor the password field as the
  parent of `Show password`.
- Do not use `hideKeyboard` on the current Android emulator. It sends
  BACK and leaves the app. Dismiss IME by tapping the app-bar title.

## `login.yaml`

Cold start with `clearState`: onboarding → sign-in → complete profile →
Home. Credentials come from `MAESTRO_TEST_EMAIL` /
`MAESTRO_TEST_PASSWORD` (not committed). Pre-register the user; this
flow only types login.

## `register.yaml`

Cold start with `clearState`: onboarding → sign-in → Create one →
create account → complete profile → Home. Same env vars, typed into
the register form. Do not curl-register first. Password minLength 10.
