import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/early_errors/early_error_buffer.dart';

class _FakeReporter implements EarlyErrorReporter {
  final List<_RecordedError> errors = [];
  final List<_RecordedFlutterError> flutterErrors = [];

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    errors.add(
      _RecordedError(error: error, stack: stack, reason: reason, fatal: fatal),
    );
    return Future.value();
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) {
    flutterErrors.add(_RecordedFlutterError(details: details, fatal: fatal));
    return Future.value();
  }
}

class _RecordedError {
  const _RecordedError({
    required this.error,
    required this.stack,
    required this.reason,
    required this.fatal,
  });

  final Object error;
  final StackTrace stack;
  final String? reason;
  final bool fatal;
}

class _RecordedFlutterError {
  const _RecordedFlutterError({required this.details, required this.fatal});

  final FlutterErrorDetails details;
  final bool fatal;
}

void main() {
  group('EarlyErrorBuffer', () {
    setUp(() {
      EarlyErrorBuffer.instance.resetForTesting();
    });

    test('buffers errors until activated then flushes', () async {
      final buffer = EarlyErrorBuffer.instance;

      buffer.recordError(
        StateError('zone'),
        StackTrace.current,
        reason: 'Uncaught zone error',
        fatal: true,
      );

      buffer.recordFlutterError(
        FlutterErrorDetails(
          exception: Exception('flutter'),
          stack: StackTrace.current,
          context: ErrorDescription('during build'),
        ),
        fatal: true,
      );

      expect(buffer.pendingCount, 2);

      final reporter = _FakeReporter();
      await buffer.activate(reporter);

      expect(buffer.pendingCount, 0);
      expect(reporter.errors, hasLength(1));
      expect(reporter.flutterErrors, hasLength(1));

      // After activation, new errors should be forwarded (not buffered).
      buffer.recordError(Exception('after'), StackTrace.current);
      expect(buffer.pendingCount, 0);
      expect(reporter.errors, hasLength(2));
    });

    test('keeps only the latest N buffered events', () async {
      final buffer = EarlyErrorBuffer.instance;

      for (var i = 0; i < 25; i++) {
        buffer.recordError(StateError('e$i'), StackTrace.current);
      }

      expect(buffer.pendingCount, 20);

      final reporter = _FakeReporter();
      await buffer.activate(reporter);

      expect(reporter.errors, hasLength(20));
      expect((reporter.errors.first.error as StateError).message, 'e5');
      expect((reporter.errors.last.error as StateError).message, 'e24');
    });
  });
}
