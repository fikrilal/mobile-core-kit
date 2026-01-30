import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_identity.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/user/model/remote/me_model.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockGoogleFederatedAuthService extends Mock
    implements GoogleFederatedAuthService {}

class _MockDeviceIdentityService extends Mock
    implements DeviceIdentityService {}

AuthResponseModel _authResponse() {
  return const AuthResponseModel(
    user: MeModel(
      id: 'u1',
      email: 'user@example.com',
      emailVerified: false,
      roles: ['USER'],
      authMethods: ['PASSWORD'],
      profile: MeProfileModel(),
    ),
    accessToken: 'access',
    refreshToken: 'refresh',
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RegisterRequestModel(email: 'e', password: 'p'),
    );
    registerFallbackValue(const LoginRequestModel(email: 'e', password: 'p'));
    registerFallbackValue(
      const OidcExchangeRequestModel(provider: 'GOOGLE', idToken: 't'),
    );
  });

  test('register includes deviceId/deviceName in payload', () async {
    final remote = _MockAuthRemoteDataSource();
    final google = _MockGoogleFederatedAuthService();
    final device = _MockDeviceIdentityService();

    when(() => device.get()).thenAnswer(
      (_) async => const DeviceIdentity(id: 'device-123', name: 'Pixel 7'),
    );

    when(() => remote.register(any())).thenAnswer(
      (_) async =>
          ApiResponse<AuthResponseModel>.success(data: _authResponse()),
    );

    final repo = AuthRepositoryImpl(remote, google, device);

    final result = await repo.register(
      const RegisterRequestEntity(email: 'user@example.com', password: 'pass'),
    );

    expect(result.isRight(), true);

    final captured = verify(() => remote.register(captureAny())).captured;
    final request = captured.single as RegisterRequestModel;
    expect(request.deviceId, 'device-123');
    expect(request.deviceName, 'Pixel 7');
  });

  test('login includes deviceId/deviceName in payload', () async {
    final remote = _MockAuthRemoteDataSource();
    final google = _MockGoogleFederatedAuthService();
    final device = _MockDeviceIdentityService();

    when(() => device.get()).thenAnswer(
      (_) async => const DeviceIdentity(id: 'device-123', name: 'Pixel 7'),
    );

    when(() => remote.login(any())).thenAnswer(
      (_) async =>
          ApiResponse<AuthResponseModel>.success(data: _authResponse()),
    );

    final repo = AuthRepositoryImpl(remote, google, device);

    final result = await repo.login(
      const LoginRequestEntity(email: 'user@example.com', password: 'pass'),
    );

    expect(result.isRight(), true);

    final captured = verify(() => remote.login(captureAny())).captured;
    final request = captured.single as LoginRequestModel;
    expect(request.deviceId, 'device-123');
    expect(request.deviceName, 'Pixel 7');
  });

  test('oidc exchange includes deviceId/deviceName in payload', () async {
    final remote = _MockAuthRemoteDataSource();
    final google = _MockGoogleFederatedAuthService();
    final device = _MockDeviceIdentityService();

    when(
      () => google.signInAndGetOidcIdToken(),
    ).thenAnswer((_) async => 'oidc');
    when(() => device.get()).thenAnswer(
      (_) async => const DeviceIdentity(id: 'device-123', name: 'Pixel 7'),
    );

    when(() => remote.oidcExchange(any())).thenAnswer(
      (_) async =>
          ApiResponse<AuthResponseModel>.success(data: _authResponse()),
    );

    final repo = AuthRepositoryImpl(remote, google, device);

    final result = await repo.signInWithGoogleOidc();

    expect(result.isRight(), true);

    final captured = verify(() => remote.oidcExchange(captureAny())).captured;
    final request = captured.single as OidcExchangeRequestModel;
    expect(request.deviceId, 'device-123');
    expect(request.deviceName, 'Pixel 7');
  });
}
