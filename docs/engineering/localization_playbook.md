# Localization Playbook — Use, Modify, Scale

This is the “how to” companion to the architecture doc:
`docs/engineering/localization.md`

---

## 1) Day-to-day usage in code

### Use `context.l10n` in widgets

Use `BuildContext.l10n` (from `lib/core/localization/l10n.dart`) anywhere you have a `BuildContext`.

Example:

```dart
AppButton(text: context.l10n.commonConfirm, onPressed: ...)
```

### Don’t localize inside Domain

Domain code should stay framework‑free and should not import Flutter or generated l10n types.

Recommended pattern:
- Domain failures: keep them semantic (types/enums/codes).
- Presentation layer: map failures to localized copy using `context.l10n`.

If you need generic network error copy, use the core localizer:
`lib/core/network/exceptions/api_failure_localizer.dart`

---

## 2) Add a new string (PR checklist)

1. Add the new key to `lib/l10n/app_en.arb`.
2. Add the same key to every shipped locale:
   - `lib/l10n/app_id.arb`
   - `lib/l10n/app_en_XA.arb` (pseudo)
   - `lib/l10n/app_ar_XB.arb` (RTL pseudo)
   - `lib/l10n/app_ar.arb` (internal fallback for `ar-XB`, keep it aligned)
3. Add metadata (`@<key>`) — required by `required-resource-attributes: true`.
4. Run `flutter gen-l10n` (CI and `tool/verify.dart` do this too).
5. Use it from `context.l10n`.

Commands (WSL-safe):
- `tool/agent/flutterw --no-stdin gen-l10n`
- `tool/agent/flutterw --no-stdin analyze`
- `tool/agent/flutterw --no-stdin test`

---

## 3) Placeholders (parameters)

This repo enables `use-named-parameters: true`, so generated messages use named parameters.

ARB example:

```json
"profileGreeting": "Hello {name}",
"@profileGreeting": {
  "description": "Greeting shown on the profile header.",
  "placeholders": {
    "name": { "type": "String", "example": "Ari" }
  }
}
```

Usage:

```dart
Text(context.l10n.profileGreeting(name: user.firstName))
```

Important:
- In ARB JSON, `example` values should be strings (even for `int` placeholders).

---

## 4) Plurals / ICU messages

Use ICU syntax in ARB files (ARB → `gen-l10n` → `intl`).

Example:

```json
"commonItemsCount": "{count, plural, =0{No items} one{1 item} other{{count} items}}",
"@commonItemsCount": {
  "description": "Human-friendly item count with pluralization.",
  "placeholders": {
    "count": { "type": "int", "example": "2" }
  }
}
```

Usage:

```dart
Text(context.l10n.commonItemsCount(count: items.length))
```

---

## 5) Add a new locale (ship it)

1. Add a new ARB file under `lib/l10n/`:
   - Example: `lib/l10n/app_es.arb`
2. Copy all keys + metadata from `app_en.arb` (keep descriptions consistent).
3. Run `flutter gen-l10n` and fix any missing keys.
4. If you want to expose the locale in the in-app language override UI, update the language picker:
   - `lib/features/profile/presentation/pages/profile_page.dart`

Notes:
- `preferred-supported-locales` in `l10n.yaml` controls ordering/fallback preference.
- `LocaleController.supportedLocales` is the source of truth for what the app reports as supported at runtime.

---

## 6) User language override behavior

Behavior:
- `null` locale override means “follow system/device language”.
- Selecting a locale persists the user override via SharedPreferences (`LocaleStore`).
- Entry points load the persisted override before first frame to avoid a language flash.

Where to look:
- Persistence: `lib/core/services/localization/locale_store.dart`
- Runtime controller: `lib/core/services/localization/locale_controller.dart`
- App shell wiring: `lib/app.dart`
- UI entrypoint: `lib/features/profile/presentation/pages/profile_page.dart`

---

## 7) Pseudo-locales (dev QA)

We ship Android pseudo-locales for QA:
- `en-XA` (expansion/accent stress test)
- `ar-XB` (RTL stress test)

Rules:
- Only available in dev builds (`BuildConfig.env == BuildEnv.dev`).
- Never shipped in stage/prod supported locales.

Important nuance (Flutter requirement):
- `gen-l10n` requires a base fallback ARB for region/script locales.
  - So `ar-XB` requires `app_ar.arb` to exist.
- We keep `app_ar.arb` internal and filter it out from supported locales to avoid enabling real Arabic via device locale matching.

When adding new keys:
- Update the pseudo ARBs too, or generation will fail due to missing keys.

---

## 8) Localized network errors (ApiFailure)

Use the core localizer to show safe, localized error messages:
- `lib/core/network/exceptions/api_failure_localizer.dart`

Example integration (UI layer):

```dart
try {
  await repoCall();
} on ApiFailure catch (f) {
  AppSnackBar.showError(context, message: messageFor(f, context.l10n));
}
```

Scaling rule:
- Keep `api_failure_localizer.dart` generic (offline/timeout/auth/rate-limit/server).
- For feature-specific backend codes, map `ApiFailure.code` to feature strings in that feature’s presentation/repository layer.

---

## 9) Scaling guidelines (enterprise-friendly, not over-engineered)

- Keep one ARB per locale (single namespace) and use prefixes to avoid collisions:
  - `common*`, `errors*`, then feature prefixes like `auth*`, `profile*`, `settings*`.
- Keep localization calls in presentation. Prefer passing localized copy into shared widgets.
- Keep translator context strong:
  - Always add `@key.description`
  - Use placeholder metadata (`type`, `example`)
- Translation workflow:
  - ARB files are compatible with common TMS platforms (Crowdin/Lokalise/etc).
  - Pseudo locales provide a cheap, continuous UI QA safety net.
- CI remains deterministic because generation runs before analyze/tests.

