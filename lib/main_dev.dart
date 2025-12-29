import 'dart:async';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/configs/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/startup_metrics/startup_metrics.dart';
import 'core/utilities/log_utils.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final startupMetrics = StartupMetrics.instance..start();
      WidgetsFlutterBinding.ensureInitialized();
      startupMetrics
        ..mark(StartupMilestone.flutterBindingInitialized)
        ..attachFirstFrameTimingsListener();

      // Initialize AppConfig
      AppConfig.init(const AppConfig(accessToken: ''));

      // Register dependencies synchronously, then render the first Flutter frame
      // as soon as possible (reduces time spent on the native launch screen).
      registerLocator();
      startupMetrics.mark(StartupMilestone.diRegistered);

      startupMetrics.mark(StartupMilestone.runAppCalled);
      runApp(MyApp());

      // Defer heavy initialization work until after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupMetrics.mark(StartupMilestone.firstFrame);
        unawaited(bootstrapLocator());
      });
    },
    (error, stack) {
      Log.wtf('Uncaught zone error', error, stack, true, 'Zone');
    },
  );
}
