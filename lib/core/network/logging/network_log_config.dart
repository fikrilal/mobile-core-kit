import 'package:flutter/foundation.dart';

import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/network/logging/net_log_mode.dart';

/// Configuration for network logging behavior.
///
/// Initialize via [NetworkLogConfig.initFromBuildConfig] in main_*.dart
/// before [ApiClient.init] is called.
class NetworkLogConfig {
  final NetLogMode mode;
  final int bodyLimitBytes;
  final int largeThresholdBytes;
  final int slowMs;
  final bool redact;
  final bool inspectorEnabled;

  const NetworkLogConfig({
    required this.mode,
    required this.bodyLimitBytes,
    required this.largeThresholdBytes,
    required this.slowMs,
    required this.redact,
    required this.inspectorEnabled,
  });

  static late NetworkLogConfig instance;

  static void init(NetworkLogConfig config) {
    instance = config;
  }

  /// Creates a [NetworkLogConfig] from [BuildConfig] values.
  ///
  /// This reads the generated config values from env/*.yaml files.
  static void initFromBuildConfig() {
    instance = NetworkLogConfig(
      mode: _parseMode(BuildConfig.netLogMode),
      bodyLimitBytes: BuildConfig.netLogBodyLimitBytes,
      largeThresholdBytes: BuildConfig.netLogLargeThresholdBytes,
      slowMs: BuildConfig.netLogSlowMs,
      redact: BuildConfig.netLogRedact,
      inspectorEnabled: !kReleaseMode,
    );
  }

  /// Parses the mode string from config into [NetLogMode].
  static NetLogMode _parseMode(String mode) {
    return switch (mode.toLowerCase()) {
      'off' => NetLogMode.off,
      'summary' => NetLogMode.summary,
      'smallbodies' => NetLogMode.smallBodies,
      'full' => NetLogMode.full,
      _ => kReleaseMode ? NetLogMode.off : NetLogMode.summary,
    };
  }

  /// Returns sensible defaults based on release mode.
  static NetworkLogConfig defaults({bool isProd = kReleaseMode}) {
    return NetworkLogConfig(
      mode: isProd ? NetLogMode.off : NetLogMode.summary,
      bodyLimitBytes: 8192,
      largeThresholdBytes: 65536,
      slowMs: 800,
      redact: true,
      inspectorEnabled: !isProd,
    );
  }
}
