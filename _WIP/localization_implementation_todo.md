# TODO — Implement Localization (gen-l10n) in Mobile Core Kit

This is the execution checklist for `_WIP/localization_engineering_proposal.md`.

## Phase 0 — Decisions (before coding)

- [x] Ship the template with `en` + `id` locales (include `id` as the reference/example locale).
- [x] Include a **user language override** (persisted) in the template (implement in Phase 5A).
  - `User language override` = an in-app setting that lets users pick a language (saved locally) instead of always following the OS/system language. Technically this means setting `MaterialApp.router(locale: ...)` to a chosen `Locale?`.
- [x] Include **pseudo-locales** (`en-XA`, `ar-XB`) in dev builds by default (implement in Phase 5C).
  - `Pseudo-locales` = dev-only “fake” locales used to QA UI issues (string expansion, truncation, and RTL layout) without needing real translations. They should never ship in release builds.

## Phase 1 — Scaffold (minimal working localization)

### Pubspec + generation

- [x] Update `pubspec.yaml`
  - [x] Add `flutter_localizations` dependency
  - [x] Switch `intl` to `any` (prefer Flutter-pinned)
  - [x] Add `flutter:\n  generate: true`
- [x] Add `l10n.yaml` (repo root) with:
  - [x] `arb-dir: lib/l10n`
  - [x] `template-arb-file: app_en.arb`
  - [x] `output-dir: lib/l10n/gen`
  - [x] `output-localization-file: app_localizations.dart`
  - [x] `output-class: AppLocalizations`
  - [x] `nullable-getter: false`
  - [x] Enterprise toggles:
    - [x] `required-resource-attributes: true`
    - [x] `untranslated-messages-file: tool/untranslated_messages.json`
    - [x] `preferred-supported-locales: [en, id]`
    - [x] `use-named-parameters: true`

### ARB source of truth

- [x] Create `lib/l10n/app_en.arb`
  - [x] Add `appTitle`, `commonOk`, `commonCancel` (minimum viable)
  - [x] Add `@key` metadata (`description`, placeholder typing/examples when applicable)
- [x] Create `lib/l10n/app_id.arb` (example locale)
  - [x] Mirror keys from `app_en.arb`
  - [x] Provide Indonesian translations (keep metadata; translator notes can stay English)

### Generated output hygiene

- [x] Update `.gitignore`
  - [x] Ignore `lib/l10n/gen/`
  - [x] Ignore `tool/untranslated_messages.json`

### App shell wiring

- [x] Update `lib/app.dart`
  - [x] Import `package:mobile_core_kit/l10n/gen/app_localizations.dart`
  - [x] Use `onGenerateTitle: (context) => AppLocalizations.of(context).appTitle`
  - [x] Add `localizationsDelegates: AppLocalizations.localizationsDelegates`
  - [x] Add `supportedLocales: AppLocalizations.supportedLocales`
  - [x] Ensure this remains compatible with `MaterialApp.router` + `GoRouter`

### Ergonomics

- [x] Add `lib/core/localization/l10n.dart`
  - [x] `extension L10nX on BuildContext { AppLocalizations get l10n => AppLocalizations.of(this); }`
- [ ] Prefer using `context.l10n.*` in new feature code going forward.

## Phase 2 — Tooling / CI (deterministic generation)

- [ ] Update `tool/verify.dart`
  - [ ] Add step `flutter gen-l10n` after `flutter pub get` and before `flutter analyze`
  - [ ] Ensure `verify.dart` fails if generation fails (non-zero exit)
- [ ] Confirm local workflows:
  - [ ] `tool/agent/flutterw --no-stdin gen-l10n`
  - [ ] `dart run tool/verify.dart --env dev`

## Phase 3 — Template migration (high-impact strings first)

- [ ] Migrate app-level strings
  - [ ] App title (`lib/app.dart`)
  - [ ] Any shared widget default copy that’s user-visible (loading labels, empty states, etc.)
- [ ] Create a convention for new strings:
  - [ ] New UI copy must be added to ARB (PR review rule).

## Phase 4 — Tests (contract-level)

- [ ] Add `test/core/localization/app_localizations_smoke_test.dart`
  - [ ] Load `AppLocalizations` for each supported locale
  - [ ] Assert a handful of keys are present (no hardcoding of translations beyond sanity)
- [ ] Add `test/core/localization/pluralization_test.dart`
  - [ ] Validate at least one pluralized message for 2 locales (where rules differ), if/when added.

## Phase 5 — Enterprise extensions (optional, staged)

### A) User language override (persisted)

- [ ] Add `LocaleStore` (SharedPreferences) + `LocaleController` (ValueNotifier) mirroring `ThemeModeStore/Controller`
- [ ] Wire `MaterialApp.router(locale: ...)` with `null` meaning “system default”
- [ ] Add a minimal UI entrypoint (settings/dev tools) to switch locale

### B) Backend error codes → localized messages

- [ ] Add `lib/core/network/exceptions/api_failure_localizer.dart`
  - [ ] `String messageFor(ApiFailure failure, AppLocalizations l10n)`
  - [ ] Map common cases (offline/timeout/unauthenticated) to localized copy
  - [ ] Fallback to `l10n.errorsUnexpected`

### C) Pseudo-locales / RTL QA

- [ ] Decide implementation approach:
  - [ ] Add `lib/l10n/app_en_XA.arb` and `lib/l10n/app_ar_XB.arb`, or
  - [ ] Add a tiny script under `tool/` to generate pseudo ARBs for dev builds
- [ ] Ensure pseudo-locales are enabled only for dev/debug builds (avoid shipping them unintentionally)

## Done criteria (definition of “implemented”)

- [ ] `flutter gen-l10n` runs cleanly in local dev and CI/verify.
- [ ] `lib/app.dart` uses localized title + delegates/locales.
- [ ] At least one screen/widget consumes `context.l10n.*` successfully.
- [ ] Smoke tests exist and pass.
- [ ] Generated output is not committed and is ignored by Git.
