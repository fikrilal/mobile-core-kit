import 'package:flutter/material.dart';

import '../adaptive_context.dart';
import '../size_classes.dart';

Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  bool isScrollControlled = true,
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
  final effectiveEnableDrag = enableDrag ?? barrierDismissible;

  if (layout.widthClass == WindowWidthClass.compact) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: barrierDismissible,
      enableDrag: effectiveEnableDrag,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      shape: bottomSheetShape,
      backgroundColor: bottomSheetBackgroundColor,
      clipBehavior: clipBehavior,
      builder: (modalContext) {
        return PopScope(
          canPop: barrierDismissible,
          child: builder(modalContext),
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
