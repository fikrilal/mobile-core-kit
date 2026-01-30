import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_screens.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_targets.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/sign_in_with_google_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUserUseCase extends Mock implements LoginUserUseCase {}

class _MockGoogleSignInUseCase extends Mock
    implements SignInWithGoogleUseCase {}

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
    late _MockGoogleSignInUseCase googleSignIn;
    late _MockSessionManager sessionManager;
    late _MockAnalyticsTracker analytics;

    setUp(() {
      loginUser = _MockLoginUserUseCase();
      googleSignIn = _MockGoogleSignInUseCase();
      sessionManager = _MockSessionManager();
      analytics = _MockAnalyticsTracker();

      when(
        () => analytics.trackButtonClick(
          id: any(named: 'id'),
          screen: any(named: 'screen'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => analytics.trackLogin(method: any(named: 'method')),
      ).thenAnswer((_) async {});

      when(() => sessionManager.login(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = LoginCubit(
        loginUser,
        googleSignIn,
        sessionManager,
        analytics,
      );
      final emitted = <LoginState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, LoginStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.emailError?.code,
        ValidationErrorCodes.invalidEmail,
      );
      expect(emitted.single.passwordError?.code, ValidationErrorCodes.required);

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

      final cubit = LoginCubit(
        loginUser,
        googleSignIn,
        sessionManager,
        analytics,
      );
      final emitted = <LoginState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('password');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 4);
      expect(emitted[2].status, LoginStatus.submitting);
      expect(emitted[2].submittingMethod, LoginSubmitMethod.emailPassword);
      expect(emitted[3].status, LoginStatus.success);
      expect(emitted[3].submittingMethod, isNull);

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

    test(
      'emits submitting -> failure for invalid credentials and resets on edit',
      () async {
        when(
          () => loginUser(any()),
        ).thenAnswer((_) async => left(const AuthFailure.invalidCredentials()));

        final cubit = LoginCubit(
          loginUser,
          googleSignIn,
          sessionManager,
          analytics,
        );
        final emitted = <LoginState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.emailChanged('user@example.com');
        cubit.passwordChanged('password');
        await cubit.submit();
        await pumpEventQueue();

        expect(emitted.length, 4);
        expect(emitted[3].status, LoginStatus.failure);
        expect(emitted[3].failure, const AuthFailure.invalidCredentials());

        cubit.emailChanged('user@example.com');
        await pumpEventQueue();

        expect(emitted.last.status, LoginStatus.initial);
        expect(emitted.last.failure, isNull);

        verifyNever(() => sessionManager.login(any()));
        verifyNever(() => analytics.trackLogin(method: any(named: 'method')));

        await sub.cancel();
        await cubit.close();
      },
    );
  });
}
