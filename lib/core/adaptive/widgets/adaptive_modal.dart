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
  double dialogMaxWidth = 560,
  EdgeInsets? dialogInsetPadding,
}) {
  final layout = context.adaptiveLayout;

  if (layout.widthClass == WindowWidthClass.compact) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: barrierDismissible,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      builder: builder,
    );
  }

  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
    builder: (context) {
      return Dialog(
        insetPadding: dialogInsetPadding ?? layout.pagePadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          child: builder(context),
        ),
      );
    },
  );
}
