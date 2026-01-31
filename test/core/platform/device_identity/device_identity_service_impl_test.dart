import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/storage/secure/device_identity_secure_storage.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service_impl.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_name_resolver.dart';

class _FakeDeviceIdentitySecureStorage implements DeviceIdentitySecureStorage {
  String? _deviceId;
  int readCount = 0;
  int writeCount = 0;

  @override
  Future<String?> readDeviceId() async {
    readCount += 1;
    return _deviceId;
  }

  @override
  Future<void> writeDeviceId(String id) async {
    writeCount += 1;
    _deviceId = id;
  }

  @override
  Future<void> clearDeviceId() async {
    _deviceId = null;
  }
}

class _FakeNameResolver implements DeviceNameResolver {
  _FakeNameResolver(this._value);

  final String? _value;
  int callCount = 0;

  @override
  Future<String?> resolve() async {
    callCount += 1;
    return _value;
  }
}

void main() {
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  test('generates and persists deviceId when missing', () async {
    final storage = _FakeDeviceIdentitySecureStorage();
    final resolver = _FakeNameResolver('Pixel 7');

    final service = DeviceIdentityServiceImpl(
      storage: storage,
      nameResolver: resolver,
    );

    final identity = await service.get();

    expect(identity.id.trim().isNotEmpty, true);
    expect(uuidV4.hasMatch(identity.id), true);
    expect(identity.name, 'Pixel 7');
    expect(storage.writeCount, 1);
    expect(resolver.callCount, 1);
  });

  test('returns cached identity on subsequent calls', () async {
    final storage = _FakeDeviceIdentitySecureStorage();
    final resolver = _FakeNameResolver('Pixel 7');

    final service = DeviceIdentityServiceImpl(
      storage: storage,
      nameResolver: resolver,
    );

    final first = await service.get();
    final second = await service.get();

    expect(second.id, first.id);
    expect(second.name, first.name);
    expect(storage.writeCount, 1);
    expect(resolver.callCount, 1);
  });

  test('single-flights concurrent get calls', () async {
    final storage = _FakeDeviceIdentitySecureStorage();
    final resolver = _FakeNameResolver('Pixel 7');

    final service = DeviceIdentityServiceImpl(
      storage: storage,
      nameResolver: resolver,
    );

    final results = await Future.wait([service.get(), service.get()]);

    expect(results[0].id, results[1].id);
    expect(storage.writeCount, 1);
    expect(resolver.callCount, 1);
  });
}
