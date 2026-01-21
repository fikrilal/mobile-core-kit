import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_user_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockTokenRefresher extends Mock implements TokenRefresher {}

class _FakeCachedUserStore implements CachedUserStore {
  UserEntity? cachedUser;

  @override
  Future<UserEntity?> read() async => cachedUser;

  @override
  Future<void> write(UserEntity user) async {
    cachedUser = user;
  }

  @override
  Future<void> clear() async {
    cachedUser = null;
  }
}

String _jwtWithExpSeconds(int expSeconds) {
  final header = <String, dynamic>{'alg': 'none', 'typ': 'JWT'};
  final payload = <String, dynamic>{'exp': expSeconds};
  final headerPart = base64Url
      .encode(utf8.encode(jsonEncode(header)))
      .replaceAll('=', '');
  final payloadPart = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return '$headerPart.$payloadPart.signature';
}

void main() {
  test(
    'after login/register, SessionRepositoryImpl.loadSession restores derived expiry (expiresAtMs)',
    () async {
      final store = <String, String>{};
      final storage = _MockFlutterSecureStorage();
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any<String?>(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        final value = invocation.namedArguments[#value] as String?;
        if (value == null) {
          store.remove(key);
        } else {
          store[key] = value;
        }
      });
      when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
        invocation,
      ) async {
        final key = invocation.namedArguments[#key] as String;
        store.remove(key);
      });
      when(() => storage.readAll()).thenAnswer((_) async => Map.from(store));
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((
        invocation,
      ) async {
        final key = invocation.namedArguments[#key] as String;
        return store[key];
      });

      final cachedUserStore = _FakeCachedUserStore();
      final repo = SessionRepositoryImpl(
        cachedUserStore: cachedUserStore,
        secure: TokenSecureStorage(storage),
      );

      final tokenRefresher = _MockTokenRefresher();
      when(() => tokenRefresher.refresh(any())).thenAnswer(
        (_) async => left(const SessionFailure.unexpected()),
      );

      final events = AppEventBus();
      final manager = SessionManager(
        repo,
        tokenRefresher: tokenRefresher,
        events: events,
      );

      final expSeconds =
          DateTime.now()
              .toUtc()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch ~/
          1000;

      final authResult = AuthResultModel(
        user: const AuthUserModel(
          id: 'u1',
          email: 'user@example.com',
          emailVerified: true,
          authMethods: ['PASSWORD'],
        ),
        accessToken: _jwtWithExpSeconds(expSeconds),
        refreshToken: 'refresh',
      );

      final AuthSessionEntity session = authResult.toSessionEntity();
      final savedExpiresIn = session.tokens.expiresIn;
      final savedExpiresAtMs = session.tokens.expiresAt!.millisecondsSinceEpoch;

      await manager.login(session);

      final restored = await repo.loadSession();
      expect(restored, isNotNull);
      expect(restored!.tokens.accessToken, session.tokens.accessToken);
      expect(restored.tokens.refreshToken, session.tokens.refreshToken);
      expect(restored.tokens.tokenType, 'Bearer');
      expect(restored.tokens.expiresIn, savedExpiresIn);
      expect(restored.tokens.expiresAt, isNotNull);
      expect(restored.tokens.expiresAt!.millisecondsSinceEpoch, savedExpiresAtMs);
      expect(restored.user, isNull);

      events.dispose();
      manager.dispose();
    },
  );
}

