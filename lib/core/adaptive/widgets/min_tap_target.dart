import 'package:flutter/widgets.dart';

import '../adaptive_context.dart';

class MinTapTarget extends StatelessWidget {
  const MinTapTarget({
    super.key,
    required this.child,
    this.minSize,
  });

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

