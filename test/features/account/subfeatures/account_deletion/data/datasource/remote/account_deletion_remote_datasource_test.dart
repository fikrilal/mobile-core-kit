import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/datasource/remote/account_deletion_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

void main() {
  test(
    'requestDeletion(request) hits /me/account-deletion/request on profile host with idempotency key',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = AccountDeletionRemoteDataSource(apiHelper);

      final expected = ApiResponse<ApiNoData>.success(data: const ApiNoData());

      when(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meAccountDeletionRequest,
          host: ApiHost.profile,
          throwOnError: false,
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.requestDeletion(
        AccountDeletionAction.request,
      );

      expect(response, same(expected));

      final captured = verify(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meAccountDeletionRequest,
          host: ApiHost.profile,
          throwOnError: false,
          headers: captureAny(named: 'headers'),
        ),
      ).captured;

      final headers = captured[0] as Map<String, String>?;
      expect(headers, isNotNull);
      expect(headers!.containsKey('Idempotency-Key'), isTrue);
      expect(headers['Idempotency-Key'], isNotEmpty);

      verifyNoMoreInteractions(apiHelper);
    },
  );

  test(
    'requestDeletion(cancel) hits /me/account-deletion/cancel on profile host with idempotency key',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = AccountDeletionRemoteDataSource(apiHelper);

      final expected = ApiResponse<ApiNoData>.success(data: const ApiNoData());

      when(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meAccountDeletionCancel,
          host: ApiHost.profile,
          throwOnError: false,
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.requestDeletion(
        AccountDeletionAction.cancel,
      );

      expect(response, same(expected));

      final captured = verify(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meAccountDeletionCancel,
          host: ApiHost.profile,
          throwOnError: false,
          headers: captureAny(named: 'headers'),
        ),
      ).captured;

      final headers = captured[0] as Map<String, String>?;
      expect(headers, isNotNull);
      expect(headers!.containsKey('Idempotency-Key'), isTrue);
      expect(headers['Idempotency-Key'], isNotEmpty);

      verifyNoMoreInteractions(apiHelper);
    },
  );
}
