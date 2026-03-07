import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';

class UploadProfileImageUseCase {
  UploadProfileImageUseCase(this._repository, this._currentUserFetcher);

  static const int maxSizeBytes = 5_000_000;
  static const Set<String> allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final ProfileImageRepository _repository;
  final CurrentUserFetcher _currentUserFetcher;

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
          (_) => _refreshCurrentUser(),
        );
      });
    });
  }

  Future<Either<AuthFailure, UserEntity>> _refreshCurrentUser() async {
    final result = await _currentUserFetcher.fetch();
    return result.mapLeft(_mapSessionFailure);
  }

  static AuthFailure _mapSessionFailure(SessionFailure failure) {
    return switch (failure.type) {
      SessionFailureType.network => const AuthFailure.network(),
      SessionFailureType.unauthenticated =>
        const AuthFailure.unauthenticated(),
      SessionFailureType.tooManyRequests =>
        const AuthFailure.tooManyRequests(),
      SessionFailureType.serverError =>
        AuthFailure.serverError(failure.message),
      SessionFailureType.unexpected =>
        AuthFailure.unexpected(message: failure.message),
    };
  }

  static String _normalizeContentType(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized == 'image/jpg') return 'image/jpeg';
    return normalized;
  }
}
