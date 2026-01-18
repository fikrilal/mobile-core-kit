import 'package:flutter/material.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_policies.dart';
import 'package:mobile_core_kit/core/adaptive/policies/modal_policy.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/adaptive_modal.dart';

/// Adaptive side sheet entrypoint (side sheet on medium+, fallback on compact).
///
/// On compact widths, this falls back to [showAdaptiveModal] using the same
/// [ModalPolicy] decision logic.
Future<T?> showAdaptiveSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ModalPolicy? modalPolicy,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  double width = 360,
  Duration transitionDuration = const Duration(milliseconds: 220),
}) {
  final layout = context.adaptiveLayout;
  final policy = modalPolicy ?? AdaptivePolicies.of(context).modalPolicy;

  final presentation = policy.sideSheetPresentation(layout: layout);

  // Compact surfaces should avoid side sheets; fall back to the modal strategy.
  if (presentation == AdaptiveSideSheetPresentation.modalFallback) {
    return showAdaptiveModal<T>(
      context: context,
      builder: builder,
      modalPolicy: policy,
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
