import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/theme/extensions/theme_extensions_utils.dart';

import '../../adaptive/widgets/adaptive_modal.dart';
import '../../theme/tokens/spacing.dart';
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

  VoidCallback _resolveCloseAction() {
    final closeAction = onClose ?? onCancel;
    return () {
      if (!_canDismiss) return;
      closeAction();
    };
  }

  Widget _buildStandardDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirmText = isLoading && loadingLabel != null
        ? loadingLabel!
        : confirmLabel;

    return Stack(
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
                  textAlign: centerContent ? TextAlign.center : TextAlign.left,
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
                      borderColor: context.border,
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
              onPressed: _canDismiss ? _resolveCloseAction() : null,
              icon: Icon(Icons.close, size: 22, color: scheme.onSurfaceVariant),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirmText = isLoading && loadingLabel != null
        ? loadingLabel!
        : confirmLabel;
    final iconShellColor =
        iconBackgroundColor ?? scheme.errorContainer.withValues(alpha: 0.4);
    final iconInnerColor = iconAccentColor ?? scheme.errorContainer;
    final iconColor = scheme.onErrorContainer;

    return Padding(
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
                      borderColor: scheme.outline,
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
                onPressed: _canDismiss ? _resolveCloseAction() : null,
                icon: Icon(
                  Icons.close,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
        ],
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

  final radius = switch (variant) {
    AppConfirmationDialogVariant.standard => AppSpacing.space20,
    AppConfirmationDialogVariant.featured => AppSpacing.space24,
  };

  final dialogInsetPadding =
      insetPadding ??
      switch (variant) {
        AppConfirmationDialogVariant.standard => const EdgeInsets.symmetric(
          horizontal: AppSpacing.space24,
          vertical: AppSpacing.space24,
        ),
        AppConfirmationDialogVariant.featured => const EdgeInsets.symmetric(
          horizontal: AppSpacing.space24,
        ),
      };

  final theme = Theme.of(context);
  final dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );
  final bottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
  );

  return showAdaptiveModal<bool>(
    context: context,
    barrierDismissible: effectiveBarrierDismissible,
    showDragHandle: false,
    dialogInsetPadding: dialogInsetPadding,
    dialogShape: dialogShape,
    dialogBackgroundColor: theme.colorScheme.surface,
    bottomSheetShape: bottomSheetShape,
    bottomSheetBackgroundColor: theme.colorScheme.surface,
    builder: (dialogContext) => AppConfirmationDialog(
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
      onClose: onClose == null
          ? null
          : () {
              onClose();
              Navigator.of(dialogContext).pop(false);
            },
      iconBackgroundColor: iconBackgroundColor,
      iconAccentColor: iconAccentColor,
      centerContent: centerContent,
      footer: footer,
    ),
  ).then((value) {
    if (value == null && effectiveBarrierDismissible) {
      onCancel?.call();
      return false;
    }
    return value;
  });
}
