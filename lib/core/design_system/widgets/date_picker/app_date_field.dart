import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/widgets/date_picker/app_date_picker_sheet.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';

class AppDateField extends StatefulWidget {
  const AppDateField.single({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.labelPosition = LabelPosition.above,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    this.resetLabel,
    this.suffixIcon,
    this.useRootNavigator = true,
  }) : mode = AppDateSelectionMode.single,
       rangeValue = null,
       onRangeChanged = null,
       minRangeDays = null,
       maxRangeDays = null,
       constraintMessage = null;

  const AppDateField.range({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.rangeValue,
    this.onRangeChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.labelPosition = LabelPosition.above,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    this.resetLabel,
    this.minRangeDays,
    this.maxRangeDays,
    this.constraintMessage,
    this.suffixIcon,
    this.useRootNavigator = true,
  }) : mode = AppDateSelectionMode.range,
       value = null,
       onChanged = null;

  final AppDateSelectionMode mode;

  final DateTime firstDate;
  final DateTime lastDate;

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;

  final DateTimeRange? rangeValue;
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  final bool enabled;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;

  final FieldVariant variant;
  final FieldSize size;
  final LabelPosition labelPosition;

  final AppSelectableDayPredicate? selectableDayPredicate;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;
  final String? resetLabel;
  final int? minRangeDays;
  final int? maxRangeDays;
  final String? constraintMessage;
  final Widget? suffixIcon;
  final bool useRootNavigator;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncText();
  }

  @override
  void didUpdateWidget(covariant AppDateField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final didValueChange = oldWidget.value != widget.value;
    final didRangeChange = oldWidget.rangeValue != widget.rangeValue;
    final didModeChange = oldWidget.mode != widget.mode;

    if (didValueChange || didRangeChange || didModeChange) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      variant: widget.variant,
      size: widget.size,
      fieldType: FieldType.text,
      labelText: widget.labelText,
      labelPosition: widget.labelPosition,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      semanticLabel: widget.semanticLabel,
      suffixIcon:
          widget.suffixIcon ?? const Icon(Icons.calendar_today_outlined),
      onTap: widget.enabled ? _handleTap : null,
    );
  }

  Future<void> _handleTap() async {
    switch (widget.mode) {
      case AppDateSelectionMode.single:
        final selected = await showAppSingleDatePickerSheet(
          context: context,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          initialDate: widget.value,
          selectableDayPredicate: widget.selectableDayPredicate,
          title: widget.title,
          confirmLabel: widget.confirmLabel,
          cancelLabel: widget.cancelLabel,
          resetLabel: widget.resetLabel,
          useRootNavigator: widget.useRootNavigator,
        );
        if (!mounted || selected == null) return;
        widget.onChanged?.call(selected);
      case AppDateSelectionMode.range:
        final selected = await showAppDateRangePickerSheet(
          context: context,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          initialRange: widget.rangeValue,
          minRangeDays: widget.minRangeDays,
          maxRangeDays: widget.maxRangeDays,
          selectableDayPredicate: widget.selectableDayPredicate,
          title: widget.title,
          confirmLabel: widget.confirmLabel,
          cancelLabel: widget.cancelLabel,
          resetLabel: widget.resetLabel,
          constraintMessage: widget.constraintMessage,
          useRootNavigator: widget.useRootNavigator,
        );
        if (!mounted || selected == null) return;
        widget.onRangeChanged?.call(selected);
    }
  }

  void _syncText() {
    final localizations = MaterialLocalizations.of(context);

    String format(DateTime? value) {
      if (value == null) return '';
      return localizations.formatMediumDate(value);
    }

    final text = switch (widget.mode) {
      AppDateSelectionMode.single => format(widget.value),
      AppDateSelectionMode.range => _formatRangeText(localizations),
    };

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatRangeText(MaterialLocalizations localizations) {
    final range = widget.rangeValue;
    if (range == null) return '';

    final startText = localizations.formatMediumDate(range.start);
    final endText = localizations.formatMediumDate(range.end);

    if (_isSameDay(range.start, range.end)) {
      return startText;
    }

    return '$startText - $endText';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
