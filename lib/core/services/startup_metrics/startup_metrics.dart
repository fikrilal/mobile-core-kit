import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../utilities/log_utils.dart';
import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';

enum StartupMilestone {
  dartMainStart,
  flutterBindingInitialized,
  firebaseInitialized,
  crashlyticsConfigured,
  intlInitialized,
  diRegistered,
  runAppCalled,
  firstFrame,
  firstFrameTimingsCaptured,
  bootstrapStart,
  startupReady,
  bootstrapComplete,
}

extension on StartupMilestone {
  String get label => switch (this) {
    StartupMilestone.dartMainStart => 'main',
    StartupMilestone.flutterBindingInitialized => 'binding',
    StartupMilestone.firebaseInitialized => 'firebase',
    StartupMilestone.crashlyticsConfigured => 'crashlytics',
    StartupMilestone.intlInitialized => 'intl',
    StartupMilestone.diRegistered => 'di',
    StartupMilestone.runAppCalled => 'run_app',
    StartupMilestone.firstFrame => 'first_frame',
    StartupMilestone.firstFrameTimingsCaptured => 'first_frame_timings',
    StartupMilestone.bootstrapStart => 'bootstrap_start',
    StartupMilestone.startupReady => 'startup_ready',
    StartupMilestone.bootstrapComplete => 'bootstrap_complete',
  };
}

/// Lightweight startup instrumentation (TTFF + gating readiness).
///
/// This is intentionally best-effort:
/// - If a milestone is marked multiple times, only the first timestamp is kept.
/// - If frame timings are unavailable, reporting falls back to milestone times.
class StartupMetrics {
  StartupMetrics._();

  static final StartupMetrics instance = StartupMetrics._();

  final Stopwatch _stopwatch = Stopwatch();
  final Map<StartupMilestone, Duration> _marks = <StartupMilestone, Duration>{};

  bool _started = false;
  bool _reportedToAnalytics = false;

  Duration? _firstFrameBuild;
  Duration? _firstFrameRaster;

  bool _timingsListenerAttached = false;
  bool _timingsCaptured = false;
  TimingsCallback? _timingsCallback;

  void start() {
    if (_started) return;
    _started = true;
    _stopwatch.start();
    _marks[StartupMilestone.dartMainStart] = Duration.zero;
  }

  Duration mark(StartupMilestone milestone) {
    if (!_started) start();
    return _marks.putIfAbsent(milestone, () => _stopwatch.elapsed);
  }

  Duration? milestone(StartupMilestone milestone) => _marks[milestone];

  void attachFirstFrameTimingsListener() {
    if (_timingsListenerAttached) return;
    _timingsListenerAttached = true;

    void callback(List<FrameTiming> timings) {
      if (_timingsCaptured) return;
      if (timings.isEmpty) return;

      final first = timings.first;
      _firstFrameBuild = first.buildDuration;
      _firstFrameRaster = first.rasterDuration;
      _timingsCaptured = true;
      mark(StartupMilestone.firstFrameTimingsCaptured);

      try {
        SchedulerBinding.instance.removeTimingsCallback(callback);
      } catch (e, st) {
        Log.error('Failed to remove frame timings callback', e, st, false, 'StartupMetrics');
      } finally {
        _timingsCallback = null;
      }
    }

    _timingsCallback = callback;

    try {
      SchedulerBinding.instance.addTimingsCallback(callback);
    } catch (e, st) {
      Log.error('Failed to attach frame timings callback', e, st, false, 'StartupMetrics');
      _timingsCallback = null;
    }
  }

