import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/infra/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_push_token_revoker.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_remote_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogoutRemoteUseCase extends Mock implements LogoutRemoteUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockPushTokenRevoker extends Mock implements SessionPushTokenRevoker {}

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
  group('LogoutFlowUseCase', () {
    setUpAll(() {
      registerFallbackValue(
        const LogoutRequestEntity(refreshToken: 'fallback'),
      );
    });

    test(
      'calls remote logout (best-effort) then clears local session',
      () async {
        final logoutRemote = _MockLogoutRemoteUseCase();
        when(() => logoutRemote(any())).thenAnswer((_) async => right(unit));

        final pushTokenRevoker = _MockPushTokenRevoker();
        when(() => pushTokenRevoker.revoke()).thenAnswer((_) async {});

        final sessionManager = _MockSessionManager();
        when(() => sessionManager.session).thenReturn(
          const AuthSessionEntity(
            tokens: AuthTokensEntity(
              accessToken: 'access',
              refreshToken: 'refresh_123',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
            user: UserEntity(id: 'u1', email: 'user@example.com'),
          ),
        );
        when(
          () => sessionManager.logout(reason: any(named: 'reason')),
        ).thenAnswer((_) async {});

        final usecase = LogoutFlowUseCase(
          logoutRemote: logoutRemote,
          pushTokenRevoker: pushTokenRevoker,
          sessionManager: sessionManager,
        );

        await usecase(reason: 'manual_logout');

        verifyInOrder([
          () => pushTokenRevoker.revoke(),
          () => logoutRemote(
            const LogoutRequestEntity(refreshToken: 'refresh_123'),
          ),
          () => sessionManager.logout(reason: 'manual_logout'),
        ]);
      },
    );

    test(
      'still clears local session when remote logout returns failure',
      () async {
        final logoutRemote = _MockLogoutRemoteUseCase();
        when(
          () => logoutRemote(any()),
        ).thenAnswer((_) async => left(const AuthFailure.network()));

        final pushTokenRevoker = _MockPushTokenRevoker();
        when(() => pushTokenRevoker.revoke()).thenAnswer((_) async {});

        final sessionManager = _MockSessionManager();
        when(() => sessionManager.session).thenReturn(
          const AuthSessionEntity(
            tokens: AuthTokensEntity(
              accessToken: 'access',
              refreshToken: 'refresh_123',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
          ),
        );
        when(
          () => sessionManager.logout(reason: any(named: 'reason')),
        ).thenAnswer((_) async {});

        final usecase = LogoutFlowUseCase(
          logoutRemote: logoutRemote,
          pushTokenRevoker: pushTokenRevoker,
          sessionManager: sessionManager,
        );

        await usecase(reason: 'manual_logout');

        verify(() => sessionManager.logout(reason: 'manual_logout')).called(1);
      },
    );

    test('still clears local session when push revoke throws', () async {
      final logoutRemote = _MockLogoutRemoteUseCase();
      when(() => logoutRemote(any())).thenAnswer((_) async => right(unit));

      final pushTokenRevoker = _MockPushTokenRevoker();
      when(
        () => pushTokenRevoker.revoke(),
      ).thenThrow(Exception('revoke failed'));

      final sessionManager = _MockSessionManager();
      when(() => sessionManager.session).thenReturn(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh_123',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutRemote: logoutRemote,
        pushTokenRevoker: pushTokenRevoker,
        sessionManager: sessionManager,
      );

      await usecase(reason: 'manual_logout');

      verify(() => pushTokenRevoker.revoke()).called(1);
      verify(
        () => logoutRemote(
          const LogoutRequestEntity(refreshToken: 'refresh_123'),
        ),
      ).called(1);
      verify(() => sessionManager.logout(reason: 'manual_logout')).called(1);
    });

    test('skips remote logout when there is no session', () async {
      final logoutRemote = _MockLogoutRemoteUseCase();
      final pushTokenRevoker = _MockPushTokenRevoker();
      final sessionManager = _MockSessionManager();

      when(() => sessionManager.session).thenReturn(null);
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutRemote: logoutRemote,
        pushTokenRevoker: pushTokenRevoker,
        sessionManager: sessionManager,
      );

      await usecase(reason: 'manual_logout');

      verifyNever(() => logoutRemote(any()));
      verifyNever(() => pushTokenRevoker.revoke());
      verify(() => sessionManager.logout(reason: 'manual_logout')).called(1);
    });

    test('clears cached user when clearing local session', () async {
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
      final repo = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      final tokenRefresher = _MockTokenRefresher();
      final events = AppEventBus();
      final manager = SessionManager(
        repo,
        tokenRefresher: tokenRefresher,
        events: events,
      );

      const user = UserEntity(id: 'u1', email: 'user@example.com');
      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh_123',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: user,
        ),
      );
      expect(cachedUserStore.cachedUser, user);

      clearInteractions(storage);
      cachedUserStore.clearCount = 0;

      final logoutRemote = _MockLogoutRemoteUseCase();
      when(() => logoutRemote(any())).thenAnswer((_) async => right(unit));

      final pushTokenRevoker = _MockPushTokenRevoker();
      when(() => pushTokenRevoker.revoke()).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutRemote: logoutRemote,
        pushTokenRevoker: pushTokenRevoker,
        sessionManager: manager,
      );

      await usecase(reason: 'manual_logout');

      expect(manager.session, isNull);
      expect(cachedUserStore.cachedUser, isNull);
      expect(cachedUserStore.clearCount, 1);

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
      verify(() => storage.delete(key: 'expires_in')).called(1);
      verify(() => storage.delete(key: 'expires_at_ms')).called(1);

      events.dispose();
      manager.dispose();
    });
  });
}
