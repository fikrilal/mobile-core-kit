import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/date_picker/date_picker.dart';

class DatePickerShowcaseScreen extends StatefulWidget {
  const DatePickerShowcaseScreen({super.key});

  @override
  State<DatePickerShowcaseScreen> createState() =>
      _DatePickerShowcaseScreenState();
}

class _DatePickerShowcaseScreenState extends State<DatePickerShowcaseScreen> {
  DateTime? _selectedDate = DateTime(2026, 4, 7);
  DateTimeRange? _selectedRange = DateTimeRange(
    start: DateTime(2026, 4, 7),
    end: DateTime(2026, 4, 10),
  );

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return localizations.formatMediumDate(date);
    }

    String formatRange(DateTimeRange? range) {
      if (range == null) return '-';
      final start = localizations.formatMediumDate(range.start);
      final end = localizations.formatMediumDate(range.end);
      return '$start - $end';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Date Picker Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space24),
              const AppText.titleLarge('Single Date'),
              const SizedBox(height: AppSpacing.space8),
              AppDateField.single(
                labelText: 'Select date',
                hintText: 'Pick a date',
                value: _selectedDate,
                firstDate: DateTime(2024, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                confirmLabel: 'Apply',
                cancelLabel: 'Cancel',
                resetLabel: 'Reset',
                onChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodySmall('Current: ${formatDate(_selectedDate)}'),
              const SizedBox(height: AppSpacing.space24),
              const AppText.titleLarge('Date Range'),
              const SizedBox(height: AppSpacing.space8),
              AppDateField.range(
                labelText: 'Select date range',
                hintText: 'Pick a range',
                rangeValue: _selectedRange,
                firstDate: DateTime(2024, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                minRangeDays: 2,
                maxRangeDays: 7,
                constraintMessage: 'Choose between 2 and 7 days.',
                confirmLabel: 'Apply',
                cancelLabel: 'Cancel',
                resetLabel: 'Reset',
                onRangeChanged: (range) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodySmall('Current: ${formatRange(_selectedRange)}'),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
