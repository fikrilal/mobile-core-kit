import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockTokenRefresher extends Mock implements TokenRefresher {}

class _FakeCachedUserStore implements CachedUserStore {
  UserEntity? cachedUser;
  var clearCount = 0;

  @override
  Future<UserEntity?> read() async => cachedUser;

  @override
  Future<void> write(UserEntity user) async {
    cachedUser = user;
  }

  @override
  Future<void> clear() async {
    cachedUser = null;
    clearCount++;
  }
}

void main() {
  group('SessionManager.refreshTokens (persistence)', () {
    test('unauthenticated refresh clears secure tokens and cached user', () async {
      final storage = _MockFlutterSecureStorage();
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any<String?>(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      final cachedUserStore = _FakeCachedUserStore();
      final repo = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      final tokenRefresher = _MockTokenRefresher();
      when(
        () => tokenRefresher.refresh(any()),
      ).thenAnswer((_) async => left(const SessionFailure.unauthenticated()));

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
            accessToken: 'access_old',
            refreshToken: 'refresh_old',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: user,
        ),
      );

      expect(cachedUserStore.cachedUser, user);

      clearInteractions(storage);
      cachedUserStore.clearCount = 0;

      final ok = await manager.refreshTokens();
      expect(ok, false);
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

