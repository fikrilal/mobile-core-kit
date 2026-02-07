import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/di/bootstrap/locator_bootstrap_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocatorBootstrapPipeline', () {
    test('runs register and stages once for concurrent callers', () async {
      final locator = GetIt.asNewInstance();
      addTearDown(locator.reset);

      var registerCount = 0;
      final order = <String>[];

      final pipeline = LocatorBootstrapPipeline(
        locator: locator,
        registerLocator: () {
          registerCount += 1;
          order.add('register');
        },
        runStartupCriticalStage: (_) async {
          order.add('startup');
          await Future<void>.delayed(const Duration(milliseconds: 10));
        },
        runPlatformHeavyStage: () async => order.add('platform'),
        runBackgroundBestEffortStage: (_) async => order.add('background'),
        reportStartupMetrics: (_) async {},
      );

      final first = pipeline.bootstrap();
      final second = pipeline.bootstrap();

      await Future.wait([first, second]);

      expect(registerCount, 1);
      expect(order, ['register', 'startup', 'platform', 'background']);
    });

    test('continues executing stages when one stage throws', () async {
      final locator = GetIt.asNewInstance();
      addTearDown(locator.reset);

      final order = <String>[];

      final pipeline = LocatorBootstrapPipeline(
        locator: locator,
        registerLocator: () => order.add('register'),
        runStartupCriticalStage: (_) async {
          order.add('startup');
          throw StateError('startup failed');
        },
        runPlatformHeavyStage: () async => order.add('platform'),
        runBackgroundBestEffortStage: (_) async => order.add('background'),
        reportStartupMetrics: (_) async {},
      );

      await pipeline.bootstrap();

      expect(order, ['register', 'startup', 'platform', 'background']);
    });

    test('reset clears single-flight state and allows rerun', () async {
      final locator = GetIt.asNewInstance();
      addTearDown(locator.reset);

      var registerCount = 0;
      var stageCount = 0;

      final pipeline = LocatorBootstrapPipeline(
        locator: locator,
        registerLocator: () => registerCount += 1,
        runStartupCriticalStage: (_) async => stageCount += 1,
        runPlatformHeavyStage: () async => stageCount += 1,
        runBackgroundBestEffortStage: (_) async => stageCount += 1,
        reportStartupMetrics: (_) async {},
      );

      await pipeline.bootstrap();
      await pipeline.bootstrap();

      expect(registerCount, 1);
      expect(stageCount, 3);

      pipeline.reset();
      await pipeline.bootstrap();

      expect(registerCount, 2);
      expect(stageCount, 6);
    });
  });
}