  void logSummary() {
    final preRunAppMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.runAppCalled,
    );
    final ttffMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.firstFrame,
    );
    final readyMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.startupReady,
    );
    final bootstrapMs = _msBetween(
      StartupMilestone.bootstrapStart,
      StartupMilestone.bootstrapComplete,
    );

    Log.info(
      'Startup metrics: preRunApp=${_fmtMs(preRunAppMs)} ttff=${_fmtMs(ttffMs)} '
      'ready=${_fmtMs(readyMs)} bootstrap=${_fmtMs(bootstrapMs)} '
      'firstFrame(build=${_fmtMs(_firstFrameBuild?.inMilliseconds)} '
      'raster=${_fmtMs(_firstFrameRaster?.inMilliseconds)})',
      name: 'StartupMetrics',
    );

    if (kDebugMode) {
      final entries =
          _marks.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
      final pretty = entries
          .map((e) => '${e.key.label}=${e.value.inMilliseconds}ms')
          .join(' ');
      Log.debug('Milestones: $pretty', name: 'StartupMetrics');
    }
  }

  Future<void> reportToAnalytics(IAnalyticsService analytics) async {
    if (_reportedToAnalytics) return;

    final params = buildAnalyticsParams();
    if (params.isEmpty) return;

    _reportedToAnalytics = true;
    try {
      await analytics.logEvent(AnalyticsEvents.startupMetrics, parameters: params);
    } catch (e, st) {
      // Allow retries on future app starts if the analytics stack wasn't ready.
      _reportedToAnalytics = false;
      Log.error('Failed to report startup metrics', e, st, false, 'StartupMetrics');
    }
  }

  Map<String, Object?> buildAnalyticsParams() {
    final params = <String, Object?>{};

    final preRunAppMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.runAppCalled,
    );
    final ttffMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.firstFrame,
    );
    final readyMs = _msBetween(
      StartupMilestone.dartMainStart,
      StartupMilestone.startupReady,
    );
    final bootstrapMs = _msBetween(
      StartupMilestone.bootstrapStart,
      StartupMilestone.bootstrapComplete,
    );

    final firebaseInitMs = _msBetween(
      StartupMilestone.flutterBindingInitialized,
      StartupMilestone.firebaseInitialized,
    );
    final crashlyticsMs = _msBetween(
      StartupMilestone.firebaseInitialized,
      StartupMilestone.crashlyticsConfigured,
    );
    final intlMs = _msBetween(
      StartupMilestone.crashlyticsConfigured,
      StartupMilestone.intlInitialized,
    );

    if (preRunAppMs != null) {
      params[AnalyticsParams.startupPreRunAppMs] = preRunAppMs;
    }
    if (ttffMs != null) params[AnalyticsParams.startupTtffMs] = ttffMs;
    if (readyMs != null) params[AnalyticsParams.startupReadyMs] = readyMs;
    if (bootstrapMs != null) params[AnalyticsParams.startupBootstrapMs] = bootstrapMs;

    if (firebaseInitMs != null) {
      params[AnalyticsParams.startupFirebaseInitMs] = firebaseInitMs;
    }
    if (crashlyticsMs != null) {
      params[AnalyticsParams.startupCrashlyticsMs] = crashlyticsMs;
    }
    if (intlMs != null) params[AnalyticsParams.startupIntlMs] = intlMs;

    final buildMs = _firstFrameBuild?.inMilliseconds;
    if (buildMs != null) {
      params[AnalyticsParams.startupFirstFrameBuildMs] = buildMs;
    }
    final rasterMs = _firstFrameRaster?.inMilliseconds;
    if (rasterMs != null) {
      params[AnalyticsParams.startupFirstFrameRasterMs] = rasterMs;
    }

    // Always keep the payload clean for analytics providers.
    params.removeWhere((_, value) => value == null);
    return params;
  }

  int? _msBetween(StartupMilestone start, StartupMilestone end) {
    final s = _marks[start]?.inMilliseconds;
    final e = _marks[end]?.inMilliseconds;
    if (s == null || e == null) return null;
    return e - s;
  }

  static String _fmtMs(int? ms) => ms == null ? 'n/a' : '${ms}ms';

  @visibleForTesting
  void reset() {
    final cb = _timingsCallback;
    if (cb != null) {
      try {
        SchedulerBinding.instance.removeTimingsCallback(cb);
      } catch (_) {
        // Best-effort cleanup for tests; ignore.
      }
    }
    _timingsCallback = null;
    _timingsListenerAttached = false;
    _timingsCaptured = false;

    _stopwatch
      ..stop()
      ..reset();
    _started = false;
    _reportedToAnalytics = false;
    _marks.clear();
    _firstFrameBuild = null;
    _firstFrameRaster = null;
  }

  @visibleForTesting
  void setMarkForTesting(StartupMilestone milestone, Duration value) {
    _marks[milestone] = value;
  }

  @visibleForTesting
  void setFirstFrameTimingsForTesting({
    Duration? build,
    Duration? raster,
  }) {
    _firstFrameBuild = build;
    _firstFrameRaster = raster;
  }
}

