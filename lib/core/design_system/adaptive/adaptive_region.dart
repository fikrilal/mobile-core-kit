import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_spec_builder.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/size_classes.dart';

/// Local adaptive scope for nested constraints.
///
/// Use this inside split panes / resizable panels where the subtree should
/// adapt based on *its own* `BoxConstraints`, not the global window size.
///
/// `AdaptiveRegion` re-derives only [LayoutSpec] from the local constraints and
/// inherits the rest of the contract (text/motion/input/platform/foldable/insets)
/// from the nearest `AdaptiveScope`.
///
/// Navigation is forced to `NavigationKind.none` inside the region to prevent
/// accidental nested navigation shells.
class AdaptiveRegion extends StatelessWidget {
  const AdaptiveRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parent = AdaptiveModel.of(context);
        final media = MediaQuery.of(context);
        final size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : media.size.width,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : media.size.height,
        );

        final widthClass = widthClassFor(size.width);
        final heightClass = heightClassFor(size.height);
        final orientation = size.width >= size.height
            ? Orientation.landscape
            : Orientation.portrait;

        final localLayout = AdaptiveSpecBuilder.deriveLayout(
          constraints: constraints,
          media: media,
          widthClass: widthClass,
          heightClass: heightClass,
          orientation: orientation,
          input: parent.input,
          navigation: const NavigationSpec(kind: NavigationKind.none),
        );

        final localSpec = parent.copyWith(layout: localLayout);

        return AdaptiveModel(spec: localSpec, child: child);
      },
    );
  }
}
