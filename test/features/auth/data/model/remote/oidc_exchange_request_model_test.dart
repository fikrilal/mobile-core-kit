import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';

void main() {
  test('toJson matches backend OIDC exchange contract (omits nulls)', () {
    const model = OidcExchangeRequestModel(
      provider: 'GOOGLE',
      idToken: 'oidc-id-token',
    );

    expect(model.toJson(), <String, dynamic>{
      'provider': 'GOOGLE',
      'idToken': 'oidc-id-token',
    });
  });

  test('toJson includes device metadata when provided', () {
    const model = OidcExchangeRequestModel(
      provider: 'GOOGLE',
      idToken: 'oidc-id-token',
      deviceId: 'device-123',
      deviceName: 'Pixel 7',
    );

    expect(model.toJson(), <String, dynamic>{
      'provider': 'GOOGLE',
      'idToken': 'oidc-id-token',
      'deviceId': 'device-123',
      'deviceName': 'Pixel 7',
    });
  });
}
