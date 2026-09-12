# Maestro Flows

Black-box device journeys for this Flutter app. Official command list:
[Maestro commands](https://docs.maestro.dev/reference/commands-available.md).
This page is the **repo subset**. Do not copy every command from upstream
into YAML.

Flow inventory: `maestro/README.md`. Proof contract:
`docs/engineering/mobile_runtime_harness.md`.

## Proof vs iterate

Kit CLI only:

```bash
# Iterate. No evidence.json. Not handoff.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device emulator-5554 --flavor dev --target maestro/<flow>.yaml

# Prove. Requires a live verified task that selects that YAML.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <id> --device emulator-5554 --flavor dev --target maestro/<flow>.yaml
```

Raw `maestro test` and Maestro MCP are debug only. They never satisfy
`handoff check`. There is no `mobilekit maestro`. There is no
`runtime logs` command.

YAML runs attach `flutter logs` and stop it. Do not `fvm flutter run`
next to Maestro: `launchApp` kills that process.

The `dev` APK must already be installed. `--flavor prod` is rejected.

## Allowed commands

Use only these unless a later plan explicitly expands the set:

| Command | Use |
|---|---|
| `launchApp` + `clearState: true` | Cold start. Parent flow only. |
| `runFlow` | Shared subflows (`_register_to_home.yaml`) or `when: visible`. |
| `tapOn` | Text / `below` / `above` / `containsChild` / `enabled` / `index`. |
| `inputText` | Focused field. Env: `${MAESTRO_TEST_EMAIL}` etc. |
| `extendedWaitUntil` | Next screen or `enabled: true` before a submit tap. |
| `scrollUntilVisible` | Bring a labeled control on screen. |
| `waitForAnimationToEnd` | After fill, before `Next` / submit if the cubit lags. |

`appId` is `dev.fikril.mobile.corekit.dev`.

## Banned on this app

| Command / selector | Why |
|---|---|
| `hideKeyboard` | This Android emulator sends BACK and leaves the app. |
| `back` | Same class of footgun. |
| `tapOn: point:` / `%` coordinates | Breaks on density and IME. |
| `swipe` to scroll | Use `scrollUntilVisible`. |
| Flutter `Key` | Invisible to Maestro. |
| AI asserts (`assertWithAI`, `assertNoDefectsWithAI`, `extractTextWithAI`) | Not completion evidence. |
| Committed emails/passwords | Env only. |

Dismiss IME by tapping the **app-bar title** (`text: "Sign In"`,
`index: 0`). Never `hideKeyboard`.

## Selectors

Maestro `text` is a **full-string regex**.

- `Create one` does **not** match `Don’t have an account? Create one`.
  Use `.*Create one`.
- `Password` **does** match `Forgot password?`. Anchor the field:
  `containsChild: "Show password"` or `below: '^Password$'`.
- Labels are non-clickable Views. Tap the `EditText` **below** the
  label: `below: { text: '^Email$' }`.
- Prefer `^Exact label$` over `(?s).*Profile.*`. Greedy regex hits
  nav, headings, and other tiles.
- Duplicate text: use `index` (logout confirm is `Log out` index 1)
  or `enabled: true` on the submit control.
- Shell tab: `^Profile$`, not `.*Profile.*`.

Flutter: visible text or `Semantics` label. Optional `Semantics`
`identifier` maps to Maestro `id:` if the plan allows that Dart file.

## Identity

- Unique `MAESTRO_TEST_EMAIL` / `MAESTRO_TEST_PASSWORD` (minLength 10)
  per run. Password change also needs `MAESTRO_TEST_NEW_PASSWORD`.
- Fresh password users have empty `givenName` → complete-profile
  before Home. Reusing a completed user skips that screen.
- Flows that create the account in-app (`_register_to_home.yaml`) must
  **not** curl-register first (`AUTH_EMAIL_ALREADY_EXISTS`).
- `login.yaml` is the exception: curl-register, then type login.

## One flow, one YAML

Do not bolt merchant, logout, and reset onto `login.yaml`. New journey
= new `maestro/<flow>.yaml` + new `maestro-flow` oracle **before** the
queued V2 plan lists that Oracle ID.

Share prefixes with `runFlow: _register_to_home.yaml`. Parent launches
the app.

Hardcoded catalog strings (`Demo Bank Alpha`, `Sole proprietorship`)
are demo-seed only. If reference data changes, the YAML must change.

## Agent loop

```text
edit YAML
  → runtime evidence --device … --target maestro/<flow>.yaml
  → (fail) stdout + _artifacts/mobile/<ts>/logs/ + ~/.maestro/tests/
  → task verify --task <id> --env dev
  → runtime evidence --task <id> --device … --target maestro/<flow>.yaml
  → handoff check --task <id>
```

Do not forge `manual-evidence.json` for `runtime.mobile-evidence`.
