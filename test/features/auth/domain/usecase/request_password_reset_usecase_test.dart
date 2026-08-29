import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      EmailAddress.create('t@t.com').getOrElse((_) => throw StateError('')),
    );
  });

  group('RequestPasswordResetUseCase', () {
    test(
      'returns validation failure and does not call repo when email invalid',
      () async {
        final repo = _MockAuthRepository();
        final usecase = RequestPasswordResetUseCase(repo);

        final result = await usecase(' ');

        expect(result.isLeft(), true);
        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'email',
                message: '',
                code: ValidationErrorCodes.invalidEmail,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.requestPasswordReset(any()));
      },
    );

    test('normalizes email before calling repo', () async {
      final repo = _MockAuthRepository();
      when(
        () => repo.requestPasswordReset(any()),
      ).thenAnswer((_) async => right(unit));

      final usecase = RequestPasswordResetUseCase(repo);

      final result = await usecase(' user@example.com ');

      expect(result.isRight(), true);

      final captured = verify(
        () => repo.requestPasswordReset(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final email = captured.single as EmailAddress;
      expect(email.value, 'user@example.com');
    });
  });
}
