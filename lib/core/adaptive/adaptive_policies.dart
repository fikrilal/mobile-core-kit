import 'package:flutter/widgets.dart';

import 'policies/modal_policy.dart';

class AdaptivePolicies extends InheritedWidget {
  const AdaptivePolicies({
    super.key,
    required this.modalPolicy,
    required super.child,
  });

  final ModalPolicy modalPolicy;

  static AdaptivePolicies of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AdaptivePolicies>();
    assert(widget != null, 'No AdaptiveScope found in context');
    return widget!;
  }

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

