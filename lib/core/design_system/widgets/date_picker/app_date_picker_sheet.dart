import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_policies.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/modal_policy.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/state_opacities.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

enum AppDateSelectionMode { single, range }

typedef AppSelectableDayPredicate = bool Function(DateTime day);

const appDatePickerPrevMonthKey = Key('app_date_picker_prev_month');
const appDatePickerNextMonthKey = Key('app_date_picker_next_month');
const appDatePickerCloseKey = Key('app_date_picker_close');
const appDatePickerCancelKey = Key('app_date_picker_cancel');
const appDatePickerResetKey = Key('app_date_picker_reset');
const appDatePickerConfirmKey = Key('app_date_picker_confirm');

Future<DateTime?> showAppSingleDatePickerSheet({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
  AppSelectableDayPredicate? selectableDayPredicate,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  String? resetLabel,
  bool? showCloseButton,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final effectiveShowCloseButton = _resolveDefaultShowCloseButton(
    context: context,
    showCloseButton: showCloseButton,
  );

  return showAdaptiveModal<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (_) => AppDatePickerSheet.single(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      resetLabel: resetLabel,
      showCloseButton: effectiveShowCloseButton,
    ),
  );
}

Future<DateTimeRange?> showAppDateRangePickerSheet({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialRange,
  int? minRangeDays,
  int? maxRangeDays,
  AppSelectableDayPredicate? selectableDayPredicate,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  String? resetLabel,
  String? constraintMessage,
  bool? showCloseButton,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final effectiveShowCloseButton = _resolveDefaultShowCloseButton(
    context: context,
    showCloseButton: showCloseButton,
  );

  return showAdaptiveModal<DateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (_) => AppDatePickerSheet.range(
      firstDate: firstDate,
      lastDate: lastDate,
      initialRange: initialRange,
      minRangeDays: minRangeDays,
      maxRangeDays: maxRangeDays,
      selectableDayPredicate: selectableDayPredicate,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      resetLabel: resetLabel,
      constraintMessage: constraintMessage,
      showCloseButton: effectiveShowCloseButton,
    ),
  );
}

bool _resolveDefaultShowCloseButton({
  required BuildContext context,
  required bool? showCloseButton,
}) {
  if (showCloseButton != null) {
    return showCloseButton;
  }

  final layout = context.adaptiveLayout;
  final modalPolicy = AdaptivePolicies.of(context).modalPolicy;
  final presentation = modalPolicy.modalPresentation(layout: layout);
  return presentation == AdaptiveModalPresentation.dialog;
}

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
    this.showCloseButton,
  }) : mode = AppDateSelectionMode.single,
       initialRange = null,
       minRangeDays = null,
       maxRangeDays = null,
       constraintMessage = null;

  const AppDatePickerSheet.range({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
    this.minRangeDays,
    this.maxRangeDays,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    this.resetLabel,
    this.constraintMessage,
    this.showCloseButton,
  }) : mode = AppDateSelectionMode.range,
       initialDate = null;

  final AppDateSelectionMode mode;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final DateTimeRange? initialRange;
  final int? minRangeDays;
  final int? maxRangeDays;
  final AppSelectableDayPredicate? selectableDayPredicate;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;
  final String? resetLabel;
  final String? constraintMessage;
  final bool? showCloseButton;

  @override
  State<AppDatePickerSheet> createState() => _AppDatePickerSheetState();
}

class _AppDatePickerSheetState extends State<AppDatePickerSheet> {
  late final DateTime _firstDate;
  late final DateTime _lastDate;

  late DateTime _visibleMonth;

  DateTime? _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _firstDate = _dateOnly(widget.firstDate);
    _lastDate = _dateOnly(widget.lastDate);

    assert(
      !_firstDate.isAfter(_lastDate),
      'firstDate must be before or equal to lastDate',
    );
    assert(
      widget.minRangeDays == null || widget.minRangeDays! > 0,
      'minRangeDays must be greater than zero',
    );
    assert(
      widget.maxRangeDays == null || widget.maxRangeDays! > 0,
      'maxRangeDays must be greater than zero',
    );
    assert(
      widget.minRangeDays == null ||
          widget.maxRangeDays == null ||
          widget.minRangeDays! <= widget.maxRangeDays!,
      'minRangeDays must be less than or equal to maxRangeDays',
    );

