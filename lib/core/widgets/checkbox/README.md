# AppCheckbox

Branded checkbox with a small API surface that stays aligned with the app theme.

## Usage

```dart
import 'package:mobile_core_kit/core/widgets/checkbox/checkbox.dart';

AppCheckbox(
  value: accepted,
  onChanged: (v) => setState(() => accepted = v ?? false),
  semanticLabel: 'Accept terms and conditions',
);
```

### Checkbox tile

Use `AppCheckboxTile` when you want the whole row to be tappable (recommended for forms/settings).

```dart
AppCheckboxTile(
  value: accepted,
  label: 'Accept terms and conditions',
  helperText: 'You must accept before continuing.',
  onChanged: (v) => setState(() => accepted = v ?? false),
);
```

### Tristate

```dart
AppCheckbox(
  value: value, // true / false / null
  tristate: true,
  onChanged: (v) => setState(() => value = v),
);
```

## Notes

- This widget wraps Flutter’s `Checkbox` so it keeps platform-correct semantics and keyboard behavior.
- Haptics are opt-in: set `enableFeedback: true` and `hapticFeedback: ...` if you want it.
