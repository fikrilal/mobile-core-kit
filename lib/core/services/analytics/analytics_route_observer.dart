import 'package:flutter/widgets.dart';

import 'analytics_tracker.dart';

/// Navigator observer that reports screen transitions to analytics.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._tracker);

  final AnalyticsTracker _tracker;

  void _trackCurrent(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (route is! PageRoute) return;

    final screenName =
        route.settings.name ?? route.settings.arguments?.toString();
    if (screenName == null || screenName.isEmpty) {
      return;
    }

    final previousName = previousRoute is PageRoute
        ? previousRoute.settings.name ?? previousRoute.settings.arguments?.toString()
        : null;

    _tracker.trackScreen(
      screenName,
      previous: previousName,
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackCurrent(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackCurrent(newRoute, oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackCurrent(previousRoute, route);
  }
}

