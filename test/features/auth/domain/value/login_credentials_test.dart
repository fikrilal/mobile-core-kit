import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_credentials.dart';

void main() {
  group('LoginCredentials', () {
    test('aggregates email and password validation errors', () {
      final result = LoginCredentials.create(
        email: 'not-an-email',
        password: '   ',
      );

      expect(result.getLeft().toNullable(), const <ValidationError>[
        ValidationError(
          field: 'email',
          message: '',
          code: ValidationErrorCodes.invalidEmail,
        ),
        ValidationError(
          field: 'password',
          message: '',
          code: ValidationErrorCodes.required,
        ),
      ]);
    });

    test('normalizes email and preserves password', () {
      final result = LoginCredentials.create(
        email: ' user@example.com ',
        password: ' password ',
      );

      final credentials = result.getRight().toNullable();
      expect(credentials, isNotNull);
      expect(credentials!.email.value, 'user@example.com');
      expect(credentials.password.value, ' password ');
    });
  });
}
