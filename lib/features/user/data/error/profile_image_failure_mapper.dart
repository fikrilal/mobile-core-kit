import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_image_error_codes.dart';
import 'package:mobile_core_kit/features/user/data/error/user_failure_mapper.dart';

/// Maps profile-image-specific backend failures into [AuthFailure].
///
/// Keep this mapping separate from repository implementations for readability
/// and unit testing (mirrors `features/auth/data/error/auth_failure_mapper.dart`).
AuthFailure mapProfileImageFailure(ApiFailure failure) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ProfileImageErrorCodes.usersObjectStorageNotConfigured:
        return const AuthFailure.serverError();
      case ProfileImageErrorCodes.usersProfileImageNotUploaded:
        return const AuthFailure.unexpected();
      case ProfileImageErrorCodes.usersProfileImageSizeMismatch:
        return AuthFailure.validation([
          ValidationError(
            field: 'file',
            message: '',
            code: ValidationErrorCodes.fileTooLarge,
          ),
        ]);
      case ProfileImageErrorCodes.usersProfileImageContentTypeMismatch:
        return AuthFailure.validation([
          ValidationError(
            field: 'contentType',
            message: '',
            code: ValidationErrorCodes.fileTypeNotSupported,
          ),
        ]);
    }
  }

  return mapUserFailure(failure);
}

AuthFailure mapProfileImageUploadFailure(PresignedUploadFailure failure) {
  final statusCode = failure.statusCode;
  if (statusCode == -1 || statusCode == -2) {
    return const AuthFailure.network();
  }
  return const AuthFailure.unexpected();
}
