# Fonts (Template Customization)

This template ships with a bundled custom font so teams can clone it and keep typography deterministic across platforms.

## Current Setup

- Font family: `InterTight`
- Assets: `assets/fonts/InterTight-*.ttf`
- License: `assets/fonts/OFL.txt` (SIL Open Font License)
- Registration: `pubspec.yaml` → `flutter: fonts:`
- Default selection:
  - `lib/core/theme/typography/typography_system.dart` → `TypographySystem.fontFamily`
  - Theme text styles are built from that choice (see `lib/core/theme/typography/`).

## How To Change The Font

1) Add your font files to `assets/fonts/` (TTF/OTF).

2) Register the family in `pubspec.yaml` under `flutter: fonts:`.
   - Ensure weights match the files you provide (100..900).
   - Provide italic variants where available.

3) Update the default font family:
   - Edit `lib/core/theme/typography/typography_system.dart` and set `TypographySystem.fontFamily` to your new family name.

4) Run:
   - `fvm flutter pub get`
   - `fvm flutter run`

## Sizing / Performance Notes

- Bundling many separate weights increases app size. If you don’t need all weights, remove unused files and delete their entries in `pubspec.yaml`.
- Variable fonts can reduce the number of files (and size) significantly, but you still need to validate weight rendering across Android/iOS.

## Licensing Checklist

- Keep the font license text in-repo under `assets/fonts/` (example: `assets/fonts/OFL.txt`).
- If you replace the font, replace the license file too.
- If your legal process requires it, also mention font licensing in your product’s `LICENSE`/about screen documentation.

