# Localization (i18n/l10n) — Architecture

This repo uses Flutter’s first‑party localization toolchain (`gen-l10n`) with ARB files and a small, explicit runtime surface.

If you’re looking for day‑to‑day steps (add a string, add a locale, pseudo‑locale QA), see:
`docs/engineering/localization_playbook.md`

---

## Goals

- Deterministic builds: generated l10n output is not committed; CI runs `gen-l10n` before analyze/tests.
- Small surface area: `context.l10n` and a single app‑shell wiring point.
- Safe UX: user locale override (persisted) and dev‑only pseudo‑locales for QA.
- Safe errors: map transport/backend failures to localized, user‑friendly copy.

---

## Source of truth vs generated output

- **Source of truth**: `lib/l10n/app_*.arb`
  - `lib/l10n/app_en.arb` (template locale)
  - `lib/l10n/app_id.arb` (example locale)
  - `lib/l10n/app_en_XA.arb` (dev pseudo‑locale)
  - `lib/l10n/app_ar_XB.arb` (dev RTL pseudo‑locale)
  - `lib/l10n/app_ar.arb` (internal fallback required by `gen-l10n` for `ar-XB`, not shipped)
- **Generated output**: `lib/l10n/gen/` (do not edit; ignored by Git)

---

## Generation config (toolchain)

Configured via:
- `pubspec.yaml` → `flutter: generate: true`
- `l10n.yaml` → `arb-dir`, `output-dir`, and enterprise toggles:
  - `required-resource-attributes: true` (forces `@key.description`)
  - `untranslated-messages-file: .tmp/untranslated_messages.json`
  - `preferred-supported-locales: [en, id]`
  - `use-named-parameters: true`

Determinism:
- `mobilekit verify` runs `flutter gen-l10n` before `flutter analyze`.
- CI runs `flutter gen-l10n` before `flutter analyze`.

## Mechanical enforcement

`hardcoded_ui_strings` is the static sensor for copy that never entered ARB.
It reports non-empty direct string literals passed to registered user-visible
or accessibility arguments in configured production UI paths. The baseline
registry covers Flutter text, semantics, tooltip, input-decoration, and
navigation APIs plus core design-system text, button, field, snackbar, search,
and bottom-navigation APIs.

Matching is target-and-argument aware. An unrelated API is not reported merely
because it has a parameter named `label`, `message`, or `title`. Interpolations
containing fixed prose are reported; interpolation-only expressions and values
that have already been localized are accepted.

This is intentionally not whole-program data-flow analysis. Copy stored in a
variable or returned through another layer is outside the initial detector, so
presentation APIs should accept already-localized values at their boundary.

Consumer repositories can add their own presentation sinks without replacing
the defaults:

```yaml
- hardcoded_ui_strings:
  include:
    - lib/features/**
    - lib/navigation/**
  sinks:
    - target: MoodChartItem
      named_arguments: [label]
    - target: ProductCopy
      positional_arguments: [1]
```

Sink configuration is closed and strict: `target` must be a Dart identifier,
named arguments must be unique identifiers, positional arguments must be
unique non-negative indexes, and duplicate targets are rejected. Use a
line-level `// ignore: hardcoded_ui_strings` only for a reviewed exception; do
not exclude production feature directories to migrate existing debt.

This sensor complements rather than replaces generation checks:

| Sensor | Invariant |
| --- | --- |
| `hardcoded_ui_strings` | Registered UI sinks do not receive fixed direct copy. |
| `flutter gen-l10n` | ARB structure and generated APIs are valid. |
| `mobilekit l10n verify` | Declared messages exist in required locale files. |

---

## Runtime wiring

### Access: `context.l10n`

`lib/core/localization/l10n.dart` defines `BuildContext.l10n`, which wraps `AppLocalizations.of(context)`.

### App shell: `MaterialApp.router`

`lib/app.dart` is the single wiring point for:
- `localizationsDelegates: AppLocalizations.localizationsDelegates`
- `supportedLocales: ...` (filtered by build env)
- `locale: ...` (user override, persisted)
- `localeListResolutionCallback: ...` (safe locale selection)

### Supported locales and persisted override

- `LocaleStore` persists the user’s override in SharedPreferences (`key: locale`).
- `LocaleController` loads/applies that override and exposes `supportedLocales` filtered by `BuildConfig.env`.

Env gating:
- `dev`: includes pseudo‑locales (`en-XA`, `ar-XB`) for QA.
- `stage/prod`: excludes pseudo‑locales.

### Pseudo‑locales (dev‑only)

We ship Android pseudo‑locales for QA:
- `en-XA`: accent/expansion stress test
- `ar-XB`: forced RTL stress test

Important nuance:
- Flutter requires a base locale ARB for region/script locales (so `ar-XB` requires `app_ar.arb`).
- We include `lib/l10n/app_ar.arb` only as the required fallback, and explicitly keep it out of supported locales so devices don’t auto‑resolve into real Arabic.
  - `LocaleController.supportedLocales` filters out the internal `ar` fallback.
  - The app’s locale resolution callback refuses to auto‑select pseudo‑locales by language match.

### Localized network errors

`lib/core/infra/network/exceptions/api_failure_localizer.dart` provides:
- `messageFor(ApiFailure failure, AppLocalizations l10n)`

This maps common `ApiFailure.code` / HTTP status codes to localized, user‑friendly copy and avoids showing raw backend strings by default.

---

## Tests

Contract-level coverage:
- `test/core/presentation/localization/app_localizations_smoke_test.dart`
- `test/core/presentation/localization/pluralization_test.dart`
- `test/core/runtime/localization/locale_controller_test.dart`
- `test/core/infra/network/exceptions/api_failure_localizer_test.dart`
- `packages/mobile_core_kit_lints/test/hardcoded_ui_strings_test.dart`
