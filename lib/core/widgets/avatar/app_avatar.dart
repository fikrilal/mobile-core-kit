import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../localization/l10n.dart';
import '../../theme/tokens/spacing.dart';
import 'avatar_size.dart';

/// A reusable circular avatar component with sensible fallbacks:
/// photo -> initials -> generic person icon.
///
/// To enable the "edit avatar" variant (camera badge), provide [onChangePhoto].
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.imageProvider,
    this.displayName,
    this.initials,
    this.size = AppAvatarSize.lg,
    this.onTap,
    this.onChangePhoto,
    this.semanticsLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.badgeBackgroundColor,
    this.badgeIconColor,
  });

  final String? imageUrl;
  final ImageProvider? imageProvider;

  /// Used to compute initials when [initials] is not provided.
  final String? displayName;

  /// Explicit initials override (will be normalized to 1–2 chars).
  final String? initials;

  final AppAvatarSize size;

  /// Optional tap on the avatar surface (e.g. open profile).
  final VoidCallback? onTap;

  /// When provided, shows a camera badge (tap triggers this callback).
  final VoidCallback? onChangePhoto;

  final String? semanticsLabel;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;

  final Color? badgeBackgroundColor;
  final Color? badgeIconColor;

  bool get _hasImage {
    final provider = imageProvider;
    if (provider != null) return true;
    final url = imageUrl;
    if (url == null) return false;
    return url.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final diameter = size.diameter;
    final normalizedInitials =
        _normalizeInitials(initials) ?? _computeInitials(displayName);

    final fallbackBg = backgroundColor ?? scheme.surfaceContainerHigh;
    final defaultFg = normalizedInitials != null
        ? scheme.primary
        : scheme.onSurfaceVariant;
    final fallbackFg = foregroundColor ?? defaultFg;

    final effectiveLabel =
        semanticsLabel ?? _defaultSemanticsLabel(context, displayName);
    final surfaceTap = onTap ?? onChangePhoto;

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: effectiveLabel,
        image: _hasImage,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAvatarSurface(
                context,
                diameter: diameter,
                background: fallbackBg,
                foreground: fallbackFg,
                initials: normalizedInitials,
                scheme: scheme,
                onSurfaceTap: surfaceTap,
              ),
              if (onChangePhoto != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildCameraBadge(
                    context,
                    avatarDiameter: diameter,
                    scheme: scheme,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSurface(
    BuildContext context, {
    required double diameter,
    required Color background,
    required Color foreground,
    required String? initials,
    required ColorScheme scheme,
    required VoidCallback? onSurfaceTap,
  }) {
    final border = borderColor == null || borderWidth <= 0
        ? null
        : Border.all(color: borderColor!, width: borderWidth);

    final decoration = BoxDecoration(
      color: background,
      shape: BoxShape.circle,
      border: border,
    );

    final content = _buildContent(
      context,
      diameter: diameter,
      initials: initials,
      foreground: foreground,
      scheme: scheme,
    );

    if (onSurfaceTap == null) {
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
          onTap: onSurfaceTap,
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

  Widget _buildContent(
    BuildContext context, {
    required double diameter,
    required String? initials,
    required Color foreground,
    required ColorScheme scheme,
  }) {
    final fallback = Center(
      child: initials != null
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                initials,
                textAlign: TextAlign.center,
                style: _initialsStyle(context, foreground),
              ),
            )
          : PhosphorIcon(
              PhosphorIcons.user(),
              size: (diameter * 0.48).clamp(14.0, 44.0),
              color: foreground,
            ),
    );

    final provider = imageProvider;
    if (provider != null) {
      return Image(
        image: provider,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return fallback;

    return Image.network(
      url,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  Widget _buildCameraBadge(
    BuildContext context, {
    required double avatarDiameter,
    required ColorScheme scheme,
  }) {
    final onChangePhoto = this.onChangePhoto!;

    final badgeDiameter = (avatarDiameter * 0.36).clamp(16.0, 32.0);
    final iconSize = (badgeDiameter * 0.55).clamp(12.0, 18.0);
    final bg = badgeBackgroundColor ?? scheme.primary;
    final fg = badgeIconColor ?? scheme.onPrimary;

    return Semantics(
      button: true,
      label: context.l10n.commonChangeProfilePhoto,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChangePhoto,
        child: SizedBox(
          width: badgeDiameter,
          height: badgeDiameter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.surface,
                width: AppSpacing.space2,
              ),
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIcons.camera(),
                size: iconSize,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _initialsStyle(BuildContext context, Color color) {
    final base = Theme.of(context).textTheme.displayLarge ?? const TextStyle();
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.0,
    );
  }

  String _defaultSemanticsLabel(BuildContext context, String? displayName) {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return context.l10n.commonAvatar;
    return context.l10n.commonAvatarFor(name: name);
  }

  String? _normalizeInitials(String? initials) {
    final raw = initials?.trim();
    if (raw == null || raw.isEmpty) return null;

    final runes = raw.runes.take(2).toList(growable: false);
    if (runes.isEmpty) return null;
    return runes.map(String.fromCharCode).join().toUpperCase();
  }

  String? _computeInitials(String? displayName) {
    final raw = displayName?.trim();
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      final runes = parts.first.runes.take(2).toList(growable: false);
      if (runes.isEmpty) return null;
      return runes.map(String.fromCharCode).join().toUpperCase();
    }

    final first = parts.first.runes.isNotEmpty
        ? String.fromCharCode(parts.first.runes.first)
        : '';
    final last = parts.last.runes.isNotEmpty
        ? String.fromCharCode(parts.last.runes.first)
        : '';
    final result = (first + last).trim();
    if (result.isEmpty) return null;
    return result.toUpperCase();
  }
}
