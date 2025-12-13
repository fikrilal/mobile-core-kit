# Feedback System (Snackbars)

This template standardizes transient user messages (success/error/info/warning) behind a single
branded component so feature code doesn’t hand-craft `SnackBar(...)` styles across the codebase.

## The rule

Feature code should show snackbars via **`AppSnackBar.show*`** and should not call:
- `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` directly
- `NavigationService.showSnackBar(...)` (deprecated)

## Usage

```dart
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';

AppSnackBar.showSuccess(context, message: 'Saved');
AppSnackBar.showError(context, message: 'Something went wrong');
AppSnackBar.showInfo(context, message: 'Copied to clipboard');
AppSnackBar.showWarning(context, message: 'You are offline');
```

### Top vs bottom

```dart
AppSnackBar.showError(
  context,
  message: 'Session expired, please sign in again.',
  position: AppSnackBarPosition.top,
);
```

## Behavior (template defaults)

- Calling `AppSnackBar.show*` hides the current snackbar before showing a new one.
- The `top` position uses an overlay card with enter/exit animation and safe-area handling.
- Tone styles come from theme tokens (`SemanticColors` + `ColorScheme`).
