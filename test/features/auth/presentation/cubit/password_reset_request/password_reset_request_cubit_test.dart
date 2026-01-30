import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestPasswordResetUseCase extends Mock
    implements RequestPasswordResetUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PasswordResetRequestEntity(email: 't@t.com'));
  });

  group('PasswordResetRequestCubit', () {
    late _MockRequestPasswordResetUseCase requestPasswordReset;

    setUp(() {
      requestPasswordReset = _MockRequestPasswordResetUseCase();
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, PasswordResetRequestStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.emailError?.code,
        ValidationErrorCodes.invalidEmail,
      );

      verifyNever(() => requestPasswordReset(any()));

      await sub.cancel();
      await cubit.close();
    });

    test('requests reset and emits submitting -> success', () async {
      when(
        () => requestPasswordReset(any()),
      ).thenAnswer((_) async => right(unit));

      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.emailChanged(' user@example.com ');
      await cubit.submit();
      await pumpEventQueue();

      expect(
        emitted.any((s) => s.status == PasswordResetRequestStatus.submitting),
        true,
      );
      expect(emitted.last.status, PasswordResetRequestStatus.success);

      final captured = verify(
        () => requestPasswordReset(captureAny()),
      ).captured;
      expect(captured.length, 1);
      expect(
        captured.single,
        const PasswordResetRequestEntity(email: 'user@example.com'),
      );

      await sub.cancel();
      await cubit.close();
    });

    test('emits failure for tooManyRequests', () async {
      when(
        () => requestPasswordReset(any()),
      ).thenAnswer((_) async => left(const AuthFailure.tooManyRequests()));

      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.emailChanged('user@example.com');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, PasswordResetRequestStatus.failure);
      expect(emitted.last.failure, const AuthFailure.tooManyRequests());

      await sub.cancel();
      await cubit.close();
    });
  });
}
