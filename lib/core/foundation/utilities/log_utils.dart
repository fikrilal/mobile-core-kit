import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';

/// Centralized logging utility for the app.
///
/// This class provides a unified logging mechanism across all environments,
/// with optional integration to Firebase Crashlytics for error reporting.
///
/// ---
/// ### Log Levels:
/// - `verbose`: Low-priority internal details
/// - `debug`: Debugging messages for logic and flow
/// - `info`: App lifecycle or general informational events
/// - `warning`: Recoverable issues or soft failures
/// - `error`: Exceptions or runtime failures
/// - `wtf`: Critical "this should never happen" type failures
///
/// ---
/// ### Crashlytics Reporting:
/// - Crashlytics will only receive logs if `report: true` is set AND `level >= error`
/// - Useful for selectively reporting only important failures in production
///
/// ---
/// ### Tagged Logging:
/// - Use the `name:` parameter to tag logs with your class or component name
/// - Default tag is the current environment name (e.g., `DEV`, `PROD`)
///
/// ---
/// ### Examples:
/// ```dart
/// Log.debug("Loaded AuthController", name: "AuthController");
/// Log.error("Login failed", error, stackTrace);
/// Log.error("API crashed", error, stackTrace, report: true, name: "LoginService");
/// Log.wtf("Critical: state unreachable", exception, stackTrace, true, "SessionManager");
/// ```

class Log {
  static const int _verbose = 0;
  static const int _debug = 1;
  static const int _info = 2;
  static const int _warning = 3;
  static const int _error = 4;
  static const int _wtf = 5;

  static const Map<int, String> _levelNames = {
    _verbose: 'VERBOSE',
    _debug: 'DEBUG',
    _info: 'INFO',
    _warning: 'WARNING',
    _error: 'ERROR',
    _wtf: 'CRITICAL',
  };
  static bool _crashlyticsReportingEnabled = true;

  @visibleForTesting
  static void enableCrashlyticsReporting(bool enabled) {
    _crashlyticsReportingEnabled = enabled;
  }

  static void debug(dynamic message, {String? name}) =>
      _log(message, _debug, name: name);

  static void info(dynamic message, {String? name}) =>
      _log(message, _info, name: name);

  static void warning(dynamic message, {String? name}) =>
      _log(message, _warning, name: name);

  static void verbose(dynamic message, {String? name}) =>
      _log(message, _verbose, name: name);

  static void error(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
    bool report = false,
    String? name,
  ]) => _log(
    message,
    _error,
    error: error,
    stackTrace: stackTrace,
    report: report,
    name: name,
  );

  static void wtf(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
    bool report = false,
    String? name,
  ]) => _log(
    message,
    _wtf,
    error: error,
    stackTrace: stackTrace,
    report: report,
    name: name,
  );

  static void _log(
    dynamic message,
    int level, {
    dynamic error,
    StackTrace? stackTrace,
    bool report = false,
    String? name,
  }) {
    final bool shouldLog = BuildConfig.logEnabled;
    final String levelName = _levelNames[level] ?? 'UNKNOWN';
    final String logMessage = '[$levelName] $message';
    final String logTag = name ?? BuildConfig.env.name.toUpperCase();

    if (shouldLog) {
      developer.log(
        logMessage,
        name: logTag,
        error: error,
        stackTrace: stackTrace,
      );

      if (level >= _error && kDebugMode) {
        developer.log('⚠️ $logMessage', name: logTag);
        if (error != null) developer.log('Error: $error', name: logTag);
        if (stackTrace != null) {
          developer.log('Stack trace:\n$stackTrace', name: logTag);
        }
      }
    }

    if (report && level >= _error && _crashlyticsReportingEnabled) {
      try {
        final crashlytics = FirebaseCrashlytics.instance;
        crashlytics.log("[$logTag] $logMessage");
        if (error != null && stackTrace != null) {
          crashlytics.recordError(error, stackTrace);
        }
      } catch (e, st) {
        developer.log(
          '[CRASHLYTICS_DISABLED] Failed to report log: $logMessage',
          name: logTag,
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}
