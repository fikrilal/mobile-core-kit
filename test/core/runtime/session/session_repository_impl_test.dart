import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/infra/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/core/runtime/session/session_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakeCachedUserStore implements CachedUserStore {
  var readCount = 0;
  var writeCount = 0;
  var clearCount = 0;
  UserEntity? _cachedUser;

  @override
  Future<UserEntity?> read() async {
    readCount++;
    return _cachedUser;
  }

  @override
  Future<void> write(UserEntity user) async {
    writeCount++;
    _cachedUser = user;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    _cachedUser = null;
  }
}

void main() {
  group('SessionRepositoryImpl.saveSession', () {
    test('writes secure tokens and caches user when provided', () async {
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
      final repository = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      const user = UserEntity(id: 'u1', email: 'user@example.com');
      final expiresAt = DateTime(2026, 1, 1, 0, 0, 0);

      await repository.saveSession(
        AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
            expiresAt: expiresAt,
          ),
          user: user,
        ),
      );

      expect(cachedUserStore.writeCount, 1);
      expect(cachedUserStore.clearCount, 0);
      expect(await cachedUserStore.read(), user);

      verify(
        () => storage.write(key: 'access_token', value: 'access'),
      ).called(1);
      verify(
        () => storage.write(key: 'refresh_token', value: 'refresh'),
      ).called(1);
      verify(() => storage.write(key: 'expires_in', value: '900')).called(1);
      verify(
        () => storage.write(
          key: 'expires_at_ms',
          value: expiresAt.millisecondsSinceEpoch.toString(),
        ),
      ).called(1);
    });

    test('clears cached user when persisting tokens-only session', () async {
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
      final repository = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      await cachedUserStore.write(
        const UserEntity(id: 'stale', email: 'stale@example.com'),
      );

      await repository.saveSession(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      expect(cachedUserStore.clearCount, 1);
      expect(await cachedUserStore.read(), isNull);
      verify(() => storage.delete(key: 'expires_at_ms')).called(1);
    });
  });

  group('SessionRepositoryImpl.loadSession', () {
    test('returns null when access token is missing', () async {
      final storage = _MockFlutterSecureStorage();
      when(() => storage.readAll()).thenAnswer(
        (_) async => {'refresh_token': 'refresh', 'expires_in': '900'},
      );

      final repository = SessionRepositoryImpl(
        cachedUserStore: _FakeCachedUserStore(),
        secure: TokenSecureStorage(storage),
      );

      final session = await repository.loadSession();
      expect(session, isNull);
    });

    test('returns null when refresh token is missing', () async {
      final storage = _MockFlutterSecureStorage();
      when(() => storage.readAll()).thenAnswer(
        (_) async => {'access_token': 'access', 'expires_in': '900'},
      );

      final repository = SessionRepositoryImpl(
        cachedUserStore: _FakeCachedUserStore(),
        secure: TokenSecureStorage(storage),
      );

      final session = await repository.loadSession();
      expect(session, isNull);
    });

    test('returns null when expiry is missing or invalid', () async {
      final storage = _MockFlutterSecureStorage();
      when(() => storage.readAll()).thenAnswer(
        (_) async => {
          'access_token': 'access',
          'refresh_token': 'refresh',
          'expires_in': 'not-an-int',
        },
      );

      final repository = SessionRepositoryImpl(
        cachedUserStore: _FakeCachedUserStore(),
        secure: TokenSecureStorage(storage),
      );

      final session = await repository.loadSession();
      expect(session, isNull);
    });

    test('maps persisted token fields to AuthSessionEntity', () async {
      final storage = _MockFlutterSecureStorage();
      const expiresAtMs = 1700000000000;
      when(() => storage.readAll()).thenAnswer(
        (_) async => {
          'access_token': 'access',
          'refresh_token': 'refresh',
          'expires_in': '900',
          'expires_at_ms': '$expiresAtMs',
        },
      );

      final repository = SessionRepositoryImpl(
        cachedUserStore: _FakeCachedUserStore(),
        secure: TokenSecureStorage(storage),
      );

      final session = await repository.loadSession();
      expect(session, isNotNull);
      expect(session?.tokens.accessToken, 'access');
      expect(session?.tokens.refreshToken, 'refresh');
      expect(session?.tokens.tokenType, 'Bearer');
      expect(session?.tokens.expiresIn, 900);
      expect(
        session?.tokens.expiresAt,
        DateTime.fromMillisecondsSinceEpoch(expiresAtMs),
      );
      expect(session?.user, isNull);
    });
  });

  group('SessionRepositoryImpl.loadCachedUser', () {
    test('delegates to cached user store', () async {
      final cachedUserStore = _FakeCachedUserStore();
      await cachedUserStore.write(
        const UserEntity(id: 'u1', email: 'user@example.com'),
      );

      final storage = _MockFlutterSecureStorage();
      when(() => storage.readAll()).thenAnswer((_) async => {});

      final repository = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      final user = await repository.loadCachedUser();
      expect(user?.id, 'u1');
      expect(cachedUserStore.readCount, 1);
    });
  });

  group('SessionRepositoryImpl.clearSession', () {
    test('clears secure tokens and cached user store', () async {
      final storage = _MockFlutterSecureStorage();
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      final cachedUserStore = _FakeCachedUserStore();
      await cachedUserStore.write(
        const UserEntity(id: 'u1', email: 'user@example.com'),
      );

      final repository = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      await repository.clearSession();

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
      verify(() => storage.delete(key: 'expires_in')).called(1);
      verify(() => storage.delete(key: 'expires_at_ms')).called(1);
      expect(cachedUserStore.clearCount, 1);
      expect(await cachedUserStore.read(), isNull);
    });
  });
}
