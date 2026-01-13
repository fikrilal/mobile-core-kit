import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/extensions/theme_extensions_utils.dart';
import '../../theme/responsive/spacing.dart';
import '../../theme/typography/components/text.dart';

part 'app_snackbar_styles.dart';
part 'top_snackbar_overlay.dart';

/// Pre-styled snackbar helpers for consistent messaging feedback.
///
/// This is the recommended API for feature code:
///
/// ```dart
/// AppSnackBar.showSuccess(context, message: 'Saved');
/// ```
class AppSnackBar {
  const AppSnackBar._();

  static final _TopSnackBarOverlayController _top =
      _TopSnackBarOverlayController();

  /// Dismisses any active top overlay snackbar.
  ///
  /// This is mainly useful when you show a top snackbar and need to dismiss it
  /// early (e.g., on navigation).
  static Future<void> dismissTop() => _top.dismiss();

  /// Returns a themed `SnackBar` for manual use (e.g., bottom placement).
  static SnackBar success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) => _buildSnackBar(
    context,
    message: message,
    tone: _AppSnackBarTone.success,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static SnackBar error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) => _buildSnackBar(
    context,
    message: message,
    tone: _AppSnackBarTone.error,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static SnackBar info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) => _buildSnackBar(
    context,
    message: message,
    tone: _AppSnackBarTone.info,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static SnackBar warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) => _buildSnackBar(
    context,
    message: message,
    tone: _AppSnackBarTone.warning,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  /// Shows a snackbar using the app theme, handling top/bottom placement.
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    AppSnackBarPosition position = AppSnackBarPosition.bottom,
  }) => _show(
    context,
    message: message,
    tone: _AppSnackBarTone.success,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
  );

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    AppSnackBarPosition position = AppSnackBarPosition.bottom,
  }) => _show(
    context,
    message: message,
    tone: _AppSnackBarTone.error,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
  );

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    AppSnackBarPosition position = AppSnackBarPosition.bottom,
  }) => _show(
    context,
    message: message,
    tone: _AppSnackBarTone.info,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
  );

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    AppSnackBarPosition position = AppSnackBarPosition.bottom,
  }) => _show(
    context,
    message: message,
    tone: _AppSnackBarTone.warning,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
  );

  static void _show(
    BuildContext context, {
    required String message,
    required _AppSnackBarTone tone,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
    required AppSnackBarPosition position,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (position == AppSnackBarPosition.top) {
      unawaited(
        _top.show(
          context,
          message: message,
          tone: tone,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      _buildSnackBar(
        context,
        message: message,
        tone: tone,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

enum AppSnackBarPosition { top, bottom }
