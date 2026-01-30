part of 'app_snackbar.dart';

enum _AppSnackBarTone { success, error, info, warning }

class _AppSnackBarColors {
  const _AppSnackBarColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

SnackBar _buildSnackBar(
  BuildContext context, {
  required String message,
  required _AppSnackBarTone tone,
  required Duration duration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final colors = _resolveColors(context, tone);
  final media = _mediaQueryData(context);

  final bottomInset = [
    media.viewPadding.bottom,
    media.padding.bottom,
    media.systemGestureInsets.bottom,
  ].reduce((a, b) => a > b ? a : b);

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: colors.background,
    duration: duration,
    margin: EdgeInsets.fromLTRB(
      AppSpacing.space16,
      0,
      AppSpacing.space16,
      bottomInset + AppSpacing.space16,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.space16,
      vertical: AppSpacing.space12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.space12),
    ),
    content: AppText.bodyMedium(
      message,
      color: colors.foreground,
      fontWeight: FontWeight.w600,
    ),
    action: (actionLabel != null && onAction != null)
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction,
            textColor: colors.foreground,
          )
        : null,
  );
}

_AppSnackBarColors _resolveColors(BuildContext context, _AppSnackBarTone tone) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (tone) {
    case _AppSnackBarTone.success:
      final semantic = context.semanticColors;
      return _AppSnackBarColors(
        background: semantic.successContainer,
        foreground: semantic.onSuccessContainer,
      );
    case _AppSnackBarTone.error:
      return _AppSnackBarColors(
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      );
    case _AppSnackBarTone.info:
      final semantic = context.semanticColors;
      return _AppSnackBarColors(
        background: semantic.infoContainer,
        foreground: semantic.onInfoContainer,
      );
    case _AppSnackBarTone.warning:
      final semantic = context.semanticColors;
      return _AppSnackBarColors(
        background: semantic.warningContainer,
        foreground: semantic.onWarningContainer,
      );
  }
}

MediaQueryData _mediaQueryData(BuildContext context) =>
    MediaQueryData.fromView(View.of(context));
