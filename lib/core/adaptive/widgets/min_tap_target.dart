import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';

/// Ensures a minimum interactive size for touch targets.
///
/// Defaults to `context.adaptiveLayout.minTapTarget`, but can be overridden via
/// [minSize]. Useful for icon-only buttons.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({super.key, required this.child, this.minSize});

  final Widget child;
  final double? minSize;

  @override
  Widget build(BuildContext context) {
    final size = minSize ?? context.adaptiveLayout.minTapTarget;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: Center(child: child),
    );
  }
}
