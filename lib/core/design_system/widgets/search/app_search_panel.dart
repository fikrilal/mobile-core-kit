import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_highlight_text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_keys.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_models.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_style.dart';

class AppSearchPanel<T> extends StatelessWidget {
  const AppSearchPanel({
    super.key,
    required this.style,
    required this.palette,
    required this.query,
    required this.history,
    required this.suggestions,
    required this.loadingText,
    required this.historySectionLabel,
    required this.suggestionsSectionLabel,
    required this.clearHistoryLabel,
    required this.isLoading,
    required this.showClearHistoryAction,
    required this.highlightedIndex,
    required this.noResultsText,
    required this.scrollController,
    this.scrollPhysics,
    required this.onHistorySelected,
    required this.onSuggestionSelected,
    this.onClearHistory,
  });

  final AppSearchStyle style;
  final AppSearchPalette palette;
  final String query;
  final List<String> history;
  final List<AppSearchSuggestion<T>> suggestions;
  final String loadingText;
  final String historySectionLabel;
  final String suggestionsSectionLabel;
  final String clearHistoryLabel;
  final bool isLoading;
  final bool showClearHistoryAction;
  final int highlightedIndex;
  final String? noResultsText;
  final ScrollController scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<String> onHistorySelected;
  final ValueChanged<AppSearchSuggestion<T>> onSuggestionSelected;
  final VoidCallback? onClearHistory;

  @override
  Widget build(BuildContext context) {
    final hasHistory = history.isNotEmpty;
    final hasSuggestions = suggestions.isNotEmpty;

    return AnimatedContainer(
      key: appSearchExperiencePanelKey,
      duration: MotionDurations.short,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: palette.panelBackground,
        borderRadius: BorderRadius.circular(style.panelRadius),
        border: Border.all(
          color: palette.panelBorder,
          width: style.borderWidth,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: style.panelMaxHeight),
        child: ScrollConfiguration(
          behavior: const _SearchPanelScrollBehavior(),
          child: ListView(
            key: appSearchExperiencePanelListKey,
            controller: scrollController,
            physics:
                scrollPhysics ??
                const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
            padding: EdgeInsets.symmetric(
              horizontal: style.panelHorizontalPadding,
              vertical: style.panelVerticalPadding,
            ),
            children: [
              if (isLoading) _LoadingRow(label: loadingText),
              if (hasHistory)
                _SectionHeader(
                  label: historySectionLabel,
                  trailing: showClearHistoryAction && onClearHistory != null
                      ? TextButton(
                          key: appSearchExperienceClearHistoryKey,
                          onPressed: onClearHistory,
                          child: Text(clearHistoryLabel),
                        )
                      : null,
                  palette: palette,
                ),
              if (hasHistory)
                ..._buildHistoryRows(context, baseIndex: 0, values: history),
              if (hasHistory && hasSuggestions && style.showSectionDividers)
                Divider(
                  color: palette.panelDivider,
                  height: AppSpacing.space16,
                ),
              if (hasSuggestions)
                _SectionHeader(
                  label: suggestionsSectionLabel,
                  palette: palette,
                ),
              if (hasSuggestions)
                ..._buildSuggestionRows(
                  context,
                  baseIndex: history.length,
                  values: suggestions,
                ),
              if (!isLoading && !hasSuggestions && noResultsText != null)
                _NoResultRow(label: noResultsText!, palette: palette),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHistoryRows(
    BuildContext context, {
    required int baseIndex,
    required List<String> values,
  }) {
    final rows = <Widget>[];

    for (var i = 0; i < values.length; i++) {
      final entry = values[i];
      rows.add(
        _PanelEntryTile(
          key: appSearchExperienceHistoryItemKey(entry),
          palette: palette,
          style: style,
          highlighted: highlightedIndex == (baseIndex + i),
          leading: Icon(Icons.history_rounded, color: palette.panelItemIcon),
          title: AppText.bodyMedium(
            entry,
            color: palette.panelItemText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onHistorySelected(entry),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildSuggestionRows(
    BuildContext context, {
    required int baseIndex,
    required List<AppSearchSuggestion<T>> values,
  }) {
    final titleStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.panelItemText,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(color: palette.panelItemText, fontWeight: FontWeight.w500);
    final highlightedStyle = titleStyle.copyWith(color: palette.panelAccent);

    final rows = <Widget>[];
    for (var i = 0; i < values.length; i++) {
      final entry = values[i];
      rows.add(
        _PanelEntryTile(
          key: appSearchExperienceSuggestionItemKey(entry.label),
          palette: palette,
          style: style,
          highlighted: highlightedIndex == (baseIndex + i),
          leading:
              entry.leading ??
              Icon(Icons.search_rounded, color: palette.panelItemIcon),
          trailing:
              entry.trailing ??
              Icon(Icons.north_west_rounded, color: palette.panelItemIcon),
          title: AppSearchHighlightText(
            text: entry.label,
            query: query,
            style: titleStyle,
            highlightStyle: highlightedStyle,
          ),
          subtitle: entry.subtitle == null
              ? null
              : AppText.bodySmall(
                  entry.subtitle!,
                  color: palette.panelItemSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: () => onSuggestionSelected(entry),
        ),
      );
    }

    return rows;
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: [
          const SizedBox.square(
            dimension: AppSpacing.space16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(child: AppText.bodyMedium(label)),
        ],
      ),
    );
  }
}

class _NoResultRow extends StatelessWidget {
  const _NoResultRow({required this.label, required this.palette});

  final String label;
  final AppSearchPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space16,
      ),
      child: AppText.bodyMedium(
        label,
        color: palette.panelItemSubtitle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.palette,
    this.trailing,
  });

  final String label;
  final AppSearchPalette palette;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText.labelSmall(
              label,
              color: palette.panelSectionLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PanelEntryTile extends StatefulWidget {
  const _PanelEntryTile({
    super.key,
    required this.palette,
    required this.style,
    required this.highlighted,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final AppSearchPalette palette;
  final AppSearchStyle style;
  final bool highlighted;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  State<_PanelEntryTile> createState() => _PanelEntryTileState();
}

class _PanelEntryTileState extends State<_PanelEntryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = widget.highlighted
        ? widget.palette.panelItemSelected
        : _hovered
        ? widget.palette.panelItemHover
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Material(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(widget.style.itemRadius),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.style.itemRadius),
          onHover: (value) {
            if (_hovered == value) return;
            setState(() {
              _hovered = value;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.style.itemHorizontalPadding,
              vertical: widget.style.itemVerticalPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.leading,
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.title,
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.space4),
                        widget.subtitle!,
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: AppSpacing.space8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchPanelScrollBehavior extends MaterialScrollBehavior {
  const _SearchPanelScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
