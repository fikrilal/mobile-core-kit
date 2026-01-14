import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef EarlyErrorPlatformHandler =
    bool Function(Object error, StackTrace stack);

abstract class EarlyErrorReporter {
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal,
  });

  Future<void> recordFlutterError(FlutterErrorDetails details, {bool fatal});
}

/// Buffers unhandled errors until the real crash reporter is ready.
///
/// This exists because we intentionally defer Firebase/Crashlytics
/// initialization until after the first Flutter frame (to reduce time spent on
/// the native splash). Without a buffer, early unhandled errors can be lost.
///
/// Typical flow:
/// - `EarlyErrorBuffer.instance.install()` in `main_*` (after
///   `WidgetsFlutterBinding.ensureInitialized()`).
/// - After Crashlytics is initialized, call
///   `EarlyErrorBuffer.instance.activate(crashlyticsReporter)`.
class EarlyErrorBuffer {
  EarlyErrorBuffer._();

  static final EarlyErrorBuffer instance = EarlyErrorBuffer._();

  static const int _maxBufferedEvents = 20;

  final Queue<_BufferedEvent> _buffer = Queue<_BufferedEvent>();
  bool _installed = false;
  EarlyErrorReporter? _reporter;

  FlutterExceptionHandler? _previousFlutterOnError;
  EarlyErrorPlatformHandler? _previousPlatformOnError;

  void install() {
    if (_installed) return;
    _installed = true;

    _previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      recordFlutterError(details, fatal: true);

      final previous = _previousFlutterOnError;
      if (previous != null && previous != FlutterError.onError) {
        try {
          previous(details);
        } catch (_) {
          // Best-effort; ignore errors in the previous handler.
        }
      }
    };

    final dispatcher = PlatformDispatcher.instance;
    _previousPlatformOnError = dispatcher.onError;
    dispatcher.onError = (error, stack) {
      recordError(
        error,
        stack,
        reason: 'PlatformDispatcher.onError',
        fatal: true,
      );

      final previous = _previousPlatformOnError;
      if (previous != null && previous != dispatcher.onError) {
        try {
          return previous(error, stack);
        } catch (_) {
          // Fall through to default behavior.
        }
      }

      // In debug/profile we prefer the default behavior so issues are visible.
      return kReleaseMode;
    };
  }

  Future<void> activate(EarlyErrorReporter reporter) async {
    if (_reporter != null) return;
    _reporter = reporter;

    // Flush existing buffered events (best-effort).
    while (_buffer.isNotEmpty) {
      final event = _buffer.removeFirst();
      try {
        await event.flushTo(reporter);
      } catch (_) {
        // Ignore failures; we don't want startup to crash because reporting failed.
      }
    }
  }

  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    final reporter = _reporter;
    if (reporter != null) {
      unawaited(
        reporter.recordError(error, stack, reason: reason, fatal: fatal),
      );
      return;
    }

    _addToBuffer(
      _BufferedNonFlutterError(error, stack, reason: reason, fatal: fatal),
    );
  }

  void recordFlutterError(FlutterErrorDetails details, {bool fatal = false}) {
    final reporter = _reporter;
    if (reporter != null) {
      unawaited(reporter.recordFlutterError(details, fatal: fatal));
      return;
    }

    _addToBuffer(_BufferedFlutterError(details, fatal: fatal));
  }

  void _addToBuffer(_BufferedEvent event) {
    if (_buffer.length >= _maxBufferedEvents) {
      _buffer.removeFirst();
    }
    _buffer.addLast(event);
  }

  @visibleForTesting
  int get pendingCount => _buffer.length;

  @visibleForTesting
  void resetForTesting() {
    _buffer.clear();
    _reporter = null;
    _installed = false;
    _previousFlutterOnError = null;
    _previousPlatformOnError = null;
  }
}

abstract class _BufferedEvent {
  Future<void> flushTo(EarlyErrorReporter reporter);
}

class _BufferedNonFlutterError implements _BufferedEvent {
  _BufferedNonFlutterError(
    this.error,
    this.stack, {
    required this.reason,
    required this.fatal,
  });

  final Object error;
  final StackTrace stack;
  final String? reason;
  final bool fatal;

  @override
  Future<void> flushTo(EarlyErrorReporter reporter) {
    return reporter.recordError(error, stack, reason: reason, fatal: fatal);
  }
}

class _BufferedFlutterError implements _BufferedEvent {
  _BufferedFlutterError(this.details, {required this.fatal});

  final FlutterErrorDetails details;
  final bool fatal;

  @override
  Future<void> flushTo(EarlyErrorReporter reporter) {
    return reporter.recordFlutterError(details, fatal: fatal);
  }
}
