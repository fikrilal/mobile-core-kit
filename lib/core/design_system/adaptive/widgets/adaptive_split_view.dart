import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/size_classes.dart';

/// List/detail split view that adapts between one-pane and two-pane layouts.
///
/// - Compact widths: typically handled via navigation; this widget renders
///   either `master` or `detail` depending on [showDetailInCompact].
/// - Expanded widths (or spanned foldables): renders a two-pane layout.
///
/// When spanned and hinge geometry is available for the global window, this
/// widget prefers hinge-aware splits. Otherwise it falls back to a flex split
/// with minimum widths.
class AdaptiveSplitView extends StatelessWidget {
  const AdaptiveSplitView({
    super.key,
    required this.master,
    required this.detail,
    this.hasSelection = false,
    this.showDetailInCompact = false,
    this.detailPlaceholder,
    this.masterFlex = 2,
    this.detailFlex = 3,
    this.minMasterWidth = 320,
    this.minDetailWidth = 360,
    this.dividerWidth = 1,
  }) : assert(masterFlex > 0),
       assert(detailFlex > 0),
       assert(minMasterWidth >= 0),
       assert(minDetailWidth >= 0),
       assert(dividerWidth >= 0);

  final Widget master;
  final Widget detail;

  /// Whether the detail pane should be considered "active".
  ///
  /// - Two-pane layouts: shows `detail` when true, otherwise `detailPlaceholder`.
  /// - Compact layouts: typically handled via navigation; you can opt into
  ///   rendering `detail` via `showDetailInCompact`.
  final bool hasSelection;

  /// On compact widths, a split view is typically handled via navigation.
  /// When `true`, this widget renders `detail` instead of `master` on compact.
  final bool showDetailInCompact;

  /// Shown as the detail pane when there is no selection (two-pane layouts only).
  final Widget? detailPlaceholder;

  final int masterFlex;
  final int detailFlex;
  final double minMasterWidth;
  final double minDetailWidth;
  final double dividerWidth;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    final foldable = context.adaptiveFoldable;

    final isTwoPane =
        _isAtLeastExpanded(layout.widthClass) || foldable.isSpanned;
    if (!isTwoPane) {
      return showDetailInCompact && hasSelection ? detail : master;
    }

    final placeholder = detailPlaceholder ?? const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final canUseGlobalHingeGeometry =
            foldable.isSpanned &&
            foldable.hingeRect != null &&
            constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            constraints.maxWidth == layout.size.width &&
            constraints.maxHeight == layout.size.height;

        if (canUseGlobalHingeGeometry) {
          final hingeRect = foldable.hingeRect!;
          final axis = foldable.hingeAxis;
          if (axis == Axis.vertical) {
            final built = _buildVerticalHingeSplit(
              constraints: constraints,
              hingeRect: hingeRect,
              placeholder: placeholder,
            );
            if (built != null) return built;
          }
          if (axis == Axis.horizontal) {
            final built = _buildHorizontalHingeSplit(
              constraints: constraints,
              hingeRect: hingeRect,
              placeholder: placeholder,
            );
            if (built != null) return built;
          }
        }

        return _buildFlexSplit(
          constraints: constraints,
          placeholder: placeholder,
        );
      },
    );
  }

  bool _isAtLeastExpanded(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact || WindowWidthClass.medium => false,
      _ => true,
    };
  }

  Widget _buildFlexSplit({
    required BoxConstraints constraints,
    required Widget placeholder,
  }) {
    final totalWidth = constraints.maxWidth;
    final divider = dividerWidth;
    final available = math.max(0.0, totalWidth - divider).toDouble();

    final flexSum = (masterFlex + detailFlex).toDouble();
    final idealMaster = available * (masterFlex / flexSum);

    final maxMasterWidth = math
        .max(minMasterWidth, available - minDetailWidth)
        .toDouble();
    final masterWidth = idealMaster
        .clamp(minMasterWidth, maxMasterWidth)
        .toDouble();
    final detailWidth = math.max(0.0, available - masterWidth).toDouble();

    if (masterWidth < minMasterWidth || detailWidth < minDetailWidth) {
      return showDetailInCompact && hasSelection ? detail : master;
    }

    return Row(
      children: [
        SizedBox(width: masterWidth, child: master),
        if (divider > 0) VerticalDivider(width: divider, thickness: divider),
        SizedBox(
          width: detailWidth,
          child: hasSelection ? detail : placeholder,
        ),
      ],
    );
  }

  Widget? _buildVerticalHingeSplit({
    required BoxConstraints constraints,
    required Rect hingeRect,
    required Widget placeholder,
  }) {
    final totalWidth = constraints.maxWidth;

    final leftWidth = math.max(0.0, hingeRect.left).toDouble();
    final rightWidth = math.max(0.0, totalWidth - hingeRect.right).toDouble();
    final gapWidth = math.max(dividerWidth, hingeRect.width).toDouble();

    if (leftWidth < minMasterWidth || rightWidth < minDetailWidth) return null;
    if (leftWidth + gapWidth + rightWidth > totalWidth + 0.5) return null;

    return Row(
      children: [
        SizedBox(width: leftWidth, child: master),
        SizedBox(width: gapWidth),
        SizedBox(width: rightWidth, child: hasSelection ? detail : placeholder),
      ],
    );
  }

  Widget? _buildHorizontalHingeSplit({
    required BoxConstraints constraints,
    required Rect hingeRect,
    required Widget placeholder,
  }) {
    final totalHeight = constraints.maxHeight;

    final topHeight = math.max(0.0, hingeRect.top).toDouble();
    final bottomHeight = math
        .max(0.0, totalHeight - hingeRect.bottom)
        .toDouble();
    final gapHeight = math.max(dividerWidth, hingeRect.height).toDouble();

    if (topHeight <= 0 || bottomHeight <= 0) return null;
    if (topHeight + gapHeight + bottomHeight > totalHeight + 0.5) return null;

    return Column(
      children: [
        SizedBox(height: topHeight, child: master),
        SizedBox(height: gapHeight),
        SizedBox(
          height: bottomHeight,
          child: hasSelection ? detail : placeholder,
        ),
      ],
    );
  }
}
