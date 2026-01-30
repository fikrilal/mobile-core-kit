import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/resend_email_verification_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/verify_email_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

class _MockResendEmailVerificationUseCase extends Mock
    implements ResendEmailVerificationUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const VerifyEmailRequestEntity(token: 'token'));
  });

  group('EmailVerificationCubit', () {
    late _MockVerifyEmailUseCase verifyEmail;
    late _MockResendEmailVerificationUseCase resendEmailVerification;

    setUp(() {
      verifyEmail = _MockVerifyEmailUseCase();
      resendEmailVerification = _MockResendEmailVerificationUseCase();
    });

    test(
      'emits token error and does not call usecase when token is empty',
      () async {
        final cubit = EmailVerificationCubit(
          verifyEmail,
          resendEmailVerification,
        );
        final emitted = <EmailVerificationState>[];
        final sub = cubit.stream.listen(emitted.add);

        await cubit.verify();
        await pumpEventQueue();

        expect(emitted.length, 1);
        expect(emitted.single.status, EmailVerificationStatus.initial);
        expect(emitted.single.lastAction, EmailVerificationAction.verify);
        expect(emitted.single.failure, isNull);
        expect(emitted.single.tokenError?.code, ValidationErrorCodes.required);

        verifyNever(() => verifyEmail(any()));
        verifyNever(() => resendEmailVerification());

        await sub.cancel();
        await cubit.close();
      },
    );

    test('verifies and emits submitting -> success', () async {
      when(() => verifyEmail(any())).thenAnswer((_) async => right(unit));

      final cubit = EmailVerificationCubit(
        verifyEmail,
        resendEmailVerification,
      );
      final emitted = <EmailVerificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.tokenChanged(' token ');
      await cubit.verify();
      await pumpEventQueue();

      expect(emitted.length, 3);
      expect(emitted[1].status, EmailVerificationStatus.submitting);
      expect(emitted[1].lastAction, EmailVerificationAction.verify);
      expect(emitted[2].status, EmailVerificationStatus.success);
      expect(emitted[2].lastAction, EmailVerificationAction.verify);
      expect(emitted[2].tokenError, isNull);

      verify(
        () => verifyEmail(const VerifyEmailRequestEntity(token: 'token')),
      ).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test(
      'resends verification email and emits submitting -> success',
      () async {
        when(
          () => resendEmailVerification(),
        ).thenAnswer((_) async => right(unit));

        final cubit = EmailVerificationCubit(
          verifyEmail,
          resendEmailVerification,
        );
        final emitted = <EmailVerificationState>[];
        final sub = cubit.stream.listen(emitted.add);

        await cubit.resendVerificationEmail();
        await pumpEventQueue();

        expect(emitted.length, 2);
        expect(emitted[0].status, EmailVerificationStatus.submitting);
        expect(emitted[0].lastAction, EmailVerificationAction.resend);
        expect(emitted[1].status, EmailVerificationStatus.success);
        expect(emitted[1].lastAction, EmailVerificationAction.resend);

        verify(() => resendEmailVerification()).called(1);

        await sub.cancel();
        await cubit.close();
      },
    );

    test('maps validation failure to field error', () async {
      when(() => verifyEmail(any())).thenAnswer(
        (_) async => left(
          AuthFailure.validation(const [
            ValidationError(
              field: 'token',
              message: '',
              code: ValidationErrorCodes.required,
            ),
          ]),
        ),
      );

      final cubit = EmailVerificationCubit(
        verifyEmail,
        resendEmailVerification,
      );
      final emitted = <EmailVerificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.tokenChanged('abc');
      await cubit.verify();
      await pumpEventQueue();

      expect(emitted.length, 3);
      expect(emitted[2].status, EmailVerificationStatus.failure);
      expect(emitted[2].tokenError?.code, ValidationErrorCodes.required);
      expect(emitted[2].lastAction, EmailVerificationAction.verify);

      await sub.cancel();
      await cubit.close();
    });
  });
}
