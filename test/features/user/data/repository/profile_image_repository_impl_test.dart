import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/api/no_data.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_request.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_upload_plan_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_url_model.dart';
import 'package:mobile_core_kit/features/user/data/repository/profile_image_repository_impl.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_upload_plan_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileImageRemoteDataSource extends Mock
    implements ProfileImageRemoteDataSource {}

class _MockPresignedUploadClient extends Mock implements PresignedUploadClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      PresignedUploadRequest(
        method: PresignedUploadMethod.put,
        url: 'https://example.com/upload',
        headers: const {'Content-Type': 'image/jpeg'},
      ),
    );
    registerFallbackValue(Uint8List(0));
  });

  group('ProfileImageRepositoryImpl', () {
    test('createUploadPlan maps response to entity', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      const model = ProfileImageUploadPlanModel(
        fileId: 'f1',
        upload: PresignedUploadModel(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: '1970-01-01T00:00:00.000Z',
      );

      when(
        () => remote.createUploadPlan(
          contentType: any(named: 'contentType'),
          sizeBytes: any(named: 'sizeBytes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(data: model));

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final result = await repo.createUploadPlan(
        const CreateProfileImageUploadPlanRequestEntity(
          contentType: 'image/jpeg',
          sizeBytes: 123,
          idempotencyKey: 'idem',
        ),
      );

      expect(result.isRight(), true);

      result.match(
        (_) => fail('Expected Right'),
        (plan) {
          expect(plan.fileId, 'f1');
          expect(plan.upload.method, 'PUT');
          expect(plan.upload.url, 'https://example.com/upload');
          expect(plan.upload.headers['Content-Type'], 'image/jpeg');
          expect(plan.expiresAt.toUtc().toIso8601String(), '1970-01-01T00:00:00.000Z');
        },
      );

      verify(
        () => remote.createUploadPlan(
          contentType: 'image/jpeg',
          sizeBytes: 123,
          idempotencyKey: 'idem',
        ),
      ).called(1);
    });

    test('createUploadPlan maps UNAUTHORIZED to unauthenticated', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => remote.createUploadPlan(
          contentType: any(named: 'contentType'),
          sizeBytes: any(named: 'sizeBytes'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse<ProfileImageUploadPlanModel>.error(
          statusCode: 401,
          code: ApiErrorCodes.unauthorized,
          message: 'Unauthorized',
        ),
      );

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final result = await repo.createUploadPlan(
        const CreateProfileImageUploadPlanRequestEntity(
          contentType: 'image/jpeg',
          sizeBytes: 1,
        ),
      );

      expect(result, left(const AuthFailure.unauthenticated()));
    });

    test('uploadToPresignedUrl uses PresignedUploadClient with correct request', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => upload.uploadBytes(any(), bytes: any(named: 'bytes')),
      ).thenAnswer((_) async {});

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final plan = ProfileImageUploadPlanEntity(
        fileId: 'f1',
        upload: const ProfileImagePresignedUploadEntity(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      final bytes = Uint8List.fromList([1, 2, 3]);

      final result = await repo.uploadToPresignedUrl(plan: plan, bytes: bytes);

      expect(result, right(unit));

      final captured = verify(
        () => upload.uploadBytes(
          captureAny(),
          bytes: captureAny(named: 'bytes'),
        ),
      ).captured;

      final request = captured[0] as PresignedUploadRequest;
      final sentBytes = captured[1] as List<int>;

      expect(request.method, PresignedUploadMethod.put);
      expect(request.uri.toString(), 'https://example.com/upload');
      expect(request.headers['Content-Type'], 'image/jpeg');
      expect(sentBytes, bytes);
    });

    test('uploadToPresignedUrl maps offline upload failure to network', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => upload.uploadBytes(any(), bytes: any(named: 'bytes')),
      ).thenThrow(PresignedUploadFailure(message: 'offline', statusCode: -1));

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final plan = ProfileImageUploadPlanEntity(
        fileId: 'f1',
        upload: const ProfileImagePresignedUploadEntity(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      final result = await repo.uploadToPresignedUrl(
        plan: plan,
        bytes: Uint8List.fromList([1]),
      );

      expect(result, left(const AuthFailure.network()));
    });

    test('completeUpload returns Unit on success', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => remote.completeUpload(fileId: any(named: 'fileId')),
      ).thenAnswer((_) async => ApiResponse.success(data: const ApiNoData()));

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final result = await repo.completeUpload(
        const CompleteProfileImageUploadRequestEntity(fileId: 'f1'),
      );

      expect(result, right(unit));
      verify(() => remote.completeUpload(fileId: 'f1')).called(1);
    });

    test('clearProfileImage returns Unit on success', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => remote.clearProfileImage(idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((_) async => ApiResponse.success(data: const ApiNoData()));

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final result = await repo.clearProfileImage(
        const ClearProfileImageRequestEntity(idempotencyKey: 'idem'),
      );

      expect(result, right(unit));
      verify(() => remote.clearProfileImage(idempotencyKey: 'idem')).called(1);
    });

    test('getProfileImageUrl returns null on 204-no-image', () async {
      final remote = _MockProfileImageRemoteDataSource();
      final upload = _MockPresignedUploadClient();

      when(
        () => remote.getProfileImageUrl(),
      ).thenAnswer(
        (_) async => ApiResponse<ProfileImageUrlModel?>.success(data: null),
      );

      final repo = ProfileImageRepositoryImpl(remote, upload);

      final result = await repo.getProfileImageUrl();

      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value, null),
      );
    });
  });
}
