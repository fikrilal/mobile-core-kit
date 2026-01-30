import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple navigation service to allow navigation without BuildContext
class NavigationService {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void go(String location) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      GoRouter.of(ctx).go(location);
    }
  }

  @Deprecated('Use AppSnackBar for transient UI messages.')
  void showSnackBar(SnackBar snackBar) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
