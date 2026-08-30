import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestPasswordResetUseCase extends Mock
    implements RequestPasswordResetUseCase {}

void main() {
  group('PasswordResetRequestCubit', () {
    late _MockRequestPasswordResetUseCase requestPasswordReset;

    setUp(() {
      requestPasswordReset = _MockRequestPasswordResetUseCase();
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final effects = <PasswordResetRequestEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, PasswordResetRequestStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.emailError?.code,
        ValidationErrorCodes.invalidEmail,
      );
      expect(effects, isEmpty);

      verifyNever(() => requestPasswordReset(any()));

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test('requests reset and emits submitting -> success', () async {
      when(
        () => requestPasswordReset(any()),
      ).thenAnswer((_) async => right(unit));

      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final effects = <PasswordResetRequestEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      cubit.emailChanged(' user@example.com ');
      await cubit.submit();
      await pumpEventQueue();

      expect(
        emitted.any((s) => s.status == PasswordResetRequestStatus.submitting),
        true,
      );
      expect(emitted.last.status, PasswordResetRequestStatus.success);
      expect(effects, hasLength(1));
      expect(effects.single, isA<PasswordResetRequestSuccessEffect>());

      final captured = verify(
        () => requestPasswordReset(captureAny()),
      ).captured;
      expect(captured.length, 1);
      expect(captured.single, ' user@example.com ');

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test('emits failure for tooManyRequests', () async {
      when(
        () => requestPasswordReset(any()),
      ).thenAnswer((_) async => left(const AuthFailure.tooManyRequests()));

      final cubit = PasswordResetRequestCubit(requestPasswordReset);
      final emitted = <PasswordResetRequestState>[];
      final effects = <PasswordResetRequestEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      cubit.emailChanged('user@example.com');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, PasswordResetRequestStatus.failure);
      expect(emitted.last.failure, const AuthFailure.tooManyRequests());
      expect(effects, hasLength(1));
      expect(effects.single, isA<PasswordResetRequestFailureEffect>());

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });
  });
}
