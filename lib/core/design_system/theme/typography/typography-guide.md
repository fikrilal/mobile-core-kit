# Typography Guide (How to use in this repo)

This is the “day-to-day” typography guide for the core kit.

Canonical docs live in:

- `docs/explainers/core/theme/typography_system_proposal.md`
- `docs/explainers/core/theme/typography_system_review.md`

## Canonical API (what to use)

Use **`Theme.of(context).textTheme.*`** as the source of truth for the type ramp:

```dart
final t = Theme.of(context).textTheme;

Text('Title', style: t.titleLarge);
Text('Body', style: t.bodyMedium);
```

Use **role colors** (do not hardcode):

```dart
Text('Body', style: t.bodyMedium?.copyWith(color: context.textPrimary));
```

## Convenience widgets (allowed)

Use these when you want less boilerplate:

- `AppText.*` for most text
- `Heading.*` for semantic headings
- `Paragraph.*` for readable multi-line body text

These convenience widgets must remain **thin wrappers** over `textTheme`.

## Using alternate font families

If you need to render a specific piece of UI in another registered font
family (example: `SpaceGrotesk`), override `fontFamily`:

```dart
import 'package:mobile_core_kit/core/design_system/theme/typography/tokens/typefaces.dart';

AppText.titleLarge(
  'Space Grotesk title',
  fontFamily: Typefaces.secondary,
);
```

## Accessibility rules (non-negotiable)

1) Never “scale fonts manually”.
   - Text scaling is applied at the app root via `AdaptiveScope` using `TextScaler.clamp(...)`.
2) Do not pass `textScaler:` to text widgets in feature code.
3) Do not invent font sizes in feature code (`TextStyle(fontSize: ...)`).

## Guardrails (lint)

This repo enforces typography guardrails via custom lints:

- `hardcoded_font_sizes` — blocks `TextStyle(fontSize: ...)`, `copyWith(fontSize: ...)`, and `apply(fontSizeFactor/fontSizeDelta: ...)` in UI layers.
- `manual_text_scaling` — blocks `TextScaler.linear(...)` and per-widget `textScaler:` usage in UI layers.

Suppressions are allowed but should be rare and justified:

- File: `// ignore_for_file: <rule_name>`
- Line: `// ignore: <rule_name>`

## Phone/tablet guidance

We use a single type ramp for phone + tablet. Tablet readability is handled via:

- layout (split views, gutters, max content widths)
- `Paragraph` width constraints for long-form reading

Do not inflate font sizes by default to “make tablet look bigger”.

## When to use raw `Text` / `SelectableText`

If you need advanced behavior that the convenience widgets don’t support cleanly, use Flutter primitives directly with `textTheme` styles.
