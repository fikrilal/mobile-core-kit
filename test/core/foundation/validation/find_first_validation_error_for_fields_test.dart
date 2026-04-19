import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/find_first_validation_error_for_fields.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';

void main() {
  group('findFirstValidationErrorForFields', () {
    test('returns exact field match first', () {
      const errors = [
        ValidationError(field: 'email', message: 'Email invalid', code: 'x'),
        ValidationError(field: 'password', message: 'Password invalid'),
      ];

      final result = findFirstValidationErrorForFields(errors, ['email']);

      expect(result, errors.first);
    });

    test('returns suffix field match', () {
      const errors = [
        ValidationError(
          field: 'profile.givenName',
          message: 'Given name invalid',
        ),
      ];

      final result = findFirstValidationErrorForFields(errors, ['givenName']);

      expect(result, errors.first);
    });

    test('ignores null or empty fields', () {
      const errors = [
        ValidationError(field: null, message: 'Ignored'),
        ValidationError(field: '', message: 'Ignored'),
        ValidationError(field: 'email', message: 'Email invalid'),
      ];

      final result = findFirstValidationErrorForFields(errors, ['email']);

      expect(result, errors.last);
    });

    test('returns null when no candidate matches', () {
      const errors = [
        ValidationError(field: 'email', message: 'Email invalid'),
      ];

      final result = findFirstValidationErrorForFields(errors, ['token']);

      expect(result, isNull);
    });
  });
}
