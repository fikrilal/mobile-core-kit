import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';

class UploadProfileImageUseCase {
  UploadProfileImageUseCase(this._repository, this._getMe);

  static const int maxSizeBytes = 5_000_000;
  static const Set<String> allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final ProfileImageRepository _repository;
  final GetMeUseCase _getMe;

  Future<Either<AuthFailure, UserEntity>> call(
    UploadProfileImageRequestEntity request,
  ) async {
    final errors = <ValidationError>[];

    final normalizedContentType = _normalizeContentType(request.contentType);
    if (normalizedContentType.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'contentType',
          message: '',
          code: ValidationErrorCodes.required,
        ),
      );
    } else if (!allowedContentTypes.contains(normalizedContentType)) {
      errors.add(
        const ValidationError(
          field: 'contentType',
          message: '',
          code: ValidationErrorCodes.fileTypeNotSupported,
        ),
      );
    }

    final sizeBytes = request.bytes.lengthInBytes;
    if (sizeBytes <= 0) {
      errors.add(
        const ValidationError(
          field: 'file',
          message: '',
          code: ValidationErrorCodes.required,
        ),
      );
    } else if (sizeBytes > maxSizeBytes) {
      errors.add(
        const ValidationError(
          field: 'file',
          message: '',
          code: ValidationErrorCodes.fileTooLarge,
        ),
      );
    }

    if (errors.isNotEmpty) {
      return left<AuthFailure, UserEntity>(AuthFailure.validation(errors));
    }

    final planResult = await _repository.createUploadPlan(
      CreateProfileImageUploadPlanRequestEntity(
        contentType: normalizedContentType,
        sizeBytes: sizeBytes,
        idempotencyKey: request.idempotencyKey,
      ),
    );

    return planResult.match((failure) => Future.value(left(failure)), (
      plan,
    ) async {
      final uploadResult = await _repository.uploadToPresignedUrl(
        plan: plan,
        bytes: request.bytes,
      );

      return uploadResult.match((failure) => Future.value(left(failure)), (
        _,
      ) async {
        final completeResult = await _repository.completeUpload(
          CompleteProfileImageUploadRequestEntity(fileId: plan.fileId),
        );

        return completeResult.match(
          (failure) => Future.value(left(failure)),
          (_) => _getMe(),
        );
      });
    });
  }

  static String _normalizeContentType(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized == 'image/jpg') return 'image/jpeg';
    return normalized;
  }
}
