import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/events/app_event.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';

/// Listens to global [AppEvent]s and surfaces cross-cutting UI side-effects.
///
/// Keeps the presentation layer reactive to domain events without coupling
/// feature widgets directly to infrastructure concerns.
class AppEventListener extends StatefulWidget {
  const AppEventListener({
    super.key,
    required this.eventBus,
    required this.child,
  });

  final AppEventBus eventBus;
  final Widget child;

  @override
  State<AppEventListener> createState() => _AppEventListenerState();
}

class _AppEventListenerState extends State<AppEventListener> {
  StreamSubscription<AppEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.eventBus.stream.listen(_handleEvent);
  }

  void _handleEvent(AppEvent event) {
    // Intentionally empty: wire global UI side-effects here when needed.
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
