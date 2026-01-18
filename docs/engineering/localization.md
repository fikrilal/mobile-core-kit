# Localization (i18n/l10n)

This repo uses Flutter’s first‑party localization toolchain (`gen-l10n`) with ARB files.

## Source of truth

- ARB files live in `lib/l10n/`
  - `lib/l10n/app_en.arb` (template locale)
  - `lib/l10n/app_id.arb` (example locale)
- Generated output is written to `lib/l10n/gen/` and is treated as build output (do not edit).

## Usage in code

- Use `context.l10n` (see `lib/core/localization/l10n.dart`).
- Prefer passing localized strings into shared widgets (e.g. `AppButton(text: ...)`) instead of hardcoding literals.

## Adding new strings (PR checklist)

1. Add the key to `lib/l10n/app_en.arb`.
2. Add the same key to all other shipped locales (e.g. `lib/l10n/app_id.arb`).
3. Add `@<key>` metadata:
   - `description` is required.
   - Add `placeholders` with `type` + `example` when the message takes arguments.
4. Run `flutter gen-l10n` (CI + `tool/verify.dart` run this deterministically).
5. Use the new string from `context.l10n`.

**PR review rule:** new user‑facing UI copy must come from ARB (including tooltips and semantics labels), except for dev‑only tooling/screens and test-only strings.

## Key naming convention

- `common*`: shared “generic” copy (OK/Cancel/Loading, etc).
- Prefer feature/domain prefixes for feature UI (e.g. `auth*`, `profile*`, `errors*`).

