import 'package:flutter/widgets.dart';

import 'policies/modal_policy.dart';

/// Policy container for adaptive behaviors that are configured at the app root.
///
/// Unlike [AdaptiveSpec], these policies are **not derived** from runtime
/// constraints/capabilities; they are product decisions (governance).
///
/// Today this holds [ModalPolicy]. If more policies are added here, they must
/// remain stable and documented (treat like API).
class AdaptivePolicies extends InheritedWidget {
  const AdaptivePolicies({
    super.key,
    required this.modalPolicy,
    required super.child,
  });

  final ModalPolicy modalPolicy;

  /// Returns the nearest policies and registers a dependency.
  static AdaptivePolicies of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AdaptivePolicies>();
    assert(widget != null, 'No AdaptiveScope found in context');
    return widget!;
  }

  /// Returns the nearest policies without registering a dependency.
  static AdaptivePolicies read(BuildContext context) {
    final widget =
        context.getElementForInheritedWidgetOfExactType<AdaptivePolicies>()?.widget
            as AdaptivePolicies?;
    assert(widget != null, 'No AdaptiveScope found in context');
    return widget!;
  }

  @override
  bool updateShouldNotify(AdaptivePolicies oldWidget) {
    return modalPolicy != oldWidget.modalPolicy;
  }
}
