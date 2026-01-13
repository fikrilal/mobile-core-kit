import 'package:flutter/material.dart';

import '../adaptive_context.dart';
import '../size_classes.dart';
import 'adaptive_modal.dart';

Future<T?> showAdaptiveSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  double width = 360,
  Duration transitionDuration = const Duration(milliseconds: 220),
}) {
  final layout = context.adaptiveLayout;

  // Compact surfaces should avoid side sheets; fall back to the modal strategy.
  if (layout.widthClass == WindowWidthClass.compact) {
    return showAdaptiveModal<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
    );
  }

  final label = MaterialLocalizations.of(context).modalBarrierDismissLabel;

  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierDismissible ? label : null,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: width),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 12,
              child: builder(context),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

