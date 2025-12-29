import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'early_error_buffer.dart';

/// Reports buffered early errors to Firebase Crashlytics.
///
/// Note: We intentionally avoid `recordFlutterError` here because it calls
/// `FlutterError.presentError` again (which can duplicate console output). We
/// instead map Flutter errors to `recordError(..., printDetails: false)`.
class CrashlyticsErrorReporter implements EarlyErrorReporter {
  CrashlyticsErrorReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      error,
      stack,
      reason: reason,
      printDetails: false,
      fatal: fatal,
    );
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) {
    final information = details.informationCollector?.call() ?? const [];

    return _crashlytics.recordError(
      details.exceptionAsString(),
      details.stack,
      reason: details.context
          ?.toStringDeep(minLevel: DiagnosticLevel.info)
          .trim(),
      information: information,
      printDetails: false,
      fatal: fatal,
    );
  }
}

