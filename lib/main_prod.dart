import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/configs/build_config.dart';
import 'core/configs/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/startup_metrics/startup_metrics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final startupMetrics = StartupMetrics.instance..start();
      WidgetsFlutterBinding.ensureInitialized();
      startupMetrics
        ..mark(StartupMilestone.flutterBindingInitialized)
        ..attachFirstFrameTimingsListener();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      startupMetrics.mark(StartupMilestone.firebaseInitialized);

      // Initialize AppConfig
      AppConfig.init(const AppConfig(accessToken: ''));

      // Collect crashes only in PRODUCTION builds
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        BuildConfig.env == BuildEnv.prod,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      startupMetrics.mark(StartupMilestone.crashlyticsConfigured);

      await initializeDateFormatting('en_US', '');
      startupMetrics.mark(StartupMilestone.intlInitialized);

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
    (error, stack) async {
      await FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: true);
    },
  );
}
