import 'package:flutter/material.dart';

import '../../theme/extensions/theme_extensions_utils.dart';
import '../../theme/responsive/spacing.dart';
import '../avatar/avatar_size.dart';

/// Circular icon container with an optional notification dot (top-right).
///
/// Designed for use as a leading widget in rows/tiles (Wise-style).
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = AppAvatarSize.md,
    this.showDot = false,
    this.onTap,
    this.semanticsLabel,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = AppSpacing.space1,
    this.iconColor,
    this.iconSize,
    this.dotColor,
    this.dotBorderColor,
  });

  final Widget icon;
  final AppAvatarSize size;

  final bool showDot;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  final Color? iconColor;
  final double? iconSize;

  final Color? dotColor;
  final Color? dotBorderColor;

  static const _containerKey = ValueKey('AppIconBadge.container');
  static const _dotKey = ValueKey('AppIconBadge.dot');

  @override
  Widget build(BuildContext context) {
    final diameter = size.diameter;

    final effectiveBackground = backgroundColor ?? context.bgContainerHigh;
    final effectiveBorder = borderColor ?? context.borderSubtle;
    final effectiveIconColor = iconColor ?? context.textPrimary;
    final effectiveIconSize = iconSize ?? (diameter * 0.44).clamp(16.0, 28.0);

    final circle = _buildCircle(
      diameter: diameter,
      background: effectiveBackground,
      borderColor: effectiveBorder,
      iconColor: effectiveIconColor,
      iconSize: effectiveIconSize,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: semanticsLabel,
        button: onTap != null,
        child: SizedBox(
          key: _containerKey,
          width: diameter,
          height: diameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              circle,
              if (showDot)
                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildDot(context, diameter: diameter),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle({
    required double diameter,
    required Color background,
    required Color borderColor,
    required Color iconColor,
    required double iconSize,
  }) {
    final decoration = BoxDecoration(
      color: background,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: borderWidth),
    );

    final content = Center(
      child: IconTheme(
        data: IconThemeData(color: iconColor, size: iconSize),
        child: icon,
      ),
    );

    if (onTap == null) {
      return ClipOval(
        child: DecoratedBox(
          decoration: decoration,
          child: SizedBox(width: diameter, height: diameter, child: content),
        ),
      );
    }

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: diameter,
            height: diameter,
            decoration: decoration,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, {required double diameter}) {
    final dotDiameter = (diameter * 0.30).clamp(10.0, 18.0);
    final dotOverlap = (dotDiameter * 0.18).clamp(2.0, 4.0);
    final overlap = dotOverlap - AppSpacing.space2;
    final bg = dotColor ?? context.cs.error;
    final border = dotBorderColor ?? context.bgSurface;

    return Transform.translate(
      offset: Offset(overlap, -overlap),
      child: SizedBox(
        key: _dotKey,
        width: dotDiameter,
        height: dotDiameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: AppSpacing.space2),
          ),
        ),
      ),
    );
  }
}
