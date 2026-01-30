import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_upload_plan_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileImageRepository extends Mock
    implements ProfileImageRepository {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CreateProfileImageUploadPlanRequestEntity(
        contentType: 'image/jpeg',
        sizeBytes: 1,
      ),
    );
    registerFallbackValue(
      const CompleteProfileImageUploadRequestEntity(fileId: 'f1'),
    );
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      ProfileImageUploadPlanEntity(
        fileId: 'f1',
        upload: ProfileImagePresignedUploadEntity(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  });

  group('UploadProfileImageUseCase', () {
    test(
      'returns validation failure and does not call repo when content type unsupported',
      () async {
        final repo = _MockProfileImageRepository();
        final getMe = _MockGetMeUseCase();
        final usecase = UploadProfileImageUseCase(repo, getMe);

        final result = await usecase(
          UploadProfileImageRequestEntity(
            bytes: Uint8List.fromList([1, 2, 3]),
            contentType: 'image/gif',
          ),
        );

        expect(
          result,
          left(
            const AuthFailure.validation([
              ValidationError(
                field: 'contentType',
                message: '',
                code: ValidationErrorCodes.fileTypeNotSupported,
              ),
            ]),
          ),
        );

        verifyNever(() => repo.createUploadPlan(any()));
        verifyNever(
          () => repo.uploadToPresignedUrl(
            plan: any(named: 'plan'),
            bytes: any(named: 'bytes'),
          ),
        );
        verifyNever(() => repo.completeUpload(any()));
        verifyNever(() => getMe());
      },
    );

    test('returns validation failure when file is too large', () async {
      final repo = _MockProfileImageRepository();
      final getMe = _MockGetMeUseCase();
      final usecase = UploadProfileImageUseCase(repo, getMe);

      final result = await usecase(
        UploadProfileImageRequestEntity(
          bytes: Uint8List(UploadProfileImageUseCase.maxSizeBytes + 1),
          contentType: 'image/png',
        ),
      );

      expect(
        result,
        left(
          const AuthFailure.validation([
            ValidationError(
              field: 'file',
              message: '',
              code: ValidationErrorCodes.fileTooLarge,
            ),
          ]),
        ),
      );

      verifyNever(() => repo.createUploadPlan(any()));
      verifyNever(
        () => repo.uploadToPresignedUrl(
          plan: any(named: 'plan'),
          bytes: any(named: 'bytes'),
        ),
      );
      verifyNever(() => repo.completeUpload(any()));
      verifyNever(() => getMe());
    });

    test('orchestrates plan → upload → complete → refresh /me', () async {
      final repo = _MockProfileImageRepository();
      final getMe = _MockGetMeUseCase();

      final plan = ProfileImageUploadPlanEntity(
        fileId: 'f1',
        upload: const ProfileImagePresignedUploadEntity(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      const user = UserEntity(id: 'u1', email: 'user@example.com');

      when(
        () => repo.createUploadPlan(any()),
      ).thenAnswer((_) async => right(plan));
      when(
        () => repo.uploadToPresignedUrl(
          plan: any(named: 'plan'),
          bytes: any(named: 'bytes'),
        ),
      ).thenAnswer((_) async => right(unit));
      when(
        () => repo.completeUpload(any()),
      ).thenAnswer((_) async => right(unit));
      when(() => getMe()).thenAnswer((_) async => right(user));

      final usecase = UploadProfileImageUseCase(repo, getMe);

      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = await usecase(
        UploadProfileImageRequestEntity(
          bytes: bytes,
          contentType: 'image/jpg',
          idempotencyKey: 'idem-1',
        ),
      );

      expect(result, right(user));

      final capturedCreate = verify(
        () => repo.createUploadPlan(captureAny()),
      ).captured;
      expect(capturedCreate.length, 1);
      final createReq =
          capturedCreate.single as CreateProfileImageUploadPlanRequestEntity;
      expect(createReq.contentType, 'image/jpeg');
      expect(createReq.sizeBytes, bytes.lengthInBytes);
      expect(createReq.idempotencyKey, 'idem-1');

      verifyInOrder([
        () => repo.uploadToPresignedUrl(
          plan: any(named: 'plan'),
          bytes: any(named: 'bytes'),
        ),
        () => repo.completeUpload(any()),
        () => getMe(),
      ]);
    });

    test('does not call complete/getMe when upload fails', () async {
      final repo = _MockProfileImageRepository();
      final getMe = _MockGetMeUseCase();

      final plan = ProfileImageUploadPlanEntity(
        fileId: 'f1',
        upload: const ProfileImagePresignedUploadEntity(
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {'Content-Type': 'image/jpeg'},
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      when(
        () => repo.createUploadPlan(any()),
      ).thenAnswer((_) async => right(plan));
      when(
        () => repo.uploadToPresignedUrl(
          plan: any(named: 'plan'),
          bytes: any(named: 'bytes'),
        ),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final usecase = UploadProfileImageUseCase(repo, getMe);

      final result = await usecase(
        UploadProfileImageRequestEntity(
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        ),
      );

      expect(result, left(const AuthFailure.network()));

      verify(() => repo.createUploadPlan(any())).called(1);
      verify(
        () => repo.uploadToPresignedUrl(
          plan: any(named: 'plan'),
          bytes: any(named: 'bytes'),
        ),
      ).called(1);
      verifyNever(() => repo.completeUpload(any()));
      verifyNever(() => getMe());
    });
  });
}
