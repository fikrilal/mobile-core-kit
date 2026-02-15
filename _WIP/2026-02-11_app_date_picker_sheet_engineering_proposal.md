# Engineering Proposal: `AppDatePickerSheet` (Single + Range)

## Goal
Add a reusable design-system date picker presented as an adaptive bottom sheet that supports both:

1. Single-date selection
2. Date-range selection

This becomes the standard date input primitive for future features (filters, reports, scheduling, booking windows, DOB, etc.).

## Why This Is High ROI
1. Date picking recurs across domains; without DS standardization, each feature re-implements logic.
2. Range and single modes share most behavior (calendar navigation, constraints, disabled dates, date-only normalization).
3. Centralizing this prevents UX drift and inconsistent validation logic.

## Scope (PR-sized, v1)
### Add
- `lib/core/design_system/widgets/date_picker/app_date_picker_sheet.dart`
- `lib/core/design_system/widgets/date_picker/date_picker.dart`
- `test/core/design_system/widgets/date_picker/app_date_picker_sheet_test.dart`

### Optional (same PR if small)
- Add one dev-tools showcase entry for date picker.

### Out of Scope (v1)
- Date-time selection
- Multi-range / multi-select
- Alternative calendar systems

## Proposed API (v1)
```dart
enum AppDateSelectionMode { single, range }

typedef AppSelectableDayPredicate = bool Function(DateTime day);

class AppDatePickerSheet extends StatefulWidget {
  const AppDatePickerSheet.single({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    this.resetLabel,
  });

  const AppDatePickerSheet.range({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
    this.maxRangeDays,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    this.resetLabel,
    this.constraintMessage,
  });
}

Future<DateTime?> showAppSingleDatePickerSheet(...);
Future<DateTimeRange?> showAppDateRangePickerSheet(...);
```

## Behavioral Contract
1. Normalize all dates to date-only local midnight before comparisons.
2. Month navigation is constrained by `firstDate..lastDate`.
3. Disabled days:
   - outside bounds
   - rejected by `selectableDayPredicate`
   - in range mode when selecting end date and `maxRangeDays` would be exceeded
4. Single mode:
   - tap date selects one day
   - confirm returns selected date
5. Range mode:
   - first tap = start
   - second tap = end
   - if second tap is before start, range is reordered
   - third tap restarts range from new start
6. Actions:
   - `Reset` clears current selection (when provided)
   - `Confirm` enabled only when selection is valid
   - `Cancel` closes with `null`

## Accessibility + i18n
1. Use localized month/day labels via Flutter localizations.
2. Add semantics for selected/disabled/range states.
3. Keep touch targets at least 40x40.
4. Avoid hardcoded user-facing strings; defaults from l10n where available.

## Testing Plan
`test/core/design_system/widgets/date_picker/app_date_picker_sheet_test.dart`

Minimum coverage:
1. Single mode date selection enables confirm and emits selected date.
2. Range mode selects start/end and emits `DateTimeRange`.
3. Range mode reorders when user selects earlier end date.
4. `maxRangeDays` blocks invalid end date selection.
5. Reset clears selection.
6. Month navigation respects bounds.
7. `selectableDayPredicate` disables blocked dates.

## Risks and Mitigations
1. Calendar logic complexity:
   - keep logic in small pure helper methods and test heavily.
2. Date/timezone bugs:
   - strict date-only normalization utilities.
3. Over-scoping:
   - v1 ships single+range only, no time-of-day.

## Success Criteria
1. One DS API supports single and range selection.
2. Lint/test clean and reusable in feature pages.
3. Constraint behaviors are deterministic and documented.
