# AppTextField Component

`AppTextField` is the design‑system text field for `mobile-core-kit`. It provides a small,
consistent API over `TextFormField`, aligned with the theme tokens and validation patterns in this
template.

## Features

- **Variants**: `outline` (default), `filled`, `primary`, `secondary`.
- **Label positioning**:
  - `LabelPosition.above` (default) – modern, form‑friendly labels.
  - `LabelPosition.floating` – traditional Material floating labels.
- **Sizes**: `small`, `medium` (default), `large`.
- **Field types**: `text`, `email`, `password`, `number`, `phone`, `url`, `multiline`, `search`.
- **Password toggle**: built‑in show/hide for `FieldType.password`.
- **State styling**: supports `FieldState.error` automatically and allows success/warning via
  `visualState`.
- **Prefix / suffix**: icons, text, or custom widgets.
- **Accessibility**: semantics label, tooltip, and explicit opt‑out from the semantics tree.

## Quick Start

```dart
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';

AppTextField(
  labelText: 'Email',
  hintText: 'user@example.com',
  onChanged: (value) => print(value),
);
```

## Named Constructors

Convenience constructors exist for the most common cases:

```dart
AppTextField.email(labelText: 'Email');
AppTextField.password(labelText: 'Password');
AppTextField.multiline(labelText: 'Notes', maxLines: 4);
AppTextField.search(hintText: 'Search…');
```

For other types, pass `fieldType:` directly:

```dart
AppTextField(
  fieldType: FieldType.phone,
  labelText: 'Phone number',
);
```

## Examples

### Floating label

```dart
AppTextField.email(
  labelText: 'Email',
  labelPosition: LabelPosition.floating,
);
```

### Password with toggle

```dart
AppTextField.password(
  labelText: 'Password',
  onSubmitted: (_) => submit(),
);
```

### Success / warning state

```dart
AppTextField(
  labelText: 'Referral code',
  visualState: FieldState.success,
  helperText: 'Looks good!',
);
```

### Prefix / suffix

```dart
AppTextField(
  labelText: 'Price',
  fieldType: FieldType.number,
  prefixText: '\$',
  suffixText: 'USD',
);
```

### Validation in a form

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      AppTextField.email(
        labelText: 'Email',
        validator: (value) {
          if (value == null || value.isEmpty) return 'Email is required';
          if (!value.contains('@')) return 'Invalid email';
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      const SizedBox(height: 16),
      AppTextField.password(
        labelText: 'Password',
        validator: (value) {
          if (value == null || value.length < 8) return 'Min 8 characters';
          return null;
        },
        onSubmitted: (_) {
          if (_formKey.currentState!.validate()) submit();
        },
      ),
    ],
  ),
);
```

## Haptics & Feedback

`AppTextField` supports optional haptic feedback for **taps** and the password toggle.

- No haptics are emitted by default.
- To enable:

```dart
AppTextField(
  labelText: 'Search',
  hapticFeedback: AppHapticFeedback.selectionClick,
);
```

Avoid enabling haptics for every keystroke (this template intentionally does not do that).

## Styling Notes

- Defaults come from `FieldStyles` and the global `ThemeData`/`ColorScheme`.
- Use `fillColor`, `borderColor`, and `textColor` only when a screen truly needs a special case.
- Prefer variants (`primary`, `secondary`, `outline`, `filled`) over raw color overrides.

## Testing

Recommended tests for this component:

- Variant + size styling is applied correctly.
- Password toggle visibility behavior.
- Label positioning (`above` vs `floating`).
- Type‑specific formatters (`number`, `phone`) and semantics labels.

