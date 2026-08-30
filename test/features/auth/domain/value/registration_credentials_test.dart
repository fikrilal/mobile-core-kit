import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/value/registration_credentials.dart';

void main() {
  group('RegistrationCredentials', () {
    test('aggregates email and password validation errors', () {
      final result = RegistrationCredentials.create(
        email: 'not-an-email',
        password: 'short',
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
          code: ValidationErrorCodes.passwordTooShort,
        ),
      ]);
    });

    test('normalizes email and preserves password', () {
      final result = RegistrationCredentials.create(
        email: ' user@example.com ',
        password: ' password123 ',
      );

      final credentials = result.getRight().toNullable();
      expect(credentials, isNotNull);
      expect(credentials!.email.value, 'user@example.com');
      expect(credentials.password.value, ' password123 ');
    });
  });
}
