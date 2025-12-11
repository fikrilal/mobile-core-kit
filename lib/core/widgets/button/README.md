# AppButton Component

## Overview

The `AppButton` component is an enterprise-grade button widget that provides comprehensive customization options, accessibility features, and advanced styling capabilities. It's designed to meet the highest standards for production applications.

## Features

### ✅ Core Functionality

- Multiple button variants (Primary, Secondary, Outline, Danger)
- Three size options (Small, Medium, Large)
- Loading states with customizable indicators
- Disabled state support
- Named constructors for convenience

### ✅ Accessibility

- **Semantic Labels**: Custom labels for screen readers
- **Tooltips**: Helpful hover information
- **Exclude from Semantics**: Option to exclude from accessibility tree
- **WCAG Compliance**: Meets accessibility guidelines

### ✅ Focus & Interaction

- **Autofocus**: Automatic focus on widget creation
- **Custom Focus Node**: Advanced focus management
- **Focus Change Callbacks**: React to focus state changes
- **Hover Detection**: Mouse hover event handling
- **Long Press Support**: Extended press interactions
- **Haptic Feedback**: Customizable tactile feedback
- **Feedback Control**: Enable/disable interaction feedback

### ✅ Icons & Content

- **Prefix Icons**: Leading icons with custom sizing
- **Suffix Icons**: Trailing icons with custom sizing
- **Icon Spacing**: Customizable spacing between icon and text
- **Icon Size Override**: Custom icon dimensions
- **Flexible Layout**: Responsive content arrangement

### ✅ Visual Customization

- **Custom Colors**: Background, text, and border colors
- **Dimensions**: Optional custom width
- **Padding & Margin**: Flexible spacing control

### ✅ Loading Customization

- **Custom Loading Indicator**: Replace default spinner
- **Loading Text**: Custom text during loading state
- **Loading Indicator Size**: Custom spinner dimensions
- **Loading State Management**: Automatic state handling

### ✅ Advanced Styling

- **Animation Duration**: Custom transition timing
- **Animation Curves**: Easing function control
- **Content Alignment**: Flexible content positioning
- **Layout Control**: MainAxis and CrossAxis alignment
- **Responsive Design**: Adaptive sizing and spacing

## Usage Examples

### Basic Usage

```dart
AppButton(
  text: 'Click Me',
  onPressed: () => print('Button pressed'),
)
```

### Named Constructors

```dart
// Primary button
AppButton.primary(
  text: 'Primary Action',
  onPressed: () => handlePrimaryAction(),
)

// Secondary button
AppButton.secondary(
  text: 'Secondary Action',
  onPressed: () => handleSecondaryAction(),
)

// Outline button
AppButton.outline(
  text: 'Outline Action',
  onPressed: () => handleOutlineAction(),
)

// Danger button
AppButton.danger(
  text: 'Delete',
  onPressed: () => handleDelete(),
)
```

### With Icons

```dart
AppButton(
  text: 'Save',
  icon: Icon(Icons.save),
  iconSize: 20,
  iconSpacing: 8,
  onPressed: () => save(),
)

AppButton(
  text: 'Next',
  suffixIcon: Icon(Icons.arrow_forward),
  onPressed: () => goNext(),
)
```

### Loading States

```dart
AppButton(
  text: 'Submit',
  isLoading: isSubmitting,
  loadingText: 'Submitting...',
  loadingIndicator: CustomSpinner(),
  onPressed: () => submitForm(),
)
```

### Accessibility Features

```dart
AppButton(
  text: 'Save Document',
  semanticLabel: 'Save the current document to your account',
  tooltip: 'Click to save your work',
  hapticFeedback: AppHapticFeedback.mediumImpact,
  onPressed: () => saveDocument(),
)
```

