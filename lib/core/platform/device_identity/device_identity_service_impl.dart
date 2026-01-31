import 'dart:async';

import 'package:mobile_core_kit/core/foundation/utilities/uuid_v4_utils.dart';
import 'package:mobile_core_kit/core/infra/storage/secure/device_identity_secure_storage.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_info_plus_device_name_resolver.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_name_resolver.dart';

class DeviceIdentityServiceImpl implements DeviceIdentityService {
  DeviceIdentityServiceImpl({
    DeviceIdentitySecureStorage? storage,
    DeviceNameResolver? nameResolver,
  }) : _storage = storage ?? const DeviceIdentitySecureStorage(),
       _nameResolver = nameResolver ?? DeviceInfoPlusDeviceNameResolver();

  final DeviceIdentitySecureStorage _storage;
  final DeviceNameResolver _nameResolver;

  Future<DeviceIdentity>? _inFlight;
  DeviceIdentity? _cached;

  @override
  Future<DeviceIdentity> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _load();
    _inFlight = future;
    return future.whenComplete(() {
      if (_inFlight == future) _inFlight = null;
    });
  }

  Future<DeviceIdentity> _load() async {
    final id = await _getOrCreateDeviceId();
    final name = await _resolveSafeDeviceName();
    final identity = DeviceIdentity(id: id, name: name);
    _cached = identity;
    return identity;
  }

  Future<String> _getOrCreateDeviceId() async {
    final existing = await _storage.readDeviceId();
    final trimmed = existing?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;

    final id = UuidV4Utils.generate();
    await _storage.writeDeviceId(id);
    return id;
  }

  Future<String?> _resolveSafeDeviceName() async {
    try {
      final raw = await _nameResolver.resolve();
      final trimmed = raw?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (_) {
      return null;
    }
  }
}
