import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/infra/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/sign_in_with_google_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUserUseCase extends Mock implements LoginUserUseCase {}

class _MockGoogleSignInUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class _MockAnalyticsTracker extends Mock implements AnalyticsTracker {}

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockTokenRefresher extends Mock implements TokenRefresher {}

class _FakeCachedUserStore implements CachedUserStore {
  UserEntity? cachedUser;
  var writeCount = 0;
  var clearCount = 0;

  @override
  Future<UserEntity?> read() async => cachedUser;

  @override
  Future<void> write(UserEntity user) async {
    cachedUser = user;
    writeCount++;
  }

  @override
  Future<void> clear() async {
    cachedUser = null;
    clearCount++;
  }
}

void main() {
  group('LoginCubit (persistence)', () {
    setUpAll(() {
      registerFallbackValue(
        const LoginRequestEntity(email: 'fallback@example.com', password: 'p'),
      );
    });

    test('successful login persists cached user via SessionManager', () async {
      final loginUser = _MockLoginUserUseCase();
      final googleSignIn = _MockGoogleSignInUseCase();
      final analytics = _MockAnalyticsTracker();

      when(
        () => analytics.trackButtonClick(
          id: any(named: 'id'),
          screen: any(named: 'screen'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => analytics.trackLogin(method: any(named: 'method')),
      ).thenAnswer((_) async {});

      const user = UserEntity(id: 'u1', email: 'user@example.com');
      const session = AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: user,
      );
      when(() => loginUser(any())).thenAnswer((_) async => right(session));

      final storage = _MockFlutterSecureStorage();
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any<String?>(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      final cachedUserStore = _FakeCachedUserStore();
      final sessionRepo = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      final tokenRefresher = _MockTokenRefresher();
      final events = AppEventBus();
      final sessionManager = SessionManager(
        sessionRepo,
        tokenRefresher: tokenRefresher,
        events: events,
      );

      final cubit = LoginCubit(
        loginUser,
        googleSignIn,
        sessionManager,
        analytics,
      );

      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('password');
      await cubit.submit();
      await pumpEventQueue();

      expect(sessionManager.isAuthenticated, true);
      expect(sessionManager.session?.user, user);
      expect(cachedUserStore.cachedUser, user);
      expect(cachedUserStore.writeCount, 1);
      expect(cachedUserStore.clearCount, 0);

      await cubit.close();
      events.dispose();
      sessionManager.dispose();
    });
  });
}
