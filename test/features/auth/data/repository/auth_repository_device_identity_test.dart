import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/model/remote/me_model.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_credentials.dart';
import 'package:mobile_core_kit/features/auth/domain/value/registration_credentials.dart';
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
    final credentials = _validRegistrationCredentials();

    final result = await repo.register(credentials);

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
    final credentials = _validLoginCredentials();

    final result = await repo.login(credentials);

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

LoginCredentials _validLoginCredentials() {
  return LoginCredentials.create(
    email: 'user@example.com',
    password: 'pass',
  ).match(
    (_) => throw StateError('Expected valid test credentials.'),
    (credentials) => credentials,
  );
}

RegistrationCredentials _validRegistrationCredentials() {
  return RegistrationCredentials.create(
    email: 'user@example.com',
    password: 'password123',
  ).match(
    (_) => throw StateError('Expected valid test credentials.'),
    (credentials) => credentials,
  );
}
