# Modal Governance (Adaptive Entrypoints)

This template treats “how we present a modal” as a **core concern**, not a feature decision.
Features ask for a modal (confirm, select, edit, info), and the core layer decides **dialog vs bottom sheet vs side sheet** based on the current adaptive spec.

The goal is to keep UX consistent across phone + tablet, avoid duplicated heuristics, and make future re-architecture (or new form factors) a core-only change.

## Rules (MUST / SHOULD)

### MUST

- Feature code MUST NOT call platform modal APIs directly:
  - `showDialog`
  - `showGeneralDialog`
  - `showModalBottomSheet`
  - `showCupertinoModalPopup`
  - `showCupertinoDialog`
- Feature code MUST use one of:
  - `showAdaptiveModal` (`lib/core/design_system/adaptive/widgets/adaptive_modal.dart`)
  - `showAdaptiveSideSheet` (`lib/core/design_system/adaptive/widgets/adaptive_side_sheet.dart`)
  - A core wrapper (example: `showAppConfirmationDialog`)
- New modal entrypoints SHOULD be added as **core wrappers** (not copied per feature).

### SHOULD

- A wrapper SHOULD have stable semantics:
  - consistent return type (`Future<T?>`)
  - clear dismissal behavior (what happens on barrier/back/drag)
  - predictable sizing across width classes
- A wrapper SHOULD ship with widget tests that prove:
  - compact → bottom sheet
  - medium+ → dialog (or side sheet, if appropriate)
  - non-dismissible behavior (if supported)

## Where the rule is enforced

The repo includes a guardrail script:

```bash
dart run tool/verify_modal_entrypoints.dart
```

It fails the build if disallowed modal APIs are used outside the allowlist (currently only `lib/core/design_system/adaptive/widgets/`).

`dart run tool/verify.dart` runs this check automatically.

## When to use which entrypoint

### `showAdaptiveModal`

Use for most modals:
- confirmation
- short forms
- selections (radio/list)
- info/error/success states

Behavior:
- compact → bottom sheet
- medium+ → dialog

### `showAdaptiveSideSheet`

Use when the modal content is “page-like” on tablets:
- multi-step edit flows
- dense settings panels
- deep filters/search refinement

Behavior:
- compact → falls back to `showAdaptiveModal`
- medium+ → side sheet

## Pattern: create a core wrapper

Example (confirmation):

```dart
final confirmed = await showAppConfirmationDialog(
  context: context,
  title: 'Log out?',
  message: 'You will need to sign in again to continue.',
);

if (confirmed == true) {
  // proceed
}
```

If you need a new modal type, create a wrapper under `lib/core/design_system/widgets/…` (or `lib/core/design_system/adaptive/widgets/…` if it’s purely adaptive) that delegates to `showAdaptiveModal` / `showAdaptiveSideSheet`.

## Anti-patterns

- Calling `showDialog`/`showModalBottomSheet` directly in `lib/features/**`.
- Embedding a `Dialog` widget inside a bottom sheet (leads to double surfaces/padding and weird semantics).
- Divergent “dismiss means cancel” vs “dismiss means null” semantics across features.

