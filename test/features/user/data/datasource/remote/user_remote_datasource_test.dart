import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/me_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/patch_me_request_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

MeModel _fallbackMeParser(Map<String, dynamic> json) => const MeModel(
  id: 'fallback',
  email: 'fallback@example.com',
  emailVerified: false,
  roles: ['USER'],
  authMethods: ['PASSWORD'],
  profile: MeProfileModel(),
);

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackMeParser);
  });

  test('getMe hits /me on profile host', () async {
    final apiHelper = _MockApiHelper();
    final datasource = UserRemoteDataSource(apiHelper);

    final expected = ApiResponse<MeModel>.success(
      data: const MeModel(
        id: 'u1',
        email: 'user@example.com',
        emailVerified: false,
        roles: ['USER'],
        authMethods: ['PASSWORD'],
        profile: MeProfileModel(),
      ),
    );

    when(
      () => apiHelper.getOne<MeModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
      ),
    ).thenAnswer((_) async => expected);

    final response = await datasource.getMe();

    expect(response, same(expected));
    verify(
      () => apiHelper.getOne<MeModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
      ),
    ).called(1);
    verifyNoMoreInteractions(apiHelper);
  });

  test('patchMe hits /me on profile host with idempotency key', () async {
    final apiHelper = _MockApiHelper();
    final datasource = UserRemoteDataSource(apiHelper);

    final expected = ApiResponse<MeModel>.success(
      data: const MeModel(
        id: 'u1',
        email: 'user@example.com',
        emailVerified: false,
        roles: ['USER'],
        authMethods: ['PASSWORD'],
        profile: MeProfileModel(givenName: 'Dante', familyName: 'Alighieri'),
      ),
    );

    when(
      () => apiHelper.patch<MeModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
        headers: any(named: 'headers'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => expected);

    final response = await datasource.patchMe(
      request: const PatchMeRequestModel(
        profile: PatchMeProfileModel(
          givenName: 'Dante',
          familyName: 'Alighieri',
        ),
      ),
    );

    expect(response, same(expected));

    final captured = verify(
      () => apiHelper.patch<MeModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
        headers: captureAny(named: 'headers'),
        data: captureAny(named: 'data'),
      ),
    ).captured;

    final headers = captured[0] as Map<String, String>?;
    expect(headers, isNotNull);
    expect(headers!.containsKey('Idempotency-Key'), isTrue);
    expect(headers['Idempotency-Key'], isNotEmpty);

    final data = captured[1] as Object?;
    expect(
      data,
      equals({
        'profile': {'givenName': 'Dante', 'familyName': 'Alighieri'},
      }),
    );

    verifyNoMoreInteractions(apiHelper);
  });
}
