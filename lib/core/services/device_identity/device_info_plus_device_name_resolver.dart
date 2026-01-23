import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_name_resolver.dart';

class DeviceInfoPlusDeviceNameResolver implements DeviceNameResolver {
  DeviceInfoPlusDeviceNameResolver({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  @override
  Future<String?> resolve() async {
    if (kIsWeb) return 'Web';

    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await _deviceInfo.androidInfo;
          return _joinNonEmpty([info.manufacturer, info.model]);
        case TargetPlatform.iOS:
          final info = await _deviceInfo.iosInfo;
          // Avoid `info.name` (often user-defined / PII). `model` is non-PII.
          return _normalize(info.model);
        case TargetPlatform.macOS:
          return 'macOS';
        case TargetPlatform.windows:
          return 'Windows';
        case TargetPlatform.linux:
          return 'Linux';
        case TargetPlatform.fuchsia:
          return 'Fuchsia';
      }
    } catch (_) {
      // Best-effort only.
      return null;
    }
  }

  String? _joinNonEmpty(List<String?> parts) {
    final normalized = parts
        .map(_normalize)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) return null;
    return normalized.join(' ');
  }

  String? _normalize(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }
}
