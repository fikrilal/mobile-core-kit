import 'package:flutter/material.dart';

import '../tokens/type_metrics.dart';

/// Paragraph widget for multi-line body text.
///
/// This focuses on the two common enterprise needs:
/// 1) consistent typography role (bodyLarge/bodyMedium/bodySmall)
/// 2) readable line length on larger widths (tablet)
///
/// If you need more advanced behavior, use `Text`/`SelectableText` directly
/// with `Theme.of(context).textTheme.*`.
class Paragraph extends StatelessWidget {
  final String text;
  final _ParagraphRole _role;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final bool selectable;
  final bool constrainWidth;

  const Paragraph.large(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.constrainWidth = true,
  }) : _role = _ParagraphRole.bodyLarge;

  const Paragraph(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.constrainWidth = true,
  }) : _role = _ParagraphRole.bodyMedium;

  const Paragraph.small(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.constrainWidth = true,
  }) : _role = _ParagraphRole.bodySmall;

  @override
  Widget build(BuildContext context) {
    final baseStyle = _resolveStyle(context);
    final effectiveStyle = baseStyle.copyWith(
      color: color ?? baseStyle.color,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
    );

    final textWidget = selectable
        ? SelectableText(
            text,
            style: effectiveStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          )
        : Text(
            text,
            style: effectiveStyle,
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
          );

    if (!constrainWidth) {
      return textWidget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = _idealMaxWidth(
          constraints: constraints,
          media: MediaQuery.of(context),
          fontSize: effectiveStyle.fontSize ?? 14.0,
        );
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: textWidget,
          ),
        );
      },
    );
  }

  TextStyle _resolveStyle(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return switch (_role) {
      _ParagraphRole.bodyLarge => t.bodyLarge,
      _ParagraphRole.bodyMedium => t.bodyMedium,
      _ParagraphRole.bodySmall => t.bodySmall,
    } ??
        const TextStyle();
  }

  double _idealMaxWidth({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required double fontSize,
  }) {
    final availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : media.size.width;

    final safeAvailableWidth = availableWidth.isFinite && availableWidth > 0
        ? availableWidth
        : 0.0;

    final ideal = TypeMetrics.getIdealTextContainerWidth(fontSize);
    return ideal < safeAvailableWidth ? ideal : safeAvailableWidth;
  }
}

enum _ParagraphRole { bodyLarge, bodyMedium, bodySmall }