    _seedInitialSelection();
    _visibleMonth = _initialVisibleMonth();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = MaterialLocalizations.of(context);

    final cancelLabel = widget.cancelLabel ?? context.l10n.commonCancel;
    final confirmLabel = widget.confirmLabel ?? context.l10n.commonContinue;
    final resetLabel = widget.resetLabel;
    final titleText = widget.title ?? locale.formatMonthYear(_visibleMonth);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space8,
          AppSpacing.space16,
          AppSpacing.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: titleText,
              showCloseButton: widget.showCloseButton ?? true,
              canGoPreviousMonth: _canGoPreviousMonth,
              canGoNextMonth: _canGoNextMonth,
              onClose: () => Navigator.of(context).pop(),
              onPreviousMonth: _goToPreviousMonth,
              onNextMonth: _goToNextMonth,
            ),
            const SizedBox(height: AppSpacing.space8),
            _SelectionSummary(
              mode: widget.mode,
              selectedDate: _selectedDate,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
            ),
            if (widget.constraintMessage != null &&
                widget.constraintMessage!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.radius8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space8),
                  child: AppText.bodySmall(
                    widget.constraintMessage!,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space12),
            _WeekdayHeader(),
            const SizedBox(height: AppSpacing.space8),
            _CalendarGrid(
              visibleMonth: _visibleMonth,
              firstDate: _firstDate,
              lastDate: _lastDate,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
              selectedDate: _selectedDate,
              isDateSelectable: _isDateSelectable,
              onDayPressed: _selectDay,
            ),
            const SizedBox(height: AppSpacing.space16),
            Row(
              children: [
                if (resetLabel != null && resetLabel.trim().isNotEmpty)
                  TextButton(
                    key: appDatePickerResetKey,
                    onPressed: _hasSelection ? _resetSelection : null,
                    child: AppText.bodyMedium(resetLabel.trim()),
                  ),
                const Spacer(),
                AppButton.outline(
                  key: appDatePickerCancelKey,
                  text: cancelLabel,
                  semanticLabel: cancelLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.space12),
                AppButton.primary(
                  key: appDatePickerConfirmKey,
                  text: confirmLabel,
                  semanticLabel: confirmLabel,
                  isDisabled: !_hasValidSelection,
                  onPressed: _confirmSelection,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _seedInitialSelection() {
    switch (widget.mode) {
      case AppDateSelectionMode.single:
        final initial = widget.initialDate == null
            ? null
            : _dateOnly(widget.initialDate!);
        if (initial != null && _isDateSelectable(initial)) {
          _selectedDate = initial;
        }
      case AppDateSelectionMode.range:
        final initialRange = widget.initialRange;
        if (initialRange == null) return;

        var start = _dateOnly(initialRange.start);
        var end = _dateOnly(initialRange.end);
        if (end.isBefore(start)) {
          final tmp = start;
          start = end;
          end = tmp;
        }

        if (!_isDateSelectable(start) || !_isDateSelectable(end)) {
          return;
        }
        if (_isInvalidRangeSize(start, end)) {
          return;
        }

        _rangeStart = start;
        _rangeEnd = end;
    }
  }

  DateTime _initialVisibleMonth() {
    final seed = switch (widget.mode) {
      AppDateSelectionMode.single => _selectedDate ?? DateTime.now(),
      AppDateSelectionMode.range => _rangeStart ?? DateTime.now(),
    };

    final month = _monthStart(_dateOnly(seed));
    final firstMonth = _monthStart(_firstDate);
    final lastMonth = _monthStart(_lastDate);

    if (month.isBefore(firstMonth)) return firstMonth;
    if (month.isAfter(lastMonth)) return lastMonth;
    return month;
  }

  bool get _canGoPreviousMonth {
    return _visibleMonth.isAfter(_monthStart(_firstDate));
  }

  bool get _canGoNextMonth {
    return _visibleMonth.isBefore(_monthStart(_lastDate));
  }

  void _goToPreviousMonth() {
    if (!_canGoPreviousMonth) return;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    if (!_canGoNextMonth) return;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  void _selectDay(DateTime date) {
    final day = _dateOnly(date);
    if (!_isDateSelectable(day)) return;

    setState(() {
      switch (widget.mode) {
        case AppDateSelectionMode.single:
          _selectedDate = day;
        case AppDateSelectionMode.range:
          if (_rangeStart == null || _rangeEnd != null) {
            _rangeStart = day;
            _rangeEnd = null;
            break;
          }

          final start = _rangeStart!;
          final nextStart = day.isBefore(start) ? day : start;
          final nextEnd = day.isBefore(start) ? start : day;
          if (_isInvalidRangeSize(nextStart, nextEnd)) {
            return;
          }

          _rangeStart = nextStart;
          _rangeEnd = nextEnd;
      }
    });
  }

  bool _isDateSelectable(DateTime day) {
    if (day.isBefore(_firstDate) || day.isAfter(_lastDate)) {
      return false;
    }

    final predicate = widget.selectableDayPredicate;
    if (predicate != null && !predicate(day)) {
      return false;
    }

    final maxRangeDays = widget.maxRangeDays;
    final minRangeDays = widget.minRangeDays;
    if (widget.mode == AppDateSelectionMode.range &&
        _rangeStart != null &&
        _rangeEnd == null) {
      final span = _inclusiveDaySpan(_rangeStart!, day);
      if (maxRangeDays != null && span > maxRangeDays) {
        return false;
      }
      if (minRangeDays != null && span < minRangeDays) {
        return false;
      }
    }

    return true;
  }

  bool _isInvalidRangeSize(DateTime start, DateTime end) {
    final minRangeDays = widget.minRangeDays;
    final maxRangeDays = widget.maxRangeDays;
    final span = _inclusiveDaySpan(start, end);

    if (minRangeDays != null && span < minRangeDays) {
      return true;
    }
    if (maxRangeDays != null && span > maxRangeDays) {
      return true;
    }
    return false;
  }

  int _inclusiveDaySpan(DateTime a, DateTime b) {
    return a.difference(b).inDays.abs() + 1;
  }

  bool get _hasSelection {
    return switch (widget.mode) {
      AppDateSelectionMode.single => _selectedDate != null,
      AppDateSelectionMode.range => _rangeStart != null || _rangeEnd != null,
    };
  }

  bool get _hasValidSelection {
    return switch (widget.mode) {
      AppDateSelectionMode.single => _selectedDate != null,
      AppDateSelectionMode.range =>
        _rangeStart != null &&
            _rangeEnd != null &&
            !_isInvalidRangeSize(_rangeStart!, _rangeEnd!),
    };
  }

  void _resetSelection() {
    setState(() {
      _selectedDate = null;
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  void _confirmSelection() {
    if (!_hasValidSelection) return;

    switch (widget.mode) {
      case AppDateSelectionMode.single:
        Navigator.of(context).pop(_selectedDate);
      case AppDateSelectionMode.range:
        Navigator.of(
          context,
        ).pop(DateTimeRange(start: _rangeStart!, end: _rangeEnd!));
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _monthStart(DateTime value) => DateTime(value.year, value.month);
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.showCloseButton,
    required this.canGoPreviousMonth,
    required this.canGoNextMonth,
    required this.onClose,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final String title;
  final bool showCloseButton;
  final bool canGoPreviousMonth;
  final bool canGoNextMonth;
  final VoidCallback onClose;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    if (!showCloseButton) {
      return Row(
        children: [
          IconButton(
            key: appDatePickerPrevMonthKey,
            onPressed: canGoPreviousMonth ? onPreviousMonth : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: AppText.titleMedium(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          IconButton(
            key: appDatePickerNextMonthKey,
            onPressed: canGoNextMonth ? onNextMonth : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          key: appDatePickerCloseKey,
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
        Expanded(
          child: AppText.titleMedium(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        IconButton(
          key: appDatePickerPrevMonthKey,
          onPressed: canGoPreviousMonth ? onPreviousMonth : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          key: appDatePickerNextMonthKey,
          onPressed: canGoNextMonth ? onNextMonth : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.mode,
    required this.selectedDate,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final AppDateSelectionMode mode;
  final DateTime? selectedDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    String format(DateTime? date) {
      if (date == null) return '-';
      return localizations.formatMediumDate(date);
    }

    switch (mode) {
      case AppDateSelectionMode.single:
        return AppText.bodyMedium(
          format(selectedDate),
          textAlign: TextAlign.center,
        );
      case AppDateSelectionMode.range:
        return Row(
          children: [
            Expanded(
              child: AppText.bodyMedium(
                format(rangeStart),
                textAlign: TextAlign.center,
              ),
            ),
            const Icon(Icons.arrow_right_alt),
            Expanded(
              child: AppText.bodyMedium(
                format(rangeEnd),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
    }
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayIndex = localizations.firstDayOfWeekIndex;
    final narrowWeekdays = localizations.narrowWeekdays;
    final ordered = List<String>.generate(
      DateTime.daysPerWeek,
      (index) => narrowWeekdays[(firstDayIndex + index) % DateTime.daysPerWeek],
    );

    return Row(
      children: [
        for (final label in ordered)
          Expanded(
            child: AppText.labelSmall(label, textAlign: TextAlign.center),
          ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.firstDate,
    required this.lastDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedDate,
    required this.isDateSelectable,
    required this.onDayPressed,
  });

  final DateTime visibleMonth;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final DateTime? selectedDate;
  final bool Function(DateTime day) isDateSelectable;
  final ValueChanged<DateTime> onDayPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayOfWeekIndex = localizations.firstDayOfWeekIndex;

    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final weekdayFromSunday = firstOfMonth.weekday % DateTime.daysPerWeek;
    final leadingPlaceholders =
        (weekdayFromSunday - firstDayOfWeekIndex + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;

    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );

    final totalCellsBeforeTrailing = leadingPlaceholders + daysInMonth;
    final trailingPlaceholders =
        (DateTime.daysPerWeek -
            (totalCellsBeforeTrailing % DateTime.daysPerWeek)) %
        DateTime.daysPerWeek;

    final cells = <DateTime?>[
      for (var i = 0; i < leadingPlaceholders; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(visibleMonth.year, visibleMonth.month, day),
      for (var i = 0; i < trailingPlaceholders; i++) null,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DateTime.daysPerWeek,
        mainAxisSpacing: AppSpacing.space4,
        crossAxisSpacing: AppSpacing.space4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final date = cells[index];
        if (date == null) return const SizedBox.shrink();

        final day = DateTime(date.year, date.month, date.day);
        final isSelectable = isDateSelectable(day);

        final isSelected = _isSameDay(day, selectedDate);
        final isRangeStart = _isSameDay(day, rangeStart);
        final isRangeEnd = _isSameDay(day, rangeEnd);
        final isInRange = _isInRange(day, rangeStart, rangeEnd);

        return _DayCell(
          date: day,
          isSelectable: isSelectable,
          isSelected: isSelected,
          isRangeStart: isRangeStart,
          isRangeEnd: isRangeEnd,
          isInRange: isInRange,
          isToday: _isSameDay(day, DateTime.now()),
          onPressed: isSelectable ? () => onDayPressed(day) : null,
        );
      },
    );
  }

  bool _isInRange(DateTime day, DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !day.isBefore(start) && !day.isAfter(end);
  }

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelectable,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isInRange,
    required this.isToday,
    required this.onPressed,
  });

  final DateTime date;
  final bool isSelectable;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isInRange;
  final bool isToday;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);

    final isBoundary = isSelected || isRangeStart || isRangeEnd;
    final textColor = !isSelectable
        ? colorScheme.onSurface.withValues(
            alpha: StateOpacities.disabledContent,
          )
        : isBoundary
        ? colorScheme.onPrimary
        : isInRange
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final backgroundColor = isBoundary
        ? colorScheme.primary
        : isInRange
        ? colorScheme.primaryContainer
        : Colors.transparent;

    final borderColor = isToday && !isBoundary
        ? colorScheme.primary
        : Colors.transparent;

    return Semantics(
      selected: isBoundary,
      button: true,
      enabled: isSelectable,
      label: localizations.formatFullDate(date),
      child: TextButton(
        key: ValueKey<String>(_dayKey(date)),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.radius8),
            side: BorderSide(color: borderColor),
          ),
          backgroundColor: backgroundColor,
          minimumSize: const Size(AppSpacing.space40, AppSpacing.space40),
        ),
        child: AppText.bodyMedium(
          '${date.day}',
          textAlign: TextAlign.center,
          color: textColor,
        ),
      ),
    );
  }

  String _dayKey(DateTime day) {
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return 'app_date_picker_day_${day.year}-$month-$date';
  }
}
