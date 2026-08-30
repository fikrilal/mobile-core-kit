import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_change_credentials.dart';

void main() {
  group('PasswordChangeCredentials', () {
    test('collects field failures from both passwords', () {
      final result = PasswordChangeCredentials.create(
        currentPassword: '',
        newPassword: '123456789',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'currentPassword',
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

    test('flags equal passwords as passwordSameAsCurrent', () {
      final result = PasswordChangeCredentials.create(
        currentPassword: 'samepassword',
        newPassword: 'samepassword',
      );

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'newPassword',
            message: '',
            code: ValidationErrorCodes.passwordSameAsCurrent,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });

    test('preserves exact password bytes when valid', () {
      final result = PasswordChangeCredentials.create(
        currentPassword: ' oldpassword123 ',
        newPassword: ' new password 123 ',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('Expected Right'), (credentials) {
        expect(credentials.currentPassword.value, ' oldpassword123 ');
        expect(credentials.newPassword.value, ' new password 123 ');
      });
    });
  });
}
