import 'package:flutter/material.dart';

import '../../theme/extensions/theme_extensions_utils.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/typography/components/text.dart';
import '../common/app_haptic_feedback.dart';
import '../tappable/app_tappable.dart';
import '../tappable/tappable_style.dart';

/// A reusable list tile component with leading, title, subtitle, and trailing.
///
/// Uses [AppTappable] for smooth touch feedback and integrates with the
/// design system typography and spacing.
///
/// Example usage:
/// ```dart
/// AppListTile(
///   leading: AppIconBadge(icon: Icon(Icons.settings)),
///   title: 'Security & Privacy',
///   subtitle: 'Manage your security and privacy settings',
///   onTap: () => Navigator.push(...),
/// )
/// ```
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.showChevron = true,
    this.chevronIcon,
    this.padding,
    this.tappableStyle = TappableStyle.standard,
    this.borderRadius,
    this.backgroundColor,
    this.hapticFeedback,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 2,
    this.semanticLabel,
  });

  /// The primary text of the tile.
  final String title;

  /// Optional secondary text below the title.
  final String? subtitle;

  /// Widget displayed before the title (typically an icon or avatar).
  final Widget? leading;

  /// Widget displayed after the title (overrides chevron if provided).
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Whether to show a chevron/arrow on the right (default: true).
  /// Ignored if [trailing] is provided.
  final bool showChevron;

  /// Custom chevron icon (defaults to caretRight).
  final Widget? chevronIcon;

  /// Padding inside the tile.
  final EdgeInsetsGeometry? padding;

  /// Touch feedback style.
  final TappableStyle tappableStyle;

  /// Border radius for the tappable area.
  final BorderRadius? borderRadius;

  /// Background color of the tile.
  final Color? backgroundColor;

  /// Haptic feedback on tap.
  final AppHapticFeedback? hapticFeedback;

  /// Maximum lines for the title.
  final int titleMaxLines;

  /// Maximum lines for the subtitle.
  final int subtitleMaxLines;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ??
        const EdgeInsets.symmetric(
          vertical: AppSpacing.space12,
          horizontal: AppSpacing.space4,
        );
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    // Determine trailing widget
    Widget? effectiveTrailing = trailing;
    if (effectiveTrailing == null && showChevron && onTap != null) {
      effectiveTrailing =
          chevronIcon ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.textSecondary,
          );
    }

    return AppTappable(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      style: tappableStyle,
      padding: effectivePadding,
      borderRadius: effectiveBorderRadius,
      backgroundColor: backgroundColor,
      hapticFeedback: hapticFeedback,
      enabled: enabled,
      semanticLabel: semanticLabel ?? title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.space16),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyLarge(
                  title,
                  maxLines: titleMaxLines,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.space2),
                  AppText.bodyMedium(
                    subtitle!,
                    maxLines: subtitleMaxLines,
                    color: context.textSecondary,
                  ),
                ],
              ],
            ),
          ),

          // Trailing widget
          if (effectiveTrailing != null) ...[
            const SizedBox(width: AppSpacing.space12),
            effectiveTrailing,
          ],
        ],
      ),
    );
  }
}
