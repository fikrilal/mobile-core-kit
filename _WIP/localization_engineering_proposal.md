# Localization (i18n/l10n) Proposal — Mobile Core Kit

**Status:** proposal (not implemented)  
**Owner:** Core / Platform  
**Audience:** engineers building features on top of this template  

## Why this matters (enterprise context)

Top-tier consumer and enterprise apps treat localization as **product infrastructure**, not a late-stage “string replacement” task:

- **All user-facing copy** is source-controlled, reviewable, and keyed (stable identifiers).
- **Runtime correctness** is guaranteed by code generation (no “missing key at runtime” surprises).
- **Formatting** (dates, numbers, plurals, genders) uses ICU/CLDR rules, not ad-hoc string concatenation.
- **Translation workflow** is automated (export/import with a TMS like Lokalise/Phrase/Crowdin), with clear translator context and placeholder constraints.
- **Quality gates** exist (lint/tests/pseudo-locales/RTL checks) without over-engineering the app code.

This template already has strong design-system and architecture guardrails. Localization should match that standard with a minimal, idiomatic Flutter approach.

---

## Current state (in this repo)

- `intl` is present in `pubspec.yaml` and is already used for date formatting initialization (`initializeDateFormatting`).
- The app shell uses `MaterialApp.router` in `lib/app.dart`.
- There is no Flutter localization setup yet:
  - missing `flutter_localizations` dependency
  - no ARB files
  - no generated `AppLocalizations`
  - many UI strings are hardcoded (e.g. app title, button labels in showcase screens).

---

## Goals

1. **Adopt Flutter’s first-party localization stack** (best practice, maintainable, widely understood).
2. **Enable high-quality translations** (ICU plural/select, placeholder typing, translator notes).
3. **Keep the implementation simple** (no custom localization frameworks, minimal surface area).
4. **Provide a path to enterprise needs**:
   - optional user language override (persisted)
   - pseudo-locales + RTL sanity checks
   - mapping backend error codes → localized messages

## Non-goals (for initial implementation)

- Building a full “string linting” system that blocks all string literals. (We can add targeted guardrails later.)
- Creating a translation management integration in-repo (we’ll document the workflow, not build the TMS).
- Localizing every last string in the template on day one (we’ll stage the migration).

---

## Recommended approach (what most top Flutter apps do)

Use Flutter’s built-in **gen-l10n** tool with **ARB files**.

Why:
- Official Flutter approach (stable, supported).
- Generates a strongly-typed `AppLocalizations` API.
- Supports ICU messages (plurals, selects) and typed placeholders.
- Clean CI story: `flutter gen-l10n` can be a deterministic step.

We should avoid 3rd-party wrappers (`easy_localization`, etc.) unless we have a specific need they solve. The template’s ethos is “enterprise-grade defaults” with minimal magic.

**Important (forward-compat):** do not rely on the default synthetic `flutter_gen` import path for localizations. Instead, explicitly configure `gen-l10n` to generate into a known `lib/` folder and import from the app package. This keeps the template resilient to Flutter tooling changes and makes the generated output location obvious (an enterprise expectation).

---

## Technical design

### 0) Enable Flutter code generation (required)

Add to `pubspec.yaml`:

```yaml
flutter:
  generate: true
```

This is required for Flutter’s localization generation to work reliably on current Flutter versions.

