import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';

enum AppFilterSelectionMode { single, multiple }

enum AppFilterChipsLayout { horizontal, wrap }

typedef AppFilterSelectionChanged<T> = void Function(Set<T> selectedValues);
typedef AppFilterSelectedCountLabelBuilder =
    String? Function(int selectedCount);

const appFilterChipsClearActionKey = Key('app_filter_chips_clear_action');

class AppFilterChipItem<T> {
  const AppFilterChipItem({
    required this.value,
    required this.label,
    this.enabled = true,
    this.avatar,
    this.tooltip,
  });

  final T value;
  final String label;
  final bool enabled;
  final Widget? avatar;
  final String? tooltip;
}

class AppFilterChipsBar<T> extends StatelessWidget {
  const AppFilterChipsBar({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.selectionMode = AppFilterSelectionMode.multiple,
    this.layout = AppFilterChipsLayout.horizontal,
    this.isEnabled = true,
    this.spacing = AppSpacing.space8,
    this.runSpacing = AppSpacing.space8,
    this.padding,
    this.showClearAction = false,
    this.clearActionLabel,
    this.onClear,
    this.selectedCountLabelBuilder,
  }) : assert(
         !showClearAction || clearActionLabel != null,
         'clearActionLabel must be provided when showClearAction is true.',
       ),
       assert(spacing >= 0, 'spacing must be greater than or equal to zero.'),
       assert(
         runSpacing >= 0,
         'runSpacing must be greater than or equal to zero.',
       );

  final List<AppFilterChipItem<T>> items;
  final Set<T> selectedValues;
  final AppFilterSelectionChanged<T> onSelectionChanged;
  final AppFilterSelectionMode selectionMode;
  final AppFilterChipsLayout layout;
  final bool isEnabled;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final bool showClearAction;
  final String? clearActionLabel;
  final VoidCallback? onClear;
  final AppFilterSelectedCountLabelBuilder? selectedCountLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final selectedCountLabel = selectedCountLabelBuilder?.call(
      selectedValues.length,
    );
    final selectedCountText = selectedCountLabel?.trim();
    final showSelectedCount = selectedCountText != null
        ? selectedCountText.isNotEmpty
        : false;
    final showMetaRow = showSelectedCount || showClearAction;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showMetaRow) ...[
            Row(
              children: [
                if (showSelectedCount)
                  AppText.bodySmall(selectedCountText, maxLines: 1),
                if (showClearAction) ...[
                  if (showSelectedCount) const Spacer(),
                  TextButton(
                    key: appFilterChipsClearActionKey,
                    onPressed: _isClearEnabled ? _handleClear : null,
                    child: Text(clearActionLabel!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
          ],
          switch (layout) {
            AppFilterChipsLayout.horizontal => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _chipsWithSpacing(context)),
            ),
            AppFilterChipsLayout.wrap => Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: _chipWidgets(context),
            ),
          },
        ],
      ),
    );
  }

  bool get _isClearEnabled => isEnabled && selectedValues.isNotEmpty;

  void _handleClear() {
    final onClear = this.onClear;
    if (onClear != null) {
      onClear();
      return;
    }
    onSelectionChanged(<T>{});
  }

  List<Widget> _chipsWithSpacing(BuildContext context) {
    final chips = _chipWidgets(context);
    if (chips.isEmpty) return const <Widget>[];

    final withSpacing = <Widget>[];
    for (var index = 0; index < chips.length; index++) {
      if (index > 0) {
        withSpacing.add(SizedBox(width: spacing));
      }
      withSpacing.add(chips[index]);
    }
    return withSpacing;
  }

  List<Widget> _chipWidgets(BuildContext context) {
    return items
        .map((item) {
          final isItemEnabled = isEnabled && item.enabled;
          final isSelected = selectedValues.contains(item.value);

          return FilterChip(
            label: Text(item.label),
            avatar: item.avatar,
            tooltip: item.tooltip,
            selected: isSelected,
            onSelected: isItemEnabled
                ? (nextSelected) => _onChipSelected(
                    value: item.value,
                    nextSelected: nextSelected,
                  )
                : null,
          );
        })
        .toList(growable: false);
  }

  void _onChipSelected({required T value, required bool nextSelected}) {
    final nextValues = switch (selectionMode) {
      AppFilterSelectionMode.single => nextSelected ? <T>{value} : <T>{},
      AppFilterSelectionMode.multiple => _toggleInMultipleMode(
        value: value,
        nextSelected: nextSelected,
      ),
    };
    onSelectionChanged(nextValues);
  }

  Set<T> _toggleInMultipleMode({required T value, required bool nextSelected}) {
    final nextValues = Set<T>.from(selectedValues);
    if (nextSelected) {
      nextValues.add(value);
    } else {
      nextValues.remove(value);
    }
    return nextValues;
  }
}
