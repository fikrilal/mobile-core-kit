import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';

/// Convenience grid widget for responsive column counts.
///
/// Typically you compute `columns` from `context.adaptiveLayout.grid.columns`.
/// If `gutter` is not provided, this defaults to `layout.gutter`.
class AdaptiveGrid extends StatelessWidget {
  AdaptiveGrid({
    super.key,
    required this.columns,
    required List<Widget> children,
    this.gutter,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : assert(columns >= 1, 'columns must be >= 1'),
       itemCount = children.length,
       itemBuilder = ((context, index) => children[index]);

  const AdaptiveGrid.builder({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
    this.gutter,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : assert(columns >= 1, 'columns must be >= 1'),
       assert(itemCount >= 0, 'itemCount must be >= 0');

  final int columns;

  /// Spacing between tiles. Defaults to `context.adaptiveLayout.gutter`.
  final double? gutter;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final spacing = gutter ?? context.adaptiveLayout.gutter;

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    );

    return GridView.builder(
      gridDelegate: gridDelegate,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
