import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/input/profile_update_input.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/profile_details.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ProfileDetails.create(
        givenName: 'Jo',
      ).getOrElse((_) => throw StateError('')),
    );
  });

  group('PatchMeProfileUseCase', () {
    test(
      'returns validation failure and does not call repo when invalid',
      () async {
        final repo = _MockProfileRepository();
        final usecase = PatchMeProfileUseCase(repo);

        final result = await usecase(
          const ProfileUpdateInput(
            givenName: ' ',
            familyName: 'A',
            displayName: ' ',
          ),
        );

        expect(result.isLeft(), true);

        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'givenName',
                message: '',
                code: ValidationErrorCodes.required,
              ),
              ValidationError(
                field: 'familyName',
                message: '',
                code: ValidationErrorCodes.nameTooShort,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.patchMeProfile(any()));
      },
    );

    test('normalizes fields before calling repo', () async {
      final repo = _MockProfileRepository();
      const user = UserEntity(id: 'u1', email: 'user@example.com');

      when(
        () => repo.patchMeProfile(any()),
      ).thenAnswer((_) async => right(user));

      final usecase = PatchMeProfileUseCase(repo);

      final result = await usecase(
        const ProfileUpdateInput(
          givenName: ' John ',
          familyName: ' Doe ',
          displayName: '  John Doe  ',
        ),
      );

      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value, user),
      );

      final captured = verify(() => repo.patchMeProfile(captureAny())).captured;
      expect(captured.length, 1);
      final details = captured.single as ProfileDetails;
      expect(details.givenName.value, 'John');
      expect(details.familyName?.value, 'Doe');
      expect(details.displayName, 'John Doe');
    });
  });
}