### 1) Add localization dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any # prefer Flutter-pinned intl to avoid version skew
```

`flutter_localizations` provides the built-in delegates for Material/Cupertino widgets and is required for proper locale-aware UI formatting.

Notes:
- This repo already depends on `intl`. For a template repo, `intl: any` is usually the safest long-term default because Flutter pins a compatible version via `flutter_localizations`. If we have a hard product constraint later, we can tighten it.

### 2) Add ARB source of truth

Directory:
- `lib/l10n/`

Files (initial):
- `lib/l10n/app_en.arb` (template locale)
- `lib/l10n/app_id.arb` (optional example; pick based on product needs)

Key conventions:
- **lowerCamelCase** keys, grouped by prefix:
  - `appTitle`
  - `commonOk`, `commonCancel`
  - `authSignInTitle`, `authEmailLabel`
  - `errorsNetworkOffline`, `errorsUnexpected`
- Provide `@key` metadata for translator context:
  - description
  - placeholders + examples

Example:

```json
{
  "appTitle": "Mobile Core Kit",
  "@appTitle": {
    "description": "Flutter app title (e.g., Android task switcher/recents, web title). iOS app name is controlled by Info.plist / native localization."
  },
  "commonOk": "OK",
  "@commonOk": { "description": "Generic confirmation button label" }
}
```

### 3) Configure gen-l10n

Add `l10n.yaml` at repo root for deterministic generation settings and stable import paths:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb

# Generate into lib/ for a stable import path (avoid relying on flutter_gen).
output-dir: lib/l10n/gen

output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false

# Enterprise polish (low-cost, high leverage)
required-resource-attributes: true
untranslated-messages-file: tool/untranslated_messages.json
preferred-supported-locales: [en, id]
use-named-parameters: true
```

Notes:
- Generated code is written under `lib/l10n/gen/` via `output-dir`.
- Avoid setting `synthetic-package`: it is deprecated in current Flutter tooling and triggers warnings.
- Treat `lib/l10n/gen/` as generated output (do not hand-edit). Prefer **not committing** it and ensure CI/verify runs `flutter gen-l10n` deterministically (and add `lib/l10n/gen/` to `.gitignore`).
- `required-resource-attributes: true` ensures every message has metadata (description, placeholder typing) — critical for translator quality in real orgs.
- `untranslated-messages-file` provides a machine-readable missing-translation report for CI; treat it as generated output (ignore or upload as a CI artifact).
- `preferred-supported-locales` makes fallback ordering deterministic.
- `use-named-parameters` improves readability and reduces placeholder misuse for multi-arg messages.

### 4) Wire localization into the app shell

Update `lib/app.dart` `MaterialApp.router`:
- add `localizationsDelegates`
- add `supportedLocales`
- optionally provide `localeResolutionCallback` (defensive)
- replace hardcoded `title:` with a localized title (use `onGenerateTitle:` so it has `BuildContext`)

Canonical wiring:

```dart
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

MaterialApp.router(
  onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

Note on “app name”:
- `onGenerateTitle` localizes Flutter’s application title where it is used (Android recents, web, etc.).
- iOS app name is controlled by native metadata (`Info.plist` / `InfoPlist.strings`) and is a separate concern.

### 5) Add a tiny ergonomic API (optional but recommended)

Provide a single extension in `lib/core/localization/l10n.dart`:

```dart
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

Then feature code uses:
- `context.l10n.commonOk`

This matches existing patterns (`context.cs`, `context.semanticColors`, `context.adaptiveLayout`).

### 6) Staged migration of strings (avoid a “big bang”)

Phase 1 (core + shell):
- `lib/app.dart` title and any app-wide strings
- navigation labels (if any)
- shared widgets that ship with “public API” copy (e.g., default loading labels)

Phase 2 (features):
- Auth feature screens and validation messages
- any snackbar/dialog copy

Phase 3 (system messages):
- map API failure codes to user-facing localized messages (see below)

---

## Handling dates, numbers, and plurals (best practice)

### Dates/numbers
- Use `intl` with the current locale:
  - `final locale = Localizations.localeOf(context).toLanguageTag();`
  - `DateFormat.yMMMd(locale).format(date)`
- For Material widgets, prefer `MaterialLocalizations` where it fits (it automatically uses locale rules).

### Plurals / ICU
Use ARB plural syntax and generated methods:

```json
{
  "inboxUnreadCount": "{count,plural, =0{No unread messages} =1{1 unread message} other{{count} unread messages}}",
  "@inboxUnreadCount": {
    "description": "Unread count label",
    "placeholders": { "count": { "type": "int", "example": 3 } }
  }
}
```

