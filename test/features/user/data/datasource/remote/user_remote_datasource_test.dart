import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/user_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

UserModel _fallbackUserParser(Map<String, dynamic> json) =>
    const UserModel(id: 'fallback', email: 'fallback@example.com');

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackUserParser);
  });

  test('getMe hits /me on profile host', () async {
    final apiHelper = _MockApiHelper();
    final datasource = UserRemoteDataSource(apiHelper);

    final expected = ApiResponse<UserModel>.success(
      data: const UserModel(id: 'u1', email: 'user@example.com'),
    );

    when(
      () => apiHelper.getOne<UserModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
      ),
    ).thenAnswer((_) async => expected);

    final response = await datasource.getMe();

    expect(response, same(expected));
    verify(
      () => apiHelper.getOne<UserModel>(
        UserEndpoint.me,
        parser: any(named: 'parser'),
        host: ApiHost.profile,
        throwOnError: false,
      ),
    ).called(1);
    verifyNoMoreInteractions(apiHelper);
  });
}
