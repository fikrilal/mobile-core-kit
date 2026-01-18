import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';

/// Default screen wrapper for adaptive page layout.
///
/// Responsibilities:
/// - applies safe area padding (optional)
/// - applies adaptive page padding (`layout.pagePadding`) by default
/// - clamps content width by [SurfaceKind] via surface tokens
///
/// This widget is intentionally lightweight. Scrolling, app bars, etc. are the
/// responsibility of the caller.
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

  /// Semantic surface classification used to select max-width rules.
  final SurfaceKind surface;

  /// When true, includes `MediaQuery.padding` (safe area) in the effective padding.
  final bool safeArea;
  final AlignmentGeometry alignment;

  /// Optional padding override. Defaults to `context.adaptiveLayout.pagePadding`.
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
