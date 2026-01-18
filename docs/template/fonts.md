# Fonts (Template Customization)

This template ships with a bundled custom font so teams can clone it and keep typography deterministic across platforms.

## Current Setup

- Default font family: `Inter`
- Additional font families:
  - `SpaceGrotesk`
- Assets (variable fonts):
  - `assets/fonts/Inter-VariableFont_opsz_wght.ttf` (upright)
  - `assets/fonts/Inter-Italic-VariableFont_opsz_wght.ttf` (italic)
  - `assets/fonts/SpaceGrotesk-VariableFont_wght.ttf` (upright)
- License: `assets/fonts/OFL.txt` (SIL Open Font License; covers Inter + Space Grotesk)
- Registration: `pubspec.yaml` → `flutter: fonts:`
- Default selection:
  - `lib/core/theme/typography/tokens/typefaces.dart` → `Typefaces.primary`
  - `lib/core/theme/typography/typography_system.dart` → `TypographySystem.fontFamily` (wired to `Typefaces.primary`)
  - Theme text styles are built from that choice (see `lib/core/theme/typography/`).

## How To Change The Font

1) Add your font files to `assets/fonts/` (TTF/OTF).

2) Register the family in `pubspec.yaml` under `flutter: fonts:`.
   - Ensure weights match the files you provide (100..900).
   - Provide italic variants where available.

3) Update the default font family:
   - Update `lib/core/theme/typography/tokens/typefaces.dart` and set `Typefaces.primary` to your new family name.

4) Run:
   - `fvm flutter pub get` (WSL: `tool/agent/flutterw pub get`)
   - `fvm flutter run` (WSL: `tool/agent/flutterw run`)

## Sizing / Performance Notes

- Variable fonts keep size smaller and simplify maintenance (two files instead of many).
- If you prefer static fonts, you can ship per-weight TTFs instead; just update `pubspec.yaml` and keep only the weights you use.

## Licensing Checklist

- Keep the font license text in-repo under `assets/fonts/` (example: `assets/fonts/OFL.txt`).
- If you replace the font, replace the license file too.
- If your legal process requires it, also mention font licensing in your product’s `LICENSE`/about screen documentation.
