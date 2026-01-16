# Mobile Core Kit Theme System

This is the guide to using the theme system in this template.

Start here for color rules + examples:
- `docs/explainers/core/theme/color_usage_guide.md`

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Theme Structure](#theme-structure)
4. [Color System](#color-system)
5. [Typography System](#typography-system)
6. [Adaptive Layout](#adaptive-layout)
7. [Components](#components)
8. [Usage Examples](#usage-examples)
9. [Best Practices](#best-practices)
10. [Refactoring Recipes](#refactoring-recipes)

## Overview

The theme system provides a unified, responsive, and accessible design foundation for the Flutter application. It includes:

- **Role-based colors**: `ColorScheme` + `SemanticColors` derived from seeds (contrast is gated by tests)
- **Typography System**: Token-based type ramp with accessibility-correct text scaling (via `TextScaler`)
- **Adaptive Layout System**: Constraint-first responsive + adaptive layout decisions (`lib/core/adaptive/`)
- **Component Theming**: Pre-styled components with consistent design patterns
- **Accessibility Support**: built-in text scaling support + WCAG contrast enforcement via `test/core/theme/color_contrast_test.dart`

## Quick Start

### 1. Apply Theme to Your App

```dart:lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Core Kit',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
```

### 2. Use Typography Components

```dart:lib/pages/example_page.dart
import 'package:flutter/material.dart';
import '../core/theme/typography/components/heading.dart';
import '../core/theme/typography/components/paragraph.dart';
import '../core/theme/typography/components/text.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Heading.h1('Welcome'),
          Heading.h2('Getting Started'),
          Paragraph.large('This is a large paragraph with proper typography.'),
          AppText.bodyMedium('Regular body text'),
        ],
      ),
    );
  }
}
```

### 3. Use Adaptive Layout

```dart:lib/widgets/responsive_widget.dart
import 'package:flutter/material.dart';
import '../core/adaptive/adaptive_context.dart';
import '../core/adaptive/tokens/surface_tokens.dart';
import '../core/adaptive/widgets/app_page_container.dart';

class AdaptiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;

    return AppPageContainer(
      surface: SurfaceKind.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Width class: ${layout.widthClass}'),
          Text('Height class: ${layout.heightClass}'),
          Text('Grid columns: ${layout.grid.columns}'),
        ],
      ),
    );
  }
}
```

## Theme Structure

```
lib/core/theme/
├── theme.dart                 # Main theme entry point
├── light_theme.dart          # Light theme configuration
├── dark_theme.dart           # Dark theme configuration
├── extensions/               # Theme extension utilities
│   ├── semantic_colors.dart
│   └── theme_extensions_utils.dart
├── system/                   # Seed → role derivation + policies
│   ├── app_color_seeds.dart
│   ├── app_color_scheme_builder.dart
│   ├── app_theme_builder.dart
│   ├── color_contrast.dart
│   ├── motion_durations.dart
│   └── state_opacities.dart
├── tokens/                   # Layout primitives (constants)
│   ├── spacing.dart          # Spacing scale
│   └── sizing.dart           # Component sizing
└── typography/               # Typography system
    ├── typography_system.dart # Main typography entry
    ├── components/           # Typography components
    │   ├── app_heading.dart
    │   ├── app_paragraph.dart
    │   ├── app_text.dart
    │   ├── heading.dart
    │   ├── paragraph.dart
    │   └── text.dart
    ├── styles/               # Text styles
    │   ├── accessible_text_style.dart
    │   └── text_theme_builder.dart
    ├── tokens/               # Typography tokens
    │   ├── type_metrics.dart
    │   ├── type_scale.dart
    │   └── type_weights.dart
    └── utils/                # Typography utilities
        └── line_height_calculator.dart
```

## Color System

### Color Token Structure

The color system uses a two-layer approach:

1. **Seeds** (`system/app_color_seeds.dart`): small set of hex inputs (brand + neutral + status)
2. **Theme roles** (`ColorScheme` + `SemanticColors`): the only colors UI should use

### Using Colors

#### 1. Preferred: `ColorScheme` and helpers

```dart
// Directly from ColorScheme
final cs = Theme.of(context).colorScheme;
final primary = cs.primary;
final surface = cs.surface;
final onSurface = cs.onSurface;

// Or via ThemeRoleColors extension (see theme_extensions_utils.dart)
final brand = context.brand;           // cs.primary
final onBrand = context.onBrand;       // cs.onPrimary
final textPrimary = context.textPrimary;
final border = context.border;
final bgContainer = context.bgContainer;
```

#### 2. Semantic status colors

```dart
final semantic = context.semanticColors;

final success = semantic.success;
final warning = semantic.warning;
final infoContainer = semantic.infoContainer;
final onWarningText = semantic.onWarning;
```

Use these for non‑Material status UI (badges, banners, charts) where `ColorScheme.error` is not enough.

#### 3. Seeds (advanced)

This theme derives its role colors from a small set of seeds (single hex inputs).

- Seeds live in `lib/core/theme/system/app_color_seeds.dart`
- Roles are generated in `lib/core/theme/system/app_color_scheme_builder.dart`

For app UI, prefer consuming the roles (`ColorScheme` + `SemanticColors`).

## Typography System

### Typography Components

Prefer semantic typography components for common cases. For advanced cases,
use Flutter `Text`/`SelectableText` with `Theme.of(context).textTheme.*`.

#### Headings

```dart
// Semantic headings with proper hierarchy
Heading.h1('Page Title')           // Largest heading
Heading.h2('Section Title')        // Section heading
Heading.h3('Subsection Title')     // Subsection heading
Heading.h4('Minor Heading')        // Minor heading
Heading.h5('Small Heading')        // Small heading
Heading.h6('Smallest Heading')     // Smallest heading

// With customization
Heading.h1(
  'Custom Heading',
  color: Theme.of(context).colorScheme.primary,
  textAlign: TextAlign.center,
  maxLines: 2,
)
```

#### Paragraphs

```dart
// Optimized for reading
Paragraph.large('Large paragraph text for emphasis')
Paragraph('Standard paragraph text')
Paragraph.small('Small paragraph text for captions')

// With paragraph spacing
Padding(
  padding: const EdgeInsets.only(bottom: 16.0),
  child: Paragraph('Text with spacing'),
)
```

#### General Text

```dart
// Various text styles
AppText.displayLarge('Display text')
AppText.headlineMedium('Headline text')
AppText.titleLarge('Title text')
AppText.bodyLarge('Body text')
AppText.labelMedium('Label text')

// Custom text (advanced): use Flutter Text directly with `textTheme`
final t = Theme.of(context).textTheme;
final scheme = Theme.of(context).colorScheme;

SelectableText(
  'Custom styled text',
  style: t.bodyMedium?.copyWith(color: scheme.error),
)
```

### Typography Features

- **Type ramp**: Token-based sizes for consistent hierarchy
- **Accessibility Support**: Respects user's text scaling via `TextScaler` (clamped at app root)
- **Semantic Structure**: Proper heading hierarchy for screen readers
- **Consistent Line Heights**: Optimized for readability
- **Font Weight Variations**: Multiple weights available

## Adaptive Layout

Adaptive layout is provided by `lib/core/adaptive/` and is intentionally separate
from ThemeData construction (ThemeData is context-free; adaptive decisions are
constraint/capability-driven at runtime).

### Size classes (industry-aligned)

Use window size classes (dp) derived from constraints:

```dart
enum WindowWidthClass { compact, medium, expanded, large, extraLarge }
enum WindowHeightClass { compact, medium, expanded }
```

### Preferred access pattern

Use aspect-specific accessors to avoid rebuild storms:

```dart
final layout = context.adaptiveLayout;
final insets = context.adaptiveInsets;

final padding = layout.pagePadding;      // responsive page padding
final columns = layout.grid.columns;     // responsive grid columns
final safe = insets.safePadding;         // safe areas
final keyboard = insets.viewInsets;      // keyboard/system insets
```

### Page layout

Use `AppPageContainer` to apply padding + safe area + content max width:

```dart
AppPageContainer(
  surface: SurfaceKind.reading,
  child: child,
);
```

### Nested panes

Use `AdaptiveRegion` to adapt a subtree to its own constraints (e.g. split panes).

### Spacing system

Use `AppSpacing` for the fixed scale inside components, and adaptive layout
tokens for page-level padding and layout decisions:

```dart
// Fixed spacing values
AppSpacing.space4   // 4.0
AppSpacing.space8   // 8.0
AppSpacing.space16  // 16.0
AppSpacing.space24  // 24.0
AppSpacing.space32  // 32.0
// ... up to space96
```

## Components

### Using Theme Extensions

Access custom semantic extensions through theme extensions:

```dart
final semantic = Theme.of(context).extension<SemanticColors>()!;

final bg = semantic.successContainer;
final fg = semantic.onSuccessContainer;
```

### Component Sizing

Use predefined component sizes:

```dart
// Button heights
AppSizing.buttonHeightSmall   // 32.0
AppSizing.buttonHeightMedium  // 40.0
AppSizing.buttonHeightLarge   // 48.0

// Icon sizes
AppSizing.iconSizeSmall   // 16.0
AppSizing.iconSizeMedium  // 24.0
AppSizing.iconSizeLarge   // 32.0

// Responsive utilities
// Prefer adaptive layout tokens for responsive layout decisions.
```

## Usage Examples

### Complete Page Example

```dart:lib/pages/example_page.dart
import 'package:flutter/material.dart';
import '../core/adaptive/adaptive_context.dart';
import '../core/adaptive/tokens/surface_tokens.dart';
import '../core/adaptive/widgets/adaptive_grid.dart';
import '../core/adaptive/widgets/app_page_container.dart';
import '../core/theme/typography/components/heading.dart';
import '../core/theme/typography/components/paragraph.dart';
import '../core/theme/tokens/spacing.dart';
import '../core/theme/tokens/sizing.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Page'),
      ),
      body: AppPageContainer(
        surface: SurfaceKind.reading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              SizedBox(
                height: 160,
                child: Center(child: Heading.h1('Welcome')),
              ),

              const SizedBox(height: AppSpacing.space32),

              // Content section
              Heading.h2('About This App'),
              const SizedBox(height: AppSpacing.space16),

              Paragraph.large(
                'This is an example of how to use the theme + adaptive layout system. '
                'Layout adapts via size classes and surface tokens; text scaling follows system settings.',
              ),

              const SizedBox(height: AppSpacing.space16),

              // Adaptive grid
              AdaptiveGrid.builder(
                columns: layout.grid.columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: AppSizing.iconSizeLarge,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          AppText.labelMedium('Item ${index + 1}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Custom Theme Example

```dart:lib/theme/custom_theme.dart
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class CustomTheme {
  static ThemeData createCustomTheme() {
    // Create a custom color scheme
    const customColorScheme = ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      surface: Color(0xFFFAFAFA),
      background: Color(0xFFFFFFFF),
      error: Color(0xFFEF4444),
    );

    // Apply to theme with typography
    return AppTheme.custom(
      colorScheme: customColorScheme,
      fontFamily: 'CustomFont',
    );
  }
}
```

## Best Practices

### 1. Use Semantic Components

✅ **Good**: Use semantic typography components

```dart
Heading.h1('Page Title')
Paragraph('Body content')
```

❌ **Avoid**: Raw Text widgets with manual styling

```dart
Text('Page Title', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
```

### 2. Leverage Adaptive Utilities

✅ **Good**: Use adaptive layout tokens/widgets

```dart
AppPageContainer(child: child)
```

❌ **Avoid**: Fixed values

```dart
Padding(
  padding: EdgeInsets.all(16.0),
  child: child,
)
```

### 3. Use Theme Colors

✅ **Good**: Access colors through theme

```dart
color: Theme.of(context).colorScheme.primary
```

❌ **Avoid**: Hardcoded colors

```dart
color: Color(0xFF6366F1)
```

### 4. Adaptive Layout Patterns

✅ **Good**: Use `AppPageContainer` and adaptive grid/tokens

```dart
AdaptiveGrid.builder(
  columns: context.adaptiveLayout.grid.columns,
  itemCount: items.length,
  itemBuilder: ...,
)
```

### 5. Accessibility Considerations

- Always use semantic typography components for proper heading hierarchy
- Respect user's text size preferences (built into the system)
- Ensure sufficient color contrast (provided by the color tokens)
- Use meaningful widget semantics

## Refactoring Recipes

### Prefer semantic typography components

**Avoid:**

```dart
Text(
  'Heading',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

**Prefer:**

```dart
Heading.h2('Heading')
```

### Prefer constraint-aware layout primitives

**Avoid:**

```dart
Container(
  width: 300,
  padding: EdgeInsets.all(16),
  child: child,
)
```

**Prefer:**

```dart
AppPageContainer(child: child)
```

### Prefer role colors (no hardcoded hex)

**Avoid:**

```dart
Container(
  color: Color(0xFF6366F1),
  child: child,
)
```

**Prefer:**

```dart
Container(
  color: Theme.of(context).colorScheme.primary,
  child: child,
)
```

## Advanced Usage

### Creating Custom Responsive Components

```dart
class CustomResponsiveCard extends StatelessWidget {
  final Widget child;

  const CustomResponsiveCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    return Card(
      margin: EdgeInsets.all(layout.gutter),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: child,
      ),
    );
  }
}
```

### Extending the Color System

```dart
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color accent;
  final Color highlight;

  const CustomColors({
    required this.accent,
    required this.highlight,
  });

  @override
  CustomColors copyWith({Color? accent, Color? highlight}) {
    return CustomColors(
      accent: accent ?? this.accent,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      accent: Color.lerp(accent, other.accent, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}
```

---

## Support

For questions or issues with the theme system:

1. Check the existing documentation in each module
2. Review `lib/core/adaptive/README.md` for adaptive layout guidance
3. Check `lib/core/theme/typography/typography-guide.md` (and `docs/explainers/core/theme/*`) for typography guidance
4. Refer to component examples in the codebase

The theme system is designed to be comprehensive yet flexible, providing a solid foundation for consistent, accessible, and responsive design throughout the application.
