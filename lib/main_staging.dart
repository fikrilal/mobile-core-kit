import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/configs/build_config.dart';
import 'core/configs/app_config.dart';
import 'core/di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize AppConfig
      AppConfig.init(const AppConfig(accessToken: ''));

      // Collect crashes only in PRODUCTION builds
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        BuildConfig.env == BuildEnv.prod,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      await initializeDateFormatting('en_US', '');

      // Register dependencies synchronously, then render the first Flutter frame
      // as soon as possible (reduces time spent on the native launch screen).
      registerLocator();

      runApp(MyApp());

      // Defer heavy initialization work until after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(bootstrapLocator());
      });
    },
    (error, stack) async {
      await FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: true);
    },
  );
}
