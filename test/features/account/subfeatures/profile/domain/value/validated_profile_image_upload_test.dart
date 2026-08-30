import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/validated_profile_image_upload.dart';

void main() {
  group('ValidatedProfileImageUpload', () {
    test('rejects unsupported content type', () {
      final result = ValidatedProfileImageUpload.create(
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/gif',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'contentType',
            message: '',
            code: ValidationErrorCodes.fileTypeNotSupported,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });

    test('normalizes image/jpg to image/jpeg and derives size', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);

      final result = ValidatedProfileImageUpload.create(
        bytes: bytes,
        contentType: ' Image/JPG ',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('Expected Right'), (upload) {
        expect(upload.contentType, 'image/jpeg');
        expect(upload.sizeBytes, 4);
        expect(upload.bytes, bytes);
      });
    });

    test('rejects empty bytes', () {
      final result = ValidatedProfileImageUpload.create(
        bytes: Uint8List(0),
        contentType: 'image/png',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'file',
            message: '',
            code: ValidationErrorCodes.required,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });

    test('rejects oversized bytes', () {
      final result = ValidatedProfileImageUpload.create(
        bytes: Uint8List(ValidatedProfileImageUpload.maxSizeBytes + 1),
        contentType: 'image/png',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'file',
            message: '',
            code: ValidationErrorCodes.fileTooLarge,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });
  });
}
