import 'package:flutter/material.dart';

/// Small, design-system friendly text wrapper.
///
/// Canonical typography in this repo is `Theme.of(context).textTheme.*`.
/// `AppText` exists to reduce boilerplate and to keep UI code consistent.
///
/// Rules:
/// - Do not manually scale fonts (root `AdaptiveScope` applies `TextScaler`).
/// - Prefer role colors (e.g. `context.textPrimary`) over hardcoded values.
/// - If you need advanced behavior, use `Text` / `SelectableText` directly with
///   `Theme.of(context).textTheme.*`.
class AppText extends StatelessWidget {
  final String text;
  final _AppTextRole _role;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final bool selectable;
  final String? semanticsLabel;
  final bool excludeFromSemantics;

  const AppText.displayLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.displayLarge;

  const AppText.displayMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.displayMedium;

  const AppText.displaySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.displaySmall;

  const AppText.headlineLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.headlineLarge;

  const AppText.headlineMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.headlineMedium;

  const AppText.headlineSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.headlineSmall;

  const AppText.titleLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.titleLarge;

  const AppText.titleMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.titleMedium;

  const AppText.titleSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.titleSmall;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.bodyLarge;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.bodyMedium;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.bodySmall;

  const AppText.labelLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.labelLarge;

  const AppText.labelMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.labelMedium;

  const AppText.labelSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : _role = _AppTextRole.labelSmall;

  @override
  Widget build(BuildContext context) {
    final base = _resolveBaseStyle(context);
    final effectiveStyle = base.copyWith(
      color: color ?? base.color,
      fontWeight: fontWeight ?? base.fontWeight,
    );

    Widget child;
    if (selectable) {
      child = SelectableText(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
      );
    } else {
      child = Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
      );
    }

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }
    return child;
  }

  TextStyle _resolveBaseStyle(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return switch (_role) {
      _AppTextRole.displayLarge => t.displayLarge,
      _AppTextRole.displayMedium => t.displayMedium,
      _AppTextRole.displaySmall => t.displaySmall,
      _AppTextRole.headlineLarge => t.headlineLarge,
      _AppTextRole.headlineMedium => t.headlineMedium,
      _AppTextRole.headlineSmall => t.headlineSmall,
      _AppTextRole.titleLarge => t.titleLarge,
      _AppTextRole.titleMedium => t.titleMedium,
      _AppTextRole.titleSmall => t.titleSmall,
      _AppTextRole.bodyLarge => t.bodyLarge,
      _AppTextRole.bodyMedium => t.bodyMedium,
      _AppTextRole.bodySmall => t.bodySmall,
      _AppTextRole.labelLarge => t.labelLarge,
      _AppTextRole.labelMedium => t.labelMedium,
      _AppTextRole.labelSmall => t.labelSmall,
    } ??
        const TextStyle();
  }
}

enum _AppTextRole {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}
