import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_screens.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_targets.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_state.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUserUseCase extends Mock implements RegisterUserUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockAnalyticsTracker extends Mock implements AnalyticsTracker {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RegisterRequestEntity(
        email: 'e',
        password: 'p',
        firstName: 'f',
        lastName: 'l',
      ),
    );
    registerFallbackValue(
      const AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: UserEntity(id: 'u1', email: 'user@example.com'),
      ),
    );
  });

  group('RegisterCubit', () {
    late _MockRegisterUserUseCase registerUser;
    late _MockSessionManager sessionManager;
    late _MockAnalyticsTracker analytics;

    setUp(() {
      registerUser = _MockRegisterUserUseCase();
      sessionManager = _MockSessionManager();
      analytics = _MockAnalyticsTracker();

      when(
        () => analytics.trackButtonClick(
          id: any(named: 'id'),
          screen: any(named: 'screen'),
        ),
      ).thenAnswer((_) async {});

      when(() => sessionManager.login(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = RegisterCubit(registerUser, sessionManager, analytics);
      final emitted = <RegisterState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, RegisterStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.firstNameError?.code,
        ValidationErrorCodes.required,
      );
      expect(emitted.single.lastNameError?.code, ValidationErrorCodes.required);
      expect(
        emitted.single.emailError?.code,
        ValidationErrorCodes.invalidEmail,
      );
      expect(emitted.single.passwordError?.code, ValidationErrorCodes.required);

      verifyNever(() => registerUser(any()));
      verifyNever(() => sessionManager.login(any()));
      verify(
        () => analytics.trackButtonClick(
          id: AuthAnalyticsTargets.registerSubmit,
          screen: AuthAnalyticsScreens.register,
        ),
      ).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test('registers and emits submitting -> success', () async {
      const session = AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: UserEntity(
          id: 'u1',
          email: 'user@example.com',
          firstName: 'Jane',
          lastName: 'Doe',
        ),
      );
      when(() => registerUser(any())).thenAnswer((_) async => right(session));

      final cubit = RegisterCubit(registerUser, sessionManager, analytics);
      final emitted = <RegisterState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.firstNameChanged('Jane');
      cubit.lastNameChanged('Doe');
      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('password123');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 6);
      expect(emitted[4].status, RegisterStatus.submitting);
      expect(emitted[5].status, RegisterStatus.success);

      final captured = verify(() => registerUser(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured.single as RegisterRequestEntity;
      expect(request.email, 'user@example.com');
      expect(request.password, 'password123');
      expect(request.firstName, 'Jane');
      expect(request.lastName, 'Doe');

      verify(() => sessionManager.login(session)).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test(
      'emits submitting -> failure for emailTaken and resets on edit',
      () async {
        when(
          () => registerUser(any()),
        ).thenAnswer((_) async => left(const AuthFailure.emailTaken()));

        final cubit = RegisterCubit(registerUser, sessionManager, analytics);
        final emitted = <RegisterState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.firstNameChanged('Jane');
        cubit.lastNameChanged('Doe');
        cubit.emailChanged('user@example.com');
        cubit.passwordChanged('password123');
        await cubit.submit();
        await pumpEventQueue();

        expect(emitted.length, 6);
        expect(emitted[4].status, RegisterStatus.submitting);
        expect(emitted[5].status, RegisterStatus.failure);
        expect(emitted[5].failure, const AuthFailure.emailTaken());
        expect(emitted[5].emailError?.code, 'email_taken');

        cubit.emailChanged('user@example.com');
        await pumpEventQueue();

        expect(emitted.last.status, RegisterStatus.initial);
        expect(emitted.last.failure, isNull);

        verifyNever(() => sessionManager.login(any()));

        await sub.cancel();
        await cubit.close();
      },
    );
  });
}
