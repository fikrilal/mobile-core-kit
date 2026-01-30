import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_upload_plan_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_url_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

ProfileImageUploadPlanModel _fallbackUploadPlanParser(
  Map<String, dynamic> json,
) {
  return const ProfileImageUploadPlanModel(
    fileId: 'fallback-file-id',
    upload: PresignedUploadModel(
      method: 'PUT',
      url: 'https://example.com/upload',
      headers: {},
    ),
    expiresAt: '2026-01-01T00:00:00.000Z',
  );
}

ProfileImageUrlModel _fallbackProfileImageUrlParser(Map<String, dynamic> json) {
  return const ProfileImageUrlModel(
    url: 'https://example.com/render',
    expiresAt: '2026-01-01T00:00:00.000Z',
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackUploadPlanParser);
    registerFallbackValue(_fallbackProfileImageUrlParser);
  });

  test(
    'createUploadPlan hits /me/profile-image/upload on profile host',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = ProfileImageRemoteDataSource(apiHelper);

      final expected = ApiResponse<ProfileImageUploadPlanModel>.success(
        data: const ProfileImageUploadPlanModel(
          fileId: 'f1',
          upload: PresignedUploadModel(
            method: 'PUT',
            url: 'https://example.com/upload',
            headers: {'Content-Type': 'image/webp'},
          ),
          expiresAt: '2026-01-01T00:00:00.000Z',
        ),
      );

      when(
        () => apiHelper.post<ProfileImageUploadPlanModel>(
          UserEndpoint.meProfileImageUpload,
          parser: any(named: 'parser'),
          host: ApiHost.profile,
          throwOnError: false,
          headers: any(named: 'headers'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.createUploadPlan(
        contentType: 'image/webp',
        sizeBytes: 123,
      );

      expect(response, same(expected));

      final captured = verify(
        () => apiHelper.post<ProfileImageUploadPlanModel>(
          UserEndpoint.meProfileImageUpload,
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
      expect(data, equals({'contentType': 'image/webp', 'sizeBytes': 123}));

      verifyNoMoreInteractions(apiHelper);
    },
  );

  test(
    'completeUpload hits /me/profile-image/complete on profile host',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = ProfileImageRemoteDataSource(apiHelper);

      final expected = ApiResponse<ApiNoData>.success(data: const ApiNoData());

      when(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meProfileImageComplete,
          host: ApiHost.profile,
          throwOnError: false,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.completeUpload(fileId: 'f1');
      expect(response, same(expected));

      final captured = verify(
        () => apiHelper.post<ApiNoData>(
          UserEndpoint.meProfileImageComplete,
          host: ApiHost.profile,
          throwOnError: false,
          data: captureAny(named: 'data'),
        ),
      ).captured;

      final data = captured[0] as Object?;
      expect(data, equals({'fileId': 'f1'}));

      verifyNoMoreInteractions(apiHelper);
    },
  );

  test(
    'clearProfileImage hits /me/profile-image on profile host with idempotency key',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = ProfileImageRemoteDataSource(apiHelper);

      final expected = ApiResponse<ApiNoData>.success(data: const ApiNoData());

      when(
        () => apiHelper.delete<ApiNoData>(
          UserEndpoint.meProfileImage,
          host: ApiHost.profile,
          throwOnError: false,
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.clearProfileImage();
      expect(response, same(expected));

      final captured = verify(
        () => apiHelper.delete<ApiNoData>(
          UserEndpoint.meProfileImage,
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
    'getProfileImageUrl hits /me/profile-image/url on profile host',
    () async {
      final apiHelper = _MockApiHelper();
      final datasource = ProfileImageRemoteDataSource(apiHelper);

      final expected = ApiResponse<ProfileImageUrlModel?>.success(
        data: const ProfileImageUrlModel(
          url: 'https://example.com/render',
          expiresAt: '2026-01-01T00:00:00.000Z',
        ),
      );

      when(
        () => apiHelper.getOne<ProfileImageUrlModel?>(
          UserEndpoint.meProfileImageUrl,
          parser: any(named: 'parser'),
          host: ApiHost.profile,
          throwOnError: false,
        ),
      ).thenAnswer((_) async => expected);

      final response = await datasource.getProfileImageUrl();
      expect(response, same(expected));

      verify(
        () => apiHelper.getOne<ProfileImageUrlModel?>(
          UserEndpoint.meProfileImageUrl,
          parser: any(named: 'parser'),
          host: ApiHost.profile,
          throwOnError: false,
        ),
      ).called(1);

      verifyNoMoreInteractions(apiHelper);
    },
  );
}
