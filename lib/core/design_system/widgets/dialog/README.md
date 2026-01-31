# AppConfirmationDialog

Reusable, adaptive confirmation modal with consistent layout, spacing, and button styles.

## Usage

Prefer the helper so dismissal rules stay consistent:

```dart
final confirmed = await showAppConfirmationDialog(
  context: context,
  title: 'Delete item?',
  message: 'This action cannot be undone.',
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  variant: AppConfirmationDialogVariant.featured,
  icon: const Icon(Icons.delete_outline),
);

if (confirmed == true) {
  // proceed
}
```

## Dismiss behavior (template defaults)

- Presentation:
  - Compact width → modal bottom sheet
  - Medium+ width → dialog
- `barrierDismissible` defaults to `isCancelEnabled && !isLoading`.
- Back navigation is disabled when `barrierDismissible` is false.
- If dismissed via barrier/back/drag (when allowed), the helper resolves to `false` and calls `onCancel` (if provided).
