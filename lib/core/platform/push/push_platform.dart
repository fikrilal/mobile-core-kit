import 'package:flutter/foundation.dart';

/// Backend contract for session push token registration.
///
/// Backend enum: `ANDROID | IOS | WEB`.
enum PushPlatform { android, ios, web }

extension PushPlatformApiValue on PushPlatform {
  String get apiValue => switch (this) {
    PushPlatform.android => 'ANDROID',
    PushPlatform.ios => 'IOS',
    PushPlatform.web => 'WEB',
  };
}

/// Returns the backend push platform for the current runtime.
///
/// Note: Desktop platforms are not supported by the backend contract, so this
/// returns null there. Callers should treat `null` as "push not supported".
PushPlatform? currentPushPlatformOrNull() {
  if (kIsWeb) return PushPlatform.web;

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => PushPlatform.android,
    TargetPlatform.iOS => PushPlatform.ios,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => null,
  };
}
