# Typography System Implementation Guide

This document explains how to use the new responsive typography system in your Flutter project. The system follows industry best practices used by top tech companies like Google, Apple, and leading design-focused organizations.

## Overview

The typography system is organized into several components:

1. **Typography Tokens**: Fixed values and definitions
2. **Responsive Styles**: Styles that adapt to different screen sizes
3. **Accessible Styles**: Styles that respect user accessibility preferences
4. **Text Components**: Ready-to-use UI components
5. **Utilities**: Helper methods and extensions

## Getting Started

1. Apply the typography system to your app's theme:

```dart
// In your main.dart or theme configuration
import 'core/theme/theme.dart';

return MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  // ...
);
```

## Using Typography Components

### Headings

Use semantic headings for titles and section headers:

```dart
// Level 1 (most prominent)
Heading.h1('Page Title')

// Level 2
Heading.h2('Section Title')

// Level 3
Heading.h3('Subsection Title')

// With customization
Heading.h2(
  'Section Title', 
  color: Theme.of(context).colorScheme.primary,
  textAlign: TextAlign.center,
)
```

### Text

Use the `AppText` component for general text:

```dart
// Standard text variants
AppText.displayLarge('Large Display Text')
AppText.headlineMedium('Medium Headline')
AppText.bodyMedium('Regular body text for content')
AppText.labelSmall('Small label text')

// With customization
AppText.titleLarge(
  'Title Text',
  color: Colors.blue,
  maxLines: 2,
)
```

### Paragraphs

Use the `Paragraph` component for multi-line body text:

```dart
// Regular paragraph
Paragraph(
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam in dui mauris. Vivamus hendrerit arcu sed erat molestie vehicula.',
)

// Large paragraph
Paragraph.large(
  'This is a larger paragraph text with better readability for important content.',
)

// With customization
Paragraph(
  'Custom paragraph with alignment and selection.',
  textAlign: TextAlign.center,
  selectable: true,
)
```

### Recommended Usage (Keep it Simple)

In everyday code, prefer a small, consistent set of parameters:

```dart
// Page titles and section headings
Heading.h1(
  'Page Title',
  color: context.brand,
);

Heading.h2(
  'Section Title',
  color: context.textPrimary,
  textAlign: TextAlign.left,
);

// Body copy
AppText.bodyMedium(
  'Body text goes here',
  color: context.textPrimary,
  maxLines: 3,
);

// Small labels
AppText.labelSmall(
  'Label',
  color: context.textSecondary,
);
```

Stick to `text`, `color`, `textAlign`, `maxLines`, and occasionally `padding`/`margin` and `selectable`.  
For complex cases (custom selection behavior, drag, etc.), use Flutter's `Text` / `SelectableText` directly with `context.bodyMedium` styles.

## Using Style Extensions

Extension methods make it easy to access typography styles directly from a BuildContext:

```dart
// In a widget build method
Text(
  'Styled text',
  style: context.headlineLarge,
)

// With modifications
Text(
  'Emphasized title',
  style: context.titleMedium.emphasized,
)

// Chaining modifiers
Text(
  'Custom styled text',
  style: context.bodyMedium.bolder.wide,
)
```

Available text style modifiers:
- `.bolder` - Increases font weight
- `.lighter` - Decreases font weight
- `.emphasized` - Adds italics
- `.tight` - Tightens letter spacing
- `.wide` - Widens letter spacing
- `.compact` - Reduces line height
- `.relaxed` - Increases line height
- `.larger` - Increases font size
- `.smaller` - Decreases font size

## Responsive Behavior

The typography system is designed to adapt to different screen sizes:

- Font sizes adjust slightly at different breakpoints
- Line heights and spacing maintain proper proportions
- Components like `Paragraph` automatically manage ideal line lengths

## Accessibility Support

The typography system respects user accessibility preferences:

- Text scales appropriately based on system text size settings
- By default, text scale is respected in the range 1.0x–2.5x to balance readability and layout stability
- Headings use proper semantic markup for screen readers
- Contrast can be automatically enhanced for better readability

## Advanced Usage

### Using the Typography System Directly

For advanced customization, you can access the typography system directly:

```dart
// Get appropriate line height for a font size
double lineHeight = TypographySystem.lineHeight(16.0, category: 'body');

// Calculate ideal width for text container
double width = TypographySystem.idealWidth(fontSize);
```

### Creating Custom Text Components

You can create custom text components that leverage the typography system:

```dart
class CustomLabel extends StatelessWidget {
  final String text;
  final Color? color;
  
  const CustomLabel(this.text, {this.color});
  
  @override
  Widget build(BuildContext context) {
    return AppText.labelMedium(
      text.toUpperCase(),
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
```

## Typography Metrics

The typography system uses carefully defined metrics:

- **Line heights**: Display (1.2), Headline (1.3), Title (1.4), Body (1.5), Label (1.4)
- **Letter spacing**: Varies by text category for optimal readability
- **Paragraph width**: Limited to 40-75 characters for comfortable reading

## Best Practices

1. **Use semantic components** - Use `Heading` for section titles, `Paragraph` for long text, etc.

2. **Maintain hierarchy** - Follow proper heading levels (h1 → h2 → h3) for information hierarchy

3. **Respect accessibility** - Allow text to scale with user preferences

4. **Avoid fixed pixel sizes** - Use the typography system instead of hardcoding font sizes

5. **Use extensions** - Leverage the extension methods for concise code

6. **Be consistent** - Stick to the defined type scale rather than using arbitrary font sizes

## Troubleshooting

- If text appears too large or small, ensure you're using the correct type scale component
- If text doesn't adapt to screen size, check that you're using the responsive components
- If paragraph width seems wrong, verify that `constrainWidth` is set appropriately

## Implementation Details

The typography system is built around the Material Design type scale but with custom metrics for optimal readability and responsiveness. It includes:

- 15 text styles (displayLarge to labelSmall)
- 3 component types (Heading, Text, Paragraph)
- Responsive adjustments for 3 breakpoints (mobile, tablet, desktop)
- Accessibility adjustments that respect user preferences

This approach aligns with design practices used by Google (Material Design), Apple (Human Interface Guidelines), and other industry leaders in digital typography.
