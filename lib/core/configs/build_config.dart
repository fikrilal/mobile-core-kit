import 'api_host.dart';
part 'build_config_values.dart';

enum BuildEnv { dev, stage, prod }

class BuildConfig {
  // Compile‑time selector; one flag only.
  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static final env = BuildEnv.values.firstWhere((e) => e.name == _env);

  // ---------------- public API ----------------

  /// Returns the full base URL for the requested host in the *current* build.
  static String apiUrl(ApiHost host) => switch (env) {
    BuildEnv.dev => _devHosts[host]!,
    BuildEnv.stage => _stagingHosts[host]!,
    BuildEnv.prod => _prodHosts[host]!,
  };

  /// `true` → keep verbose logs in this build.
  static bool get logEnabled => switch (env) {
    BuildEnv.dev => _devEnableLogging,
    BuildEnv.stage => _stagingEnableLogging,
    BuildEnv.prod => _prodEnableLogging,
  };

  /// Enable the closed-test reminder experiment (local notifications)
  static bool get reminderExperiment => switch (env) {
    BuildEnv.dev => _devReminderExperiment,
    BuildEnv.stage => _stagingReminderExperiment,
    BuildEnv.prod => _prodReminderExperiment,
  };

  /// Whether analytics collection should be enabled by default for this build.
  static bool get analyticsEnabledDefault => switch (env) {
    BuildEnv.dev => _devAnalyticsEnabledDefault,
    BuildEnv.stage => _stagingAnalyticsEnabledDefault,
    BuildEnv.prod => _prodAnalyticsEnabledDefault,
  };

  /// Whether verbose analytics debug logging is enabled for this build.
  static bool get analyticsDebugLoggingEnabled => switch (env) {
    BuildEnv.dev => _devAnalyticsDebugLoggingEnabled,
    BuildEnv.stage => _stagingAnalyticsDebugLoggingEnabled,
    BuildEnv.prod => _prodAnalyticsDebugLoggingEnabled,
  };

  /// Google OAuth Client IDs for mobile sign-in
  static String get googleWebClientId => switch (env) {
    BuildEnv.dev => _devGoogleWebClientId,
    BuildEnv.stage => _stagingGoogleWebClientId,
    BuildEnv.prod => _prodGoogleWebClientId,
  };

  static String get googleIosClientId => switch (env) {
    BuildEnv.dev => _devGoogleIosClientId,
    BuildEnv.stage => _stagingGoogleIosClientId,
    BuildEnv.prod => _prodGoogleIosClientId,
  };

  static String get googleAndroidClientId => switch (env) {
    BuildEnv.dev => _devGoogleAndroidClientId,
    BuildEnv.stage => _stagingGoogleAndroidClientId,
    BuildEnv.prod => _prodGoogleAndroidClientId,
  };

  // ---------------- Network Logging Config ----------------

  /// Network log mode: off, summary, smallBodies, full
  static String get netLogMode => switch (env) {
    BuildEnv.dev => _devNetLogMode,
    BuildEnv.stage => _stagingNetLogMode,
    BuildEnv.prod => _prodNetLogMode,
  };

  /// Maximum bytes to log for request/response bodies
  static int get netLogBodyLimitBytes => switch (env) {
    BuildEnv.dev => _devNetLogBodyLimitBytes,
    BuildEnv.stage => _stagingNetLogBodyLimitBytes,
    BuildEnv.prod => _prodNetLogBodyLimitBytes,
  };

  /// Threshold in bytes for classifying responses as "large"
  static int get netLogLargeThresholdBytes => switch (env) {
    BuildEnv.dev => _devNetLogLargeThresholdBytes,
    BuildEnv.stage => _stagingNetLogLargeThresholdBytes,
    BuildEnv.prod => _prodNetLogLargeThresholdBytes,
  };

  /// Threshold in milliseconds for classifying requests as "slow"
  static int get netLogSlowMs => switch (env) {
    BuildEnv.dev => _devNetLogSlowMs,
    BuildEnv.stage => _stagingNetLogSlowMs,
    BuildEnv.prod => _prodNetLogSlowMs,
  };

  /// Whether to redact sensitive headers and body fields
  static bool get netLogRedact => switch (env) {
    BuildEnv.dev => _devNetLogRedact,
    BuildEnv.stage => _stagingNetLogRedact,
    BuildEnv.prod => _prodNetLogRedact,
  };
}
