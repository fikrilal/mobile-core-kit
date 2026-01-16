import 'package:flutter/material.dart';

/// Semantic heading wrapper (thin wrapper over `Theme.of(context).textTheme`).
///
/// Use `Heading.h1/h2/h3/...` for section titles and page headers. If you need
/// advanced behavior, use `Text` directly with `Theme.of(context).textTheme`.
class Heading extends StatelessWidget {
  final String text;
  final int level;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final Color? color;
  final String? semanticsLabel;
  final bool excludeFromSemantics;

  const Heading.h1(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 1;

  const Heading.h2(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 2;

  const Heading.h3(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 3;

  const Heading.h4(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 4;

  const Heading.h5(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 5;

  const Heading.h6(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : level = 6;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context).copyWith(color: color);

    final widget = Text(
      text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );

    return Semantics(
      header: true,
      label: semanticsLabel ?? text,
      excludeSemantics: excludeFromSemantics,
      child: widget,
    );
  }

  TextStyle _resolveStyle(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return switch (level) {
      1 => t.displayLarge,
      2 => t.displayMedium,
      3 => t.displaySmall,
      4 => t.headlineLarge,
      5 => t.headlineMedium,
      6 => t.headlineSmall,
      _ => t.displayLarge,
    } ??
        const TextStyle();
  }
}
