import 'dart:async';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/configs/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/appearance/theme_mode_controller.dart';
import 'core/services/localization/locale_controller.dart';
import 'core/services/early_errors/early_error_buffer.dart';
import 'core/services/startup_metrics/startup_metrics.dart';
import 'core/utilities/log_utils.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final startupMetrics = StartupMetrics.instance..start();
      WidgetsFlutterBinding.ensureInitialized();
      EarlyErrorBuffer.instance.install();
      startupMetrics
        ..mark(StartupMilestone.flutterBindingInitialized)
        ..attachFirstFrameTimingsListener();

      // Initialize AppConfig
      AppConfig.init(const AppConfig(accessToken: ''));

      // Register dependencies synchronously, then render the first Flutter frame
      // as soon as possible (reduces time spent on the native launch screen).
      registerLocator();
      startupMetrics.mark(StartupMilestone.diRegistered);

      // Load theme mode preference before first frame to avoid a light↔dark flash
      // when users override system appearance.
      await locator<ThemeModeController>().load();

      // Load locale override before first frame to avoid a language flash when
      // users override system locale.
      await locator<LocaleController>().load();

      startupMetrics.mark(StartupMilestone.runAppCalled);
      runApp(MyApp());

      // Defer heavy initialization work until after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupMetrics.mark(StartupMilestone.firstFrame);
        unawaited(bootstrapLocator());
      });
    },
    (error, stack) {
      EarlyErrorBuffer.instance.recordError(
        error,
        stack,
        reason: 'Uncaught zone error',
        fatal: true,
      );
      Log.wtf('Uncaught zone error', error, stack, false, 'Zone');
    },
  );
}
