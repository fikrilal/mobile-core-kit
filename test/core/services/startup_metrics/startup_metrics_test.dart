import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_events.dart';
import 'package:mobile_core_kit/core/services/startup_metrics/startup_metrics.dart';

void main() {
  group('StartupMetrics', () {
    setUp(() {
      StartupMetrics.instance.reset();
    });

    test('buildAnalyticsParams returns computed durations', () {
      final metrics = StartupMetrics.instance..start();

      metrics
        ..setMarkForTesting(
          StartupMilestone.flutterBindingInitialized,
          const Duration(milliseconds: 10),
        )
        ..setMarkForTesting(
          StartupMilestone.firebaseInitialized,
          const Duration(milliseconds: 60),
        )
        ..setMarkForTesting(
          StartupMilestone.crashlyticsConfigured,
          const Duration(milliseconds: 80),
        )
        ..setMarkForTesting(
          StartupMilestone.intlInitialized,
          const Duration(milliseconds: 120),
        )
        ..setMarkForTesting(
          StartupMilestone.runAppCalled,
          const Duration(milliseconds: 100),
        )
        ..setMarkForTesting(
          StartupMilestone.firstFrame,
          const Duration(milliseconds: 180),
        )
        ..setMarkForTesting(
          StartupMilestone.bootstrapStart,
          const Duration(milliseconds: 200),
        )
        ..setMarkForTesting(
          StartupMilestone.startupReady,
          const Duration(milliseconds: 350),
        )
        ..setMarkForTesting(
          StartupMilestone.bootstrapComplete,
          const Duration(milliseconds: 450),
        )
        ..setFirstFrameTimingsForTesting(
          build: const Duration(milliseconds: 8),
          raster: const Duration(milliseconds: 12),
        );

      final params = metrics.buildAnalyticsParams();

      expect(params[AnalyticsParams.startupPreRunAppMs], 100);
      expect(params[AnalyticsParams.startupTtffMs], 180);
      expect(params[AnalyticsParams.startupReadyMs], 350);
      expect(params[AnalyticsParams.startupBootstrapMs], 250);

      expect(params[AnalyticsParams.startupFirebaseInitMs], 50);
      expect(params[AnalyticsParams.startupCrashlyticsMs], 20);
      expect(params[AnalyticsParams.startupIntlMs], 40);

      expect(params[AnalyticsParams.startupFirstFrameBuildMs], 8);
      expect(params[AnalyticsParams.startupFirstFrameRasterMs], 12);
    });

    test('mark keeps the first recorded value', () {
      final metrics = StartupMetrics.instance..start();

      metrics.setMarkForTesting(
        StartupMilestone.runAppCalled,
        const Duration(milliseconds: 123),
      );

      final recorded = metrics.mark(StartupMilestone.runAppCalled);
      expect(recorded, const Duration(milliseconds: 123));
    });
  });
}

