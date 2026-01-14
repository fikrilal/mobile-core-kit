import 'package:flutter/widgets.dart';

import 'adaptive_scope.dart';
import 'adaptive_spec.dart';
import 'adaptive_spec_builder.dart';
import 'size_classes.dart';

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