In Dart:
- `context.l10n.inboxUnreadCount(count)`

---

## Enterprise extensions (proposed, optional)

### A) User language override (persisted)

If product requires a manual language picker:
- follow the existing pattern used by `ThemeModeController`/`ThemeModeStore`
  - `LocaleStore` (SharedPreferences)
  - `LocaleController` (ValueNotifier<Locale?>)
- wire `MaterialApp.router(locale: controller.value, ...)`
- default is `null` (system locale)

This is a small, familiar pattern in this codebase.

### B) Backend error codes → localized messages

Top apps almost never show raw backend error strings. They:
- log raw error details for telemetry
- map error **codes** to localized copy for the UI

We already have:
- `lib/core/network/exceptions/api_error_codes.dart`
- `ApiFailure.code`

Proposal:
- create `lib/core/network/exceptions/api_failure_localizer.dart`
  - `String messageFor(ApiFailure failure, AppLocalizations l10n)`
- default fallback: `l10n.errorsUnexpected`
- special cases: offline, timeout, unauthenticated, etc.

### C) Pseudo-locales and RTL QA

Recommended QA modes (debug/dev only):
- `en-XA` pseudo locale (accented + expanded strings)
- `ar-XB` pseudo RTL locale

Implementation options:
- include pseudo locales in supported locales only in dev builds
- add ARB files like `app_en_XA.arb` / `app_ar_XB.arb` (or a small script to generate them)
- add a simple “Developer → Localization” screen to switch locale override (if we implement locale override)

---

## Tooling / CI integration

To keep CI deterministic:

1. Add a step after `flutter pub get` and before `flutter analyze` (both in `tool/verify.dart` and the shipped GitHub Actions workflow):
   - `flutter gen-l10n`
2. Keep `flutter analyze` after generation so imports like
   - `package:mobile_core_kit/l10n/gen/app_localizations.dart`
   are always present.

Optional future gate:
- a small Dart script to validate ARB shape:
  - all keys have `@key.description`
  - placeholder types are declared
  - no duplicate/mismatched placeholders across locales

---

## Testing strategy (minimal but meaningful)

Add tests under `test/core/localization/`:

- `app_localizations_smoke_test.dart`
  - loads `AppLocalizations` for each supported locale
  - asserts a few representative keys exist
- `pluralization_test.dart`
  - verifies plural/select outputs for a couple of languages (where rules differ)

Keep tests “contract-level” (don’t assert exact translations beyond sanity).

---

## Rollout plan (recommended)

1) Scaffold:
- add deps + `l10n.yaml` + `lib/l10n/app_en.arb` + `lib/l10n/app_id.arb` (template ships with `en` + `id`)
- wire `MaterialApp.router` delegates/locales
- add `context.l10n` extension
- update verify to run `flutter gen-l10n`

2) Migrate core strings:
- app title
- any default widget copy that’s user-visible

3) Migrate features over time:
- enforce “new strings must be localized” in PR review
- optionally add a lint later if this becomes a recurring source of regressions

---

## Open questions

1. Which locales should the template ship with by default?
   - Decision: ship `en` + `id` (use `id` as the reference/example locale)
2. Do we want to support user language override in the template, or keep it as a documented extension?
   - Decision: include a user language override (persisted) in the template
3. Do we want pseudo-locales wired by default in dev builds?
   - Decision: include pseudo-locales (`en-XA`, `ar-XB`) in dev builds by default

---

## Appendix: file list (expected changes when implemented)

- `pubspec.yaml` (add `flutter_localizations`, set `flutter: generate: true`, set `intl: any`)
- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_id.arb`
- `.gitignore` (ignore `lib/l10n/gen/` and `tool/untranslated_messages.json`)
- `lib/app.dart` (wire delegates, supportedLocales, localized title)
- `lib/core/localization/l10n.dart` (ergonomic `context.l10n`)
- `tool/verify.dart` (add `flutter gen-l10n` step)
- `test/core/localization/*` (smoke + plural tests)
