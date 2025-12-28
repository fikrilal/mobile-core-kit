import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_screens.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_targets.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_state.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

class _MockLoginUserUseCase extends Mock implements LoginUserUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockAnalyticsTracker extends Mock implements AnalyticsTracker {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginRequestEntity(email: 'e', password: 'p'));
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

  group('LoginCubit', () {
    late _MockLoginUserUseCase loginUser;
    late _MockSessionManager sessionManager;
    late _MockAnalyticsTracker analytics;

    setUp(() {
      loginUser = _MockLoginUserUseCase();
      sessionManager = _MockSessionManager();
      analytics = _MockAnalyticsTracker();

      when(
        () => analytics.trackButtonClick(
          id: any(named: 'id'),
          screen: any(named: 'screen'),
        ),
      ).thenAnswer((_) async {});

      when(() => analytics.trackLogin(method: any(named: 'method')))
          .thenAnswer((_) async {});

      when(() => sessionManager.login(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = LoginCubit(loginUser, sessionManager, analytics);
      final emitted = <LoginState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, LoginStatus.initial);
      expect(emitted.single.emailError, 'Please enter a valid email address');
      expect(emitted.single.passwordError, 'This field cannot be empty');

      verifyNever(() => loginUser(any()));
      verifyNever(() => sessionManager.login(any()));
      verify(
        () => analytics.trackButtonClick(
          id: AuthAnalyticsTargets.signInSubmit,
          screen: AuthAnalyticsScreens.signIn,
        ),
      ).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test('logs in and emits submitting -> success', () async {
      const session = AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: UserEntity(id: 'u1', email: 'user@example.com'),
      );
      when(() => loginUser(any())).thenAnswer((_) async => right(session));

      final cubit = LoginCubit(loginUser, sessionManager, analytics);
      final emitted = <LoginState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('password');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 4);
      expect(emitted[2].status, LoginStatus.submitting);
      expect(emitted[3].status, LoginStatus.success);

      final captured = verify(() => loginUser(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured.single as LoginRequestEntity;
      expect(request.email, 'user@example.com');
      expect(request.password, 'password');

      verify(() => sessionManager.login(session)).called(1);
      verify(() => analytics.trackLogin(method: 'email_password')).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test('emits submitting -> failure for invalid credentials and resets on edit',
        () async {
      when(
        () => loginUser(any()),
      ).thenAnswer((_) async => left(const AuthFailure.invalidCredentials()));

      final cubit = LoginCubit(loginUser, sessionManager, analytics);
      final emitted = <LoginState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('password');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 4);
      expect(emitted[3].status, LoginStatus.failure);
      expect(emitted[3].errorMessage, 'Invalid email or password');

      cubit.emailChanged('user@example.com');
      await pumpEventQueue();

      expect(emitted.last.status, LoginStatus.initial);
      expect(emitted.last.errorMessage, isNull);

      verifyNever(() => sessionManager.login(any()));
      verifyNever(() => analytics.trackLogin(method: any(named: 'method')));

      await sub.cancel();
      await cubit.close();
    });
  });
}

