import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../services/deep_link/pending_deep_link_controller.dart';

/// Clears any pending deep link intent when the user navigates back (cancels).
///
/// This is used on prerequisite flows like onboarding/auth so a user-initiated
/// cancel does not unexpectedly auto-resume a previously captured deep link.
class PendingDeepLinkCancelOnPop extends StatefulWidget {
  const PendingDeepLinkCancelOnPop({
    super.key,
    required this.deepLinks,
    required this.child,
    this.clearWhenCanPop = true,
  });

  final PendingDeepLinkController deepLinks;
  final Widget child;

  /// When false, only clears when the route cannot pop (i.e. would exit).
  ///
  /// Useful for secondary auth screens that may pop back to the primary login
  /// screen without counting as an explicit cancel.
  final bool clearWhenCanPop;

  @override
  State<PendingDeepLinkCancelOnPop> createState() =>
      _PendingDeepLinkCancelOnPopState();
}

class _PendingDeepLinkCancelOnPopState
    extends State<PendingDeepLinkCancelOnPop> {
  bool _isHandlingPop = false;

  Future<void> _handleCancel() async {
    if (_isHandlingPop) return;
    _isHandlingPop = true;

    await widget.deepLinks.clear(reason: 'cancel');

    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    unawaited(SystemNavigator.pop());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.deepLinks,
      builder: (context, _) {
        final canNavigatorPop = Navigator.of(context).canPop();
        final shouldClearOnPop =
            widget.deepLinks.hasPending &&
            (widget.clearWhenCanPop || !canNavigatorPop);

        return PopScope<Object?>(
          canPop: !shouldClearOnPop,
          onPopInvokedWithResult: (didPop, _) {
            if (!shouldClearOnPop || didPop) return;
            unawaited(_handleCancel());
          },
          child: widget.child,
        );
      },
    );
  }
}
