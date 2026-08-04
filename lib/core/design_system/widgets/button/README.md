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
  onPressed: () => saveDocument(),
)
```

### Interaction

```dart
AppButton(
  text: 'Interactive Button',
  onHover: (isHovered) => print('Button hovered: $isHovered'),
  onLongPress: () => print('Long press detected'),
  onPressed: () => print('Button pressed'),
)
```

### Custom Dimensions and Layout

```dart
AppButton(
  text: 'Custom Button',
  width: 200,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  margin: EdgeInsets.all(16),
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

### Accessibility

| Parameter       | Type      | Default | Description         |
| --------------- | --------- | ------- | ------------------- |
| `semanticLabel` | `String?` | null    | Screen reader label |

### Interaction

| Parameter     | Type                  | Default | Description          |
| ------------- | --------------------- | ------- | -------------------- |
| `onHover`     | `ValueChanged<bool>?` | null    | Hover callback       |
| `onLongPress` | `VoidCallback?`       | null    | Long press callback  |

### Loading Customization

| Parameter              | Type      | Default | Description            |
| ---------------------- | --------- | ------- | ---------------------- |
| `loadingIndicator`     | `Widget?` | null    | Custom loading spinner |
| `loadingText`          | `String?` | null    | Custom loading text    |
| `loadingIndicatorSize` | `double?` | auto    | Loading spinner size   |

## Best Practices

### 1. Accessibility

- Always provide semantic labels for complex buttons
- Ensure sufficient color contrast
- Test with screen readers

### 2. Performance

- Use named constructors for common variants
- Avoid excessive customization when theme defaults suffice

### 3. UX Guidelines

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
- Loading states
- Interaction callbacks

## Migration Guide

If upgrading from a previous version:

1. **Removed parameters**: `tooltip`, `excludeFromSemantics`, `autofocus`, `focusNode`, `onFocusChange`, `enableFeedback`, and `hapticFeedback` were removed. Haptic feedback and focus management are no longer supported on `AppButton`; use `semanticLabel` for accessibility.
2. **Loading**: Enhanced loading customization options
3. **Accessibility**: New semantic parameters

## Contributing

When contributing to this component:

1. Maintain backward compatibility
2. Add comprehensive tests for new features
3. Update documentation
4. Follow the established code style
5. Consider accessibility implications

## License

This component is part of the `mobile-core-kit` UI library template.
