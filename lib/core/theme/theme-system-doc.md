# Orymu Mobile Theme System Documentation

A comprehensive guide to using the theme system in the Orymu Mobile Flutter application.

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Theme Structure](#theme-structure)
4. [Color System](#color-system)
5. [Typography System](#typography-system)
6. [Responsive Design](#responsive-design)
7. [Components](#components)
8. [Usage Examples](#usage-examples)
9. [Best Practices](#best-practices)
10. [Migration Guide](#migration-guide)

## Overview

The Orymu Mobile theme system provides a unified, responsive, and accessible design foundation for the Flutter application. It includes:

- **Unified Color Palette**: Consistent color tokens across light and dark themes
- **Responsive Typography**: Text that adapts to screen sizes and accessibility needs
- **Responsive Layout System**: Breakpoint-based responsive design utilities
- **Component Theming**: Pre-styled components with consistent design patterns
- **Accessibility Support**: Built-in accessibility features and WCAG compliance

## Quick Start

### 1. Apply Theme to Your App

```dart:lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orymu Mobile',
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
          Heading.h1('Welcome to Orymu'),
          Heading.h2('Getting Started'),
          Paragraph.large('This is a large paragraph with proper typography.'),
          AppText.bodyMedium('Regular body text'),
        ],
      ),
    );
  }
}
```

### 3. Use Responsive Layout

```dart:lib/widgets/responsive_widget.dart
import 'package:flutter/material.dart';
import '../core/theme/responsive/responsive_container.dart';
import '../core/theme/responsive/screen_utils.dart';
import '../core/theme/responsive/spacing.dart';

class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: AppSpacing.screenPadding(context),
        child: Column(
          children: [
            Text('Screen width: ${context.screenWidth}'),
            Text('Device type: ${context.isMobile ? "Mobile" : context.isTablet ? "Tablet" : "Desktop"}'),
          ],
        ),
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
│   └── theme_extensions_utils.dart
├── responsive/               # Responsive design system
│   ├── breakpoints.dart      # Screen breakpoints
│   ├── responsive_container.dart
│   ├── responsive_layout.dart
│   ├── responsive_scale.dart # Unified scaling system
│   ├── screen_utils.dart     # Screen utility extensions
│   ├── sizing.dart           # Component sizing
│   └── spacing.dart          # Spacing tokens
├── tokens/                   # Base color tokens
│   ├── primary_colors.dart
│   ├── secondary_colors.dart
│   └── ...
└── typography/               # Typography system
    ├── typography_system.dart # Main typography entry
    ├── components/           # Typography components
    │   ├── heading.dart
    │   ├── paragraph.dart
    │   └── text.dart
    ├── styles/               # Text styles
    │   ├── accessible_text_style.dart
    │   ├── responsive_text_styles.dart
    │   └── text_theme_builder.dart
    ├── tokens/               # Typography tokens
    │   ├── type_metrics.dart
    │   ├── type_scale.dart
    │   └── type_weights.dart
    └── utils/                # Typography utilities
        ├── line_height_calculator.dart
        └── typography_extensions.dart
```

## Color System

### Color Token Structure

The color system uses a two-layer approach:

1. **Base Tokens** (`tokens/`): Raw brand and neutral color values
2. **Theme Colors** (`ColorScheme` + `SemanticColors`): Colors used by UI components

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

#### 3. Brand token palettes (advanced)

```dart
// Access raw brand tokens when you need specific steps
final primaryTokens = context.primary; // PrimaryColors
final primary500 = primaryTokens.primary500;

final greyTokens = context.grey;       // GreyColors
final neutralBackground = greyTokens.grey100;
```

Token palettes are useful for design‑system primitives, charts, and marketing visuals. For regular app UI, prefer `ColorScheme` and `SemanticColors`.

### Available Color Palettes

- **Primary Colors**: Main brand colors (50-900 scale)
- **Secondary Colors**: Supporting brand colors
- **Tertiary Colors**: Accent colors
- **Grey Colors**: Neutral colors for text and backgrounds
- **Semantic Colors**: Red (error), Green (success), Yellow (warning), Blue (info)

## Typography System

### Typography Components

Use semantic typography components instead of raw Text widgets:

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
  color: Colors.blue,
  textAlign: TextAlign.center,
  maxLines: 2,
)
```

#### Paragraphs

```dart
// Optimized for reading
Paragraph.large('Large paragraph text for emphasis')
Paragraph.medium('Standard paragraph text')
Paragraph.small('Small paragraph text for captions')

// With paragraph spacing
Paragraph.medium(
  'Text with spacing',
  paragraphSpacing: 16.0,
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

// Custom text
AppText.custom(
  'Custom styled text',
  getStyle: (context) => ResponsiveTextStyles.bodyMedium(context),
  color: Colors.red,
  selectable: true,
)
```

### Typography Features

- **Responsive Scaling**: Text sizes adapt to screen size
- **Accessibility Support**: Respects user's text size preferences
- **Semantic Structure**: Proper heading hierarchy for screen readers
- **Consistent Line Heights**: Optimized for readability
- **Font Weight Variations**: Multiple weights available

## Responsive Design

### Breakpoints

The system uses three main breakpoints (matching `lib/core/theme/responsive/breakpoints.dart`):

```dart
// Breakpoint values
Breakpoints.sm = 600.0   // Small (mobile)
Breakpoints.md = 900.0   // Medium (tablet)
Breakpoints.lg = 1200.0  // Large (desktop)
Breakpoints.xl = 1536.0  // Extra large (desktop wide)
```

### Screen Utilities

Use the `ScreenUtils` extension for responsive logic:

```dart
// Device type detection
if (context.isMobile) {
  // Mobile-specific logic
} else if (context.isTablet) {
  // Tablet-specific logic
} else if (context.isDesktop) {
  // Desktop-specific logic
}

// Screen dimensions
final width = context.screenWidth;
final height = context.screenHeight;
final safeHeight = context.screenHeight - context.safeTopPadding - context.safeBottomPadding;

// Responsive values
final columns = context.gridColumns;                   // 2, 3, 4, or 6 columns
final maxWidth = context.contentMaxWidth;              // Responsive max width
final padding = AppSpacing.screenPadding(context);     // Responsive padding
```

### Responsive Container

Use `ResponsiveContainer` to constrain content width:

```dart
ResponsiveContainer(
  centerContent: true,  // Center the content
  child: Column(
    children: [
      // Your content here
    ],
  ),
)
```

### Responsive Layout Builder

```dart
ResponsiveLayout.builder(
  context: context,
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

// Or with values
final fontSize = ResponsiveLayout.value(
  context: context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);
```

### Spacing System

Use consistent spacing throughout the app:

```dart
// Fixed spacing values
AppSpacing.space4   // 4.0
AppSpacing.space8   // 8.0
AppSpacing.space16  // 16.0
AppSpacing.space24  // 24.0
AppSpacing.space32  // 32.0
// ... up to space96

// Responsive spacing
AppSpacing.screenPadding(context)     // Responsive screen padding
AppSpacing.sectionSpacing(context)    // Responsive section spacing
AppSpacing.componentSpacing(context)  // Responsive component spacing
```

## Components

### Using Theme Extensions

Access custom color tokens through theme extensions:

```dart
// Get custom colors
final primaryColors = Theme.of(context).extension<PrimaryColors>();
final buttonColors = Theme.of(context).extension<CompButtonColors>();

// Use in widgets
Container(
  color: primaryColors?.primary100,
  child: Text('Themed container'),
)
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
AppSizing.heroHeight(context)  // Responsive hero section height
AppSizing.modalWidth(context)  // Responsive modal width
```

## Usage Examples

### Complete Page Example

```dart:lib/pages/example_page.dart
import 'package:flutter/material.dart';
import '../core/theme/typography/components/heading.dart';
import '../core/theme/typography/components/paragraph.dart';
import '../core/theme/responsive/responsive_container.dart';
import '../core/theme/responsive/spacing.dart';
import '../core/theme/responsive/screen_utils.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Page'),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              Container(
                height: AppSizing.heroHeight(context),
                child: Center(
                  child: Heading.h1('Welcome to Orymu'),
                ),
              ),

              SizedBox(height: AppSpacing.sectionSpacing(context)),

              // Content section
              Heading.h2('About This App'),
              SizedBox(height: AppSpacing.componentSpacing(context)),

              Paragraph.large(
                'This is an example of how to use the Orymu theme system. '
                'The typography automatically adapts to different screen sizes '
                'and the layout responds to the current breakpoint.',
              ),

              SizedBox(height: AppSpacing.componentSpacing(context)),

              // Responsive grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.gridColumns,
                  crossAxisSpacing: AppSpacing.space16,
                  mainAxisSpacing: AppSpacing.space16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.space16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: AppSizing.iconSizeLarge,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(height: AppSpacing.space8),
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
Paragraph.medium('Body content')
```

❌ **Avoid**: Raw Text widgets with manual styling

```dart
Text('Page Title', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
```

### 2. Leverage Responsive Utilities

✅ **Good**: Use responsive utilities

```dart
Padding(
  padding: AppSpacing.screenPadding(context),
  child: child,
)
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

### 4. Responsive Layout Patterns

✅ **Good**: Use responsive containers and utilities

```dart
ResponsiveContainer(
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.gridColumns,
    ),
    // ...
  ),
)
```

### 5. Accessibility Considerations

- Always use semantic typography components for proper heading hierarchy
- Respect user's text size preferences (built into the system)
- Ensure sufficient color contrast (provided by the color tokens)
- Use meaningful widget semantics

## Migration Guide

### From Raw Text Widgets

**Before:**

```dart
Text(
  'Heading',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

**After:**

```dart
Heading.h2('Heading')
```

### From Fixed Layouts

**Before:**

```dart
Container(
  width: 300,
  padding: EdgeInsets.all(16),
  child: child,
)
```

**After:**

```dart
ResponsiveContainer(
  child: Padding(
    padding: AppSpacing.screenPadding(context),
    child: child,
  ),
)
```

### From Hardcoded Colors

**Before:**

```dart
Container(
  color: Color(0xFF6366F1),
  child: child,
)
```

**After:**

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
    return Card(
      margin: EdgeInsets.all(
        ResponsiveLayout.value(
          context: context,
          mobile: AppSpacing.space8,
          tablet: AppSpacing.space12,
          desktop: AppSpacing.space16,
        ),
      ),
      child: Padding(
        padding: AppSpacing.componentSpacing(context),
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
2. Review the `responsive-docs.md` for responsive-specific guidance
3. Check the `typography-guide.md` for typography-specific guidance
4. Refer to component examples in the codebase

The theme system is designed to be comprehensive yet flexible, providing a solid foundation for consistent, accessible, and responsive design throughout the Orymu Mobile application.
