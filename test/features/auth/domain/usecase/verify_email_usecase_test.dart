import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/verify_email_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const VerifyEmailRequestEntity(token: 't'));
  });

  group('VerifyEmailUseCase', () {
    test(
      'returns validation failure and does not call repo when token is empty',
      () async {
        final repo = _MockAuthRepository();
        final usecase = VerifyEmailUseCase(repo);

        final result = await usecase(
          const VerifyEmailRequestEntity(token: ' '),
        );

        expect(result.isLeft(), true);
        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'token',
                message: '',
                code: ValidationErrorCodes.required,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.verifyEmail(any()));
      },
    );

    test('normalizes token before calling repo', () async {
      final repo = _MockAuthRepository();
      when(() => repo.verifyEmail(any())).thenAnswer((_) async => right(unit));

      final usecase = VerifyEmailUseCase(repo);

      final result = await usecase(
        const VerifyEmailRequestEntity(token: ' token '),
      );

      expect(result.isRight(), true);

      final captured = verify(() => repo.verifyEmail(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured.single as VerifyEmailRequestEntity;
      expect(request.token, 'token');
    });
  });
}
