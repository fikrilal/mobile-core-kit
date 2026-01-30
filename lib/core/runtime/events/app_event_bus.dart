import 'dart:async';
import 'package:mobile_core_kit/core/runtime/events/app_event.dart';

/// Simple application-wide event bus using a broadcast stream.
class AppEventBus {
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  void publish(AppEvent event) => _controller.add(event);

  Stream<AppEvent> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
