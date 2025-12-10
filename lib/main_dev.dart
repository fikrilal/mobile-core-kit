import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/configs/build_config.dart';
import 'core/configs/app_config.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp();

      // Initialize AppConfig
      AppConfig.init(const AppConfig(accessToken: ''));

      // Collect crashes only in PRODUCTION builds
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        BuildConfig.env == BuildEnv.prod,
      );

      await initializeDateFormatting('en_US', '');

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      await setupLocator();

      runApp(MyApp());
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
