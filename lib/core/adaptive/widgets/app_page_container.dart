import 'package:flutter/widgets.dart';

import '../adaptive_context.dart';
import '../tokens/surface_tokens.dart';

class AppPageContainer extends StatelessWidget {
  const AppPageContainer({
    super.key,
    required this.child,
    this.surface = SurfaceKind.settings,
    this.safeArea = true,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final SurfaceKind surface;
  final bool safeArea;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;

    final resolvedPadding = padding ?? layout.pagePadding;
    final safePadding = safeArea
        ? MediaQuery.paddingOf(context)
        : EdgeInsets.zero;
    final effectivePadding = safePadding.add(resolvedPadding);

    final maxWidth = layout.surface(surface).contentMaxWidth;
    Widget content = Padding(padding: effectivePadding, child: child);

    content = Align(
      alignment: alignment,
      child: maxWidth == null
          ? content
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: content,
            ),
    );

    return content;
  }
}
