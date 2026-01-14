import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'spacing.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? maxWidth;
  final BoxDecoration? decoration;
  final double? height;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.centerContent = false,
    this.padding,
    this.backgroundColor,
    this.maxWidth,
    this.decoration,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: height,
      // ignore: deprecated_member_use_from_same_package
      padding: padding ?? LegacyResponsiveSpacing.screenPadding(context),
      width: double.infinity,
      decoration: decoration,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              maxWidth ?? Breakpoints.getMaxContentWidthFromContext(context),
        ),
        child: centerContent ? Center(child: child) : child,
      ),
    );
  }
}
