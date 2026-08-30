import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_reset_credentials.dart';

void main() {
  group('PasswordResetCredentials', () {
    test('collects token and password failures', () {
      final result = PasswordResetCredentials.create(
        token: ' ',
        newPassword: 'short',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'token',
            message: '',
            code: ValidationErrorCodes.required,
          ),
          const ValidationError(
            field: 'newPassword',
            message: '',
            code: ValidationErrorCodes.passwordTooShort,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });

    test('normalizes only the token and preserves password bytes', () {
      final result = PasswordResetCredentials.create(
        token: ' token ',
        newPassword: ' new password 123 ',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('Expected Right'), (credentials) {
        expect(credentials.token.value, 'token');
        expect(credentials.newPassword.value, ' new password 123 ');
      });
    });
  });
}
