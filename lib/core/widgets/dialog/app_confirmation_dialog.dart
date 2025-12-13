import 'package:flutter/material.dart';

import '../../theme/responsive/spacing.dart';
import '../../theme/typography/components/text.dart';
import '../button/button.dart';

enum AppConfirmationDialogVariant { standard, featured }

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
    this.loadingLabel,
    this.errorText,
    this.isConfirmEnabled = true,
    this.isCancelEnabled = true,
    this.variant = AppConfirmationDialogVariant.standard,
    this.icon,
    this.showCloseButton = false,
    this.onClose,
    this.iconBackgroundColor,
    this.iconAccentColor,
    this.centerContent = false,
    this.footer,
    this.insetPadding,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;
  final String? loadingLabel;
  final String? errorText;
  final bool isConfirmEnabled;
  final bool isCancelEnabled;
  final AppConfirmationDialogVariant variant;
  final Widget? icon;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Color? iconBackgroundColor;
  final Color? iconAccentColor;
  final bool centerContent;
  final Widget? footer;
  final EdgeInsets? insetPadding;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppConfirmationDialogVariant.standard:
        return _buildStandardDialog(context);
      case AppConfirmationDialogVariant.featured:
        return _buildFeaturedDialog(context);
    }
  }

  bool get _canDismiss => isCancelEnabled && !isLoading;

  VoidCallback _resolveCloseAction(BuildContext context) {
    final closeAction = onClose ?? onCancel;
    return () {
      if (!_canDismiss) return;
      closeAction();
      Navigator.of(context).pop(false);
    };
  }

  Dialog _buildStandardDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirmText = isLoading && loadingLabel != null
        ? loadingLabel!
        : confirmLabel;

    return Dialog(
      insetPadding:
          insetPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space24,
          ),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerContent
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Align(
                    alignment: centerContent
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: IconTheme(
                      data: const IconThemeData(size: 32),
                      child: icon!,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                ],
                AppText.titleMedium(
                  title,
                  color: scheme.onSurface,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  textAlign: centerContent ? TextAlign.center : TextAlign.left,
                ),
                const SizedBox(height: AppSpacing.space8),
                AppText.bodyMedium(
                  message,
                  color: scheme.onSurfaceVariant,
                  textAlign: centerContent ? TextAlign.center : TextAlign.left,
                  maxLines: 8,
                ),
                if (errorText != null && errorText!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space12),
                  AppText.bodySmall(
                    errorText!,
                    color: scheme.error,
                    textAlign:
                        centerContent ? TextAlign.center : TextAlign.left,
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.space16),
                  footer!,
                ],
                const SizedBox(height: AppSpacing.space24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outline(
                        text: cancelLabel,
                        size: ButtonSize.medium,
                        onPressed: isCancelEnabled ? onCancel : null,
                        isDisabled: !isCancelEnabled,
                        borderColor: scheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: AppButton.primary(
                        text: confirmText,
                        size: ButtonSize.medium,
                        isLoading: isLoading,
                        loadingText: loadingLabel,
                        onPressed: isConfirmEnabled && !isLoading
                            ? onConfirm
                            : null,
                        isDisabled: !isConfirmEnabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showCloseButton)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: _canDismiss ? _resolveCloseAction(context) : null,
                icon: Icon(
                  Icons.close,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Dialog _buildFeaturedDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirmText = isLoading && loadingLabel != null
        ? loadingLabel!
        : confirmLabel;
    final iconShellColor =
        iconBackgroundColor ?? scheme.errorContainer.withValues(alpha: 0.4);
    final iconInnerColor = iconAccentColor ?? scheme.errorContainer;
    final iconColor = scheme.onErrorContainer;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space20,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: iconShellColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.space8),
                      decoration: BoxDecoration(
                        color: iconInnerColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: IconTheme(
                        data: IconThemeData(color: iconColor, size: 36),
                        child: icon!,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space20),
                ],
                AppText.titleLarge(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  color: scheme.onSurface,
                ),
                const SizedBox(height: AppSpacing.space8),
                AppText.bodyMedium(
                  message,
                  textAlign: TextAlign.center,
                  color: scheme.onSurfaceVariant,
                  maxLines: 10,
                ),
                if (errorText != null && errorText!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space12),
                  AppText.bodySmall(
                    errorText!,
                    textAlign: TextAlign.center,
                    color: scheme.error,
                  ),
                ],
                const SizedBox(height: AppSpacing.space24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outline(
                        text: cancelLabel,
                        size: ButtonSize.medium,
                        onPressed: _canDismiss ? onCancel : null,
                        isDisabled: !_canDismiss,
                        borderColor: scheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: AppButton.danger(
                        text: confirmText,
                        size: ButtonSize.medium,
                        isLoading: isLoading,
                        loadingText: loadingLabel,
                        onPressed: isConfirmEnabled && !isLoading
                            ? onConfirm
                            : null,
                        isDisabled: !isConfirmEnabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showCloseButton)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: _canDismiss ? _resolveCloseAction(context) : null,
                  icon: Icon(
                    Icons.close,
                    size: 22,
                    color: scheme.onSurfaceVariant,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isLoading = false,
  String? loadingLabel,
  String? errorText,
  bool isConfirmEnabled = true,
  bool isCancelEnabled = true,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  AppConfirmationDialogVariant variant = AppConfirmationDialogVariant.standard,
  Widget? icon,
  bool showCloseButton = false,
  VoidCallback? onClose,
  Color? iconBackgroundColor,
  Color? iconAccentColor,
  bool centerContent = false,
  Widget? footer,
  EdgeInsets? insetPadding,
  bool? barrierDismissible,
}) {
  final canDismiss = isCancelEnabled && !isLoading;
  final effectiveBarrierDismissible = barrierDismissible ?? canDismiss;

  return showDialog<bool>(
    context: context,
    barrierDismissible: effectiveBarrierDismissible,
    builder: (dialogContext) => PopScope(
      canPop: effectiveBarrierDismissible,
      child: AppConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isLoading: isLoading,
        loadingLabel: loadingLabel,
        errorText: errorText,
        isConfirmEnabled: isConfirmEnabled,
        isCancelEnabled: isCancelEnabled,
        onConfirm: () {
          onConfirm?.call();
          Navigator.of(dialogContext).pop(true);
        },
        onCancel: () {
          onCancel?.call();
          Navigator.of(dialogContext).pop(false);
        },
        variant: variant,
        icon: icon,
        showCloseButton: showCloseButton,
        onClose: onClose,
        iconBackgroundColor: iconBackgroundColor,
        iconAccentColor: iconAccentColor,
        centerContent: centerContent,
        footer: footer,
        insetPadding: insetPadding,
      ),
    ),
  ).then((value) {
    if (value == null && effectiveBarrierDismissible) {
      onCancel?.call();
      return false;
    }
    return value;
  });
}
