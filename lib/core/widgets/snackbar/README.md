# AppSnackBar

Branded snackbar helpers for consistent transient messaging across the app.

## Why this exists

Flutter’s `SnackBar` is flexible, but if teams build snackbars ad-hoc, styling and behavior drift
quickly. `AppSnackBar` keeps the UI and rules consistent (spacing, colors, safe-area handling, and
optional top placement) while keeping usage simple.

## Usage

Import the barrel:

```dart
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
```

Show a snackbar:

```dart
AppSnackBar.showSuccess(context, message: 'Saved');
AppSnackBar.showError(context, message: 'Something went wrong');
AppSnackBar.showInfo(context, message: 'Copied to clipboard');
AppSnackBar.showWarning(context, message: 'You are offline');
```

### Top vs bottom

Bottom is the default (`SnackBar` via `ScaffoldMessenger`). Top uses an overlay card for a more
banner-like feel:

```dart
AppSnackBar.showError(
  context,
  message: 'Session expired, please sign in again.',
  position: AppSnackBarPosition.top,
);
```

## Rules (template)

- Feature code should call `AppSnackBar.show*` (not raw `SnackBar(...)`).
- A new snackbar hides the current one before showing.
- Top overlay auto-dismiss is cancellable (safe for tests and rapid navigation).

