import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';

void main() {
  test('toJson matches backend login contract (omits nulls)', () {
    const model = LoginRequestModel(
      email: 'user@example.com',
      password: 'pass',
    );

    expect(model.toJson(), <String, dynamic>{
      'email': 'user@example.com',
      'password': 'pass',
    });
  });

  test('toJson includes device metadata when provided', () {
    const model = LoginRequestModel(
      email: 'user@example.com',
      password: 'pass',
      deviceId: 'device-123',
      deviceName: 'Pixel 7',
    );

    expect(model.toJson(), <String, dynamic>{
      'email': 'user@example.com',
      'password': 'pass',
      'deviceId': 'device-123',
      'deviceName': 'Pixel 7',
    });
  });
}
