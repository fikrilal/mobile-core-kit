import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_image_error_codes.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_image_failure_mapper.dart';

void main() {
  group('mapProfileImageFailure', () {
    test('maps USERS_OBJECT_STORAGE_NOT_CONFIGURED to serverError', () {
      final failure = ApiFailure(
        message: 'Misconfigured',
        statusCode: 500,
        code: ProfileImageErrorCodes.usersObjectStorageNotConfigured,
      );

      expect(mapProfileImageFailure(failure), const AuthFailure.serverError());
    });

    test('maps USERS_PROFILE_IMAGE_NOT_UPLOADED to unexpected', () {
      final failure = ApiFailure(
        message: 'Not uploaded',
        statusCode: 400,
        code: ProfileImageErrorCodes.usersProfileImageNotUploaded,
      );

      expect(mapProfileImageFailure(failure), const AuthFailure.unexpected());
    });

    test(
      'maps USERS_PROFILE_IMAGE_SIZE_MISMATCH to validation(fileTooLarge)',
      () {
        final failure = ApiFailure(
          message: 'Size mismatch',
          statusCode: 400,
          code: ProfileImageErrorCodes.usersProfileImageSizeMismatch,
        );

        expect(
          mapProfileImageFailure(failure),
          AuthFailure.validation([
            const ValidationError(
              field: 'file',
              message: '',
              code: ValidationErrorCodes.fileTooLarge,
            ),
          ]),
        );
      },
    );

    test(
      'maps USERS_PROFILE_IMAGE_CONTENT_TYPE_MISMATCH to validation(fileTypeNotSupported)',
      () {
        final failure = ApiFailure(
          message: 'Content type mismatch',
          statusCode: 400,
          code: ProfileImageErrorCodes.usersProfileImageContentTypeMismatch,
        );

        expect(
          mapProfileImageFailure(failure),
          AuthFailure.validation([
            const ValidationError(
              field: 'contentType',
              message: '',
              code: ValidationErrorCodes.fileTypeNotSupported,
            ),
          ]),
        );
      },
    );

    test('falls back to user mapping for generic codes', () {
      final failure = ApiFailure(
        message: 'Unauthorized',
        statusCode: 401,
        code: ApiErrorCodes.unauthorized,
      );

      expect(
        mapProfileImageFailure(failure),
        const AuthFailure.unauthenticated(),
      );
    });
  });

  group('mapProfileImageUploadFailure', () {
    test('maps offline/timeout status codes to network', () {
      expect(
        mapProfileImageUploadFailure(
          PresignedUploadFailure(message: 'offline', statusCode: -1),
        ),
        const AuthFailure.network(),
      );
      expect(
        mapProfileImageUploadFailure(
          PresignedUploadFailure(message: 'timeout', statusCode: -2),
        ),
        const AuthFailure.network(),
      );
    });

    test('maps other upload failures to unexpected', () {
      expect(
        mapProfileImageUploadFailure(
          PresignedUploadFailure(message: 'forbidden', statusCode: 403),
        ),
        const AuthFailure.unexpected(),
      );
    });
  });
}