### Focus Management

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FocusNode _buttonFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Focused Button',
      focusNode: _buttonFocus,
      autofocus: true,
      onFocusChange: (focused) => print('Focus changed: $focused'),
      onHover: (isHovered) => print('Button hovered: $isHovered'),
      onLongPress: () => print('Long press detected'),
      onPressed: () => print('Button pressed'),
    );
  }

  @override
  void dispose() {
    _buttonFocus.dispose();
    super.dispose();
  }
}
```

### Custom Dimensions and Layout

```dart
AppButton(
  text: 'Custom Button',
  width: 200,
  height: 60,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  margin: EdgeInsets.all(16),
  alignment: Alignment.centerLeft,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  onPressed: () => handleAction(),
)
```

## Parameters Reference

### Core Functionality

| Parameter    | Type            | Default   | Description          |
| ------------ | --------------- | --------- | -------------------- |
| `text`       | `String`        | required  | Button text content  |
| `onPressed`  | `VoidCallback?` | null      | Tap callback         |
| `variant`    | `ButtonVariant` | `primary` | Button style variant |
| `size`       | `ButtonSize`    | `medium`  | Button size          |
| `isLoading`  | `bool`          | `false`   | Loading state        |
| `isDisabled` | `bool`          | `false`   | Disabled state       |

### Icons & Content

| Parameter     | Type      | Default | Description                 |
| ------------- | --------- | ------- | --------------------------- |
| `icon`        | `Widget?` | null    | Leading icon                |
| `suffixIcon`  | `Widget?` | null    | Trailing icon               |
| `iconSize`    | `double?` | auto    | Custom icon size            |
| `iconSpacing` | `double?` | 8.0     | Space between icon and text |

### Visual Customization

| Parameter         | Type            | Default | Description             |
| ----------------- | --------------- | ------- | ----------------------- |
| `backgroundColor` | `Color?`        | theme   | Custom background color |
| `textColor`       | `Color?`        | theme   | Custom text color       |
| `borderColor`     | `Color?`        | theme   | Custom border color     |
| `width`           | `double?`       | auto    | Custom width            |
| `padding`         | `EdgeInsets?`   | theme   | Custom padding          |
| `margin`          | `EdgeInsets?`   | null    | Custom margin           |
| `borderRadius`    | `BorderRadius?` | theme   | Custom border radius    |

### Accessibility

| Parameter              | Type      | Default | Description                |
| ---------------------- | --------- | ------- | -------------------------- |
| `semanticLabel`        | `String?` | null    | Screen reader label        |
| `tooltip`              | `String?` | null    | Hover tooltip              |
| `excludeFromSemantics` | `bool`    | `false` | Exclude from accessibility |

### Focus & Interaction

| Parameter        | Type                      | Default | Description                 |
| ---------------- | ------------------------- | ------- | --------------------------- |
| `autofocus`      | `bool`                    | `false` | Auto focus on creation      |
| `focusNode`      | `FocusNode?`              | null    | Custom focus node           |
| `onFocusChange`  | `ValueChanged<bool>?`     | null    | Focus change callback       |
| `onHover`        | `ValueChanged<bool>?`     | null    | Hover callback              |
| `onLongPress`    | `VoidCallback?`           | null    | Long press callback         |
| `enableFeedback` | `bool`                    | `true`  | Enable interaction feedback |
| `hapticFeedback` | `AppHapticFeedback?`      | null    | Haptic feedback type        |

### Loading Customization

| Parameter              | Type      | Default | Description            |
| ---------------------- | --------- | ------- | ---------------------- |
| `loadingIndicator`     | `Widget?` | null    | Custom loading spinner |
| `loadingText`          | `String?` | null    | Custom loading text    |
| `loadingIndicatorSize` | `double?` | auto    | Loading spinner size   |

## Haptic Feedback Types

```dart
enum AppHapticFeedback {
  lightImpact,    // Light tactile feedback
  mediumImpact,   // Medium tactile feedback
  heavyImpact,    // Heavy tactile feedback
  selectionClick, // Selection feedback
  vibrate,        // Standard vibration
}
```

## Best Practices

### 1. Accessibility

- Always provide semantic labels for complex buttons
- Use tooltips for buttons with icons only
- Ensure sufficient color contrast
- Test with screen readers

### 2. Performance

- Use named constructors for common variants
- Avoid excessive customization when theme defaults suffice
- Dispose of custom focus nodes properly

### 3. UX Guidelines

- Use appropriate haptic feedback for different actions
- Provide loading states for async operations
- Use consistent sizing throughout your app
- Follow platform conventions for button placement

### 4. Theming

- Leverage theme colors when possible
- Create custom variants for brand-specific styling
- Use consistent spacing and sizing patterns

## Testing

Recommended tests for this component cover:

- Variants and sizes
- Accessibility features
- Focus and hover behavior
- Loading states
- Interaction callbacks

## Migration Guide

If upgrading from a previous version:

1. **Haptic Feedback**: The `hapticFeedback` parameter now uses `AppHapticFeedback` enum
2. **Focus Management**: New focus-related parameters available
3. **Loading**: Enhanced loading customization options
4. **Accessibility**: New semantic and tooltip parameters

## Contributing

When contributing to this component:

1. Maintain backward compatibility
2. Add comprehensive tests for new features
3. Update documentation
4. Follow the established code style
5. Consider accessibility implications

## License

This component is part of the `mobile-core-kit` UI library template.
