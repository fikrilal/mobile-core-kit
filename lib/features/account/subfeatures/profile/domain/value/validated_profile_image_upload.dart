import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';

/// Validated profile image upload accepted by the upload-plan repository
/// boundary.
class ValidatedProfileImageUpload {
  const ValidatedProfileImageUpload._({
    required this.bytes,
    required this.contentType,
    required this.sizeBytes,
    required this.idempotencyKey,
  });

  static const int maxSizeBytes = 5_000_000;
  static const Set<String> allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final Uint8List bytes;

  /// Normalized MIME type: trimmed, lowercased, `image/jpg` -> `image/jpeg`.
  final String contentType;

  /// Derived from [bytes]; always equals `bytes.lengthInBytes`.
  final int sizeBytes;
  final String? idempotencyKey;

  static Either<List<ValidationError>, ValidatedProfileImageUpload> create({
    required Uint8List bytes,
    required String contentType,
    String? idempotencyKey,
  }) {
    final errors = <ValidationError>[];

    final normalizedContentType = _normalizeContentType(contentType);
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

    final sizeBytes = bytes.lengthInBytes;
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

    if (errors.isNotEmpty) return left(errors);

    return right(
      ValidatedProfileImageUpload._(
        bytes: bytes,
        contentType: normalizedContentType,
        sizeBytes: sizeBytes,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  static String _normalizeContentType(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized == 'image/jpg') return 'image/jpeg';
    return normalized;
  }
}
