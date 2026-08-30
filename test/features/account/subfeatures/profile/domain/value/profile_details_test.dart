import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/profile_details.dart';

void main() {
  group('ProfileDetails', () {
    test('collects given and family name failures', () {
      final result = ProfileDetails.create(givenName: ' ', familyName: 'A');

      expect(result.isLeft(), true);
      result.match(
        (errors) => expect(errors, [
          const ValidationError(
            field: 'givenName',
            message: '',
            code: ValidationErrorCodes.required,
          ),
          const ValidationError(
            field: 'familyName',
            message: '',
            code: ValidationErrorCodes.nameTooShort,
          ),
        ]),
        (_) => fail('Expected Left'),
      );
    });

    test('normalizes names and blanks the display name', () {
      final result = ProfileDetails.create(
        givenName: ' John ',
        familyName: ' Doe ',
        displayName: '   ',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('Expected Right'), (details) {
        expect(details.givenName.value, 'John');
        expect(details.familyName?.value, 'Doe');
        expect(details.displayName, isNull);
      });
    });

    test('trims a nonblank display name without a length rule', () {
      final longDisplayName = 'x' * 120;

      final result = ProfileDetails.create(
        givenName: 'John',
        displayName: '  $longDisplayName  ',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('Expected Right'), (details) {
        expect(details.displayName, longDisplayName);
        expect(details.familyName, isNull);
      });
    });
  });
}
