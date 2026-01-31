import 'package:flutter/material.dart';

import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_policies.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/modal_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';

/// Visual style variants for modal bottom sheets.
enum AdaptiveBottomSheetStyle {
  /// Edge-to-edge sheet (standard Material bottom sheet).
  edgeToEdge,

  /// Inset, rounded "card" sheet with spacing from screen edges.
  floating,
}

/// Adaptive modal entrypoint (sheet on compact, dialog on larger widths).
///
/// Use this instead of `showModalBottomSheet` / `showDialog` directly in
/// feature code. The presentation decision is driven by [ModalPolicy] (set once
/// via `AdaptiveScope.modalPolicy`).
Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ModalPolicy? modalPolicy,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool isScrollControlled = true,
  AdaptiveBottomSheetStyle bottomSheetStyle = AdaptiveBottomSheetStyle.floating,
  bool? showDragHandle,
  bool? enableDrag,
  double dialogMaxWidth = 560,
  EdgeInsets? dialogInsetPadding,
  ShapeBorder? dialogShape,
  Color? dialogBackgroundColor,
  ShapeBorder? bottomSheetShape,
  Color? bottomSheetBackgroundColor,
  Clip clipBehavior = Clip.none,
}) {
  final layout = context.adaptiveLayout;
  final policy = modalPolicy ?? AdaptivePolicies.of(context).modalPolicy;
  final effectiveEnableDrag = enableDrag ?? barrierDismissible;

  final presentation = policy.modalPresentation(layout: layout);

  if (presentation == AdaptiveModalPresentation.bottomSheet) {
    final theme = Theme.of(context);
    final effectiveShape =
        bottomSheetShape ??
        theme.bottomSheetTheme.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.radius24)),
        );
    final effectiveBackgroundColor =
        bottomSheetBackgroundColor ??
        theme.bottomSheetTheme.modalBackgroundColor ??
        theme.bottomSheetTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerHigh;
    final effectiveShowDragHandle =
        showDragHandle ?? theme.bottomSheetTheme.showDragHandle ?? true;

    Widget buildBottomSheetBody(BuildContext modalContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effectiveShowDragHandle) _BottomSheetHandle(),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: builder(modalContext),
          ),
        ],
      );
    }

    if (bottomSheetStyle == AdaptiveBottomSheetStyle.edgeToEdge) {
      return showModalBottomSheet<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        isDismissible: barrierDismissible,
        enableDrag: effectiveEnableDrag,
        isScrollControlled: isScrollControlled,
        // We render our own handle for consistent styling.
        showDragHandle: false,
        useSafeArea: useSafeArea,
        shape: effectiveShape,
        backgroundColor: effectiveBackgroundColor,
        builder: (modalContext) {
          final viewInsets = MediaQuery.viewInsetsOf(modalContext);

          return PopScope(
            canPop: barrierDismissible,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: viewInsets.bottom),
                child: buildBottomSheetBody(modalContext),
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: barrierDismissible,
      enableDrag: effectiveEnableDrag,
      isScrollControlled: isScrollControlled,
      // We render our own handle inside the floating frame.
      showDragHandle: false,
      useSafeArea: useSafeArea,
      // Use a transparent route background, then render an inset, rounded
      // "card" inside the builder for a floating-sheet feel.
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.none,
      builder: (modalContext) {
        final viewInsets = MediaQuery.viewInsetsOf(modalContext);
        final horizontal = layout.pagePadding.horizontal / 2;
        final bottomGap = horizontal;

        return PopScope(
          canPop: barrierDismissible,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontal,
                right: horizontal,
                bottom: bottomGap + viewInsets.bottom,
              ),
              child: Material(
                color: effectiveBackgroundColor,
                shape: effectiveShape,
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                shadowColor: theme.colorScheme.shadow,
                child: buildBottomSheetBody(modalContext),
              ),
            ),
          ),
        );
      },
    );
  }

  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
    builder: (context) {
      return PopScope(
        canPop: barrierDismissible,
        child: Dialog(
          insetPadding: dialogInsetPadding ?? layout.pagePadding,
          shape: dialogShape,
          backgroundColor: dialogBackgroundColor,
          clipBehavior: clipBehavior,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogMaxWidth),
            child: builder(context),
          ),
        ),
      );
    },
  );
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space12,
        bottom: AppSpacing.space8,
      ),
      child: Container(
        width: AppSpacing.space40,
        height: AppSpacing.space4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.radiusPill),
        ),
      ),
    );
  }
}
