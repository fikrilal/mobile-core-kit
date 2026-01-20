import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/refresh_token_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockRefreshTokenUsecase extends Mock implements RefreshTokenUsecase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RefreshRequestEntity(refreshToken: 'refresh'));
    registerFallbackValue(
      AuthSessionEntity(
        tokens: const AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: const UserEntity(id: 'id', email: 'email@example.com'),
      ),
    );
  });

  group('SessionManager.restoreCachedUserIfNeeded', () {
    test('does nothing when signed out', () async {
      final repo = _MockSessionRepository();
      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.restoreCachedUserIfNeeded();

      verifyNever(() => repo.loadCachedUser());

      events.dispose();
      manager.dispose();
    });

    test('does nothing when user is already available', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        AuthSessionEntity(
          tokens: const AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: const UserEntity(id: 'u1', email: 'user@example.com'),
        ),
      );

      await manager.restoreCachedUserIfNeeded();

      verifyNever(() => repo.loadCachedUser());

      events.dispose();
      manager.dispose();
    });

    test('restores cached user when auth is pending', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      when(
        () => repo.loadCachedUser(),
      ).thenAnswer(
        (_) async => const UserEntity(id: 'u1', email: 'cached@example.com'),
      );

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      await manager.restoreCachedUserIfNeeded();

      expect(manager.session?.user?.id, 'u1');
      expect(manager.session?.user?.email, 'cached@example.com');
      verify(() => repo.loadCachedUser()).called(1);

      events.dispose();
      manager.dispose();
    });

    test('dedupes concurrent restores (single-flight)', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      final cachedUserCompleter = Completer<UserEntity?>();
      when(
        () => repo.loadCachedUser(),
      ).thenAnswer((_) => cachedUserCompleter.future);

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      final f1 = manager.restoreCachedUserIfNeeded();
      final f2 = manager.restoreCachedUserIfNeeded();

      verify(() => repo.loadCachedUser()).called(1);

      cachedUserCompleter.complete(
        const UserEntity(id: 'u1', email: 'cached@example.com'),
      );

      await f1;
      await f2;

      expect(manager.session?.user?.email, 'cached@example.com');

      events.dispose();
      manager.dispose();
    });

    test('ignores cached user if session changes mid-flight', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});

      final cachedUserCompleter = Completer<UserEntity?>();
      when(
        () => repo.loadCachedUser(),
      ).thenAnswer((_) => cachedUserCompleter.future);

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access_a',
            refreshToken: 'refresh_a',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      final restoreFuture = manager.restoreCachedUserIfNeeded();

      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access_b',
            refreshToken: 'refresh_b',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      cachedUserCompleter.complete(
        const UserEntity(id: 'u1', email: 'cached@example.com'),
      );

      await restoreFuture;

      expect(manager.session?.tokens.accessToken, 'access_b');
      expect(manager.session?.user, isNull);

      events.dispose();
      manager.dispose();
    });

    test('ignores cached user if session is cleared mid-flight', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      when(() => repo.clearSession()).thenAnswer((_) async {});

      final cachedUserCompleter = Completer<UserEntity?>();
      when(
        () => repo.loadCachedUser(),
      ).thenAnswer((_) => cachedUserCompleter.future);

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );

      final restoreFuture = manager.restoreCachedUserIfNeeded();

      await manager.logout(reason: 'manual_logout');

      cachedUserCompleter.complete(
        const UserEntity(id: 'u1', email: 'cached@example.com'),
      );

      await restoreFuture;

      expect(manager.session, isNull);

      events.dispose();
      manager.dispose();
    });
  });

  group('SessionManager.logout', () {
    test('clears session and publishes SessionCleared', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      when(() => repo.clearSession()).thenAnswer((_) async {});

      final refreshUsecase = _MockRefreshTokenUsecase();
      final events = AppEventBus();
      final emitted = <AppEvent>[];
      final sub = events.stream.listen(emitted.add);

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      await manager.login(
        AuthSessionEntity(
          tokens: const AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: const UserEntity(id: 'u1', email: 'user@example.com'),
        ),
      );

      await manager.logout(reason: 'manual_logout');

      verify(() => repo.clearSession()).called(1);
      expect(manager.session, isNull);

      await Future<void>.delayed(Duration.zero);
      expect(emitted.whereType<SessionCleared>().length, 1);
      expect(emitted.whereType<SessionCleared>().single.reason, 'manual_logout');

      await sub.cancel();
      events.dispose();
      manager.dispose();
    });
  });

  group('SessionManager.refreshTokens', () {
    test(
      'logs out only when unauthenticated (e.g. invalid refresh token)',
      () async {
        final repo = _MockSessionRepository();
        when(() => repo.saveSession(any())).thenAnswer((_) async {});
        when(() => repo.clearSession()).thenAnswer((_) async {});

        final refreshUsecase = _MockRefreshTokenUsecase();
        when(
          () => refreshUsecase(any()),
        ).thenAnswer((_) async => left(const AuthFailure.unauthenticated()));

        final events = AppEventBus();
        final emitted = <AppEvent>[];
        final sub = events.stream.listen(emitted.add);

        final manager = SessionManager(
          repo,
          refreshUsecase: refreshUsecase,
          events: events,
        );

        await manager.login(
          AuthSessionEntity(
            tokens: const AuthTokensEntity(
              accessToken: 'access_old',
              refreshToken: 'refresh_old',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
            user: const UserEntity(id: 'u1', email: 'user@example.com'),
          ),
        );

        final ok = await manager.refreshTokens();
        expect(ok, false);
        expect(manager.session, isNull);

        verify(() => repo.clearSession()).called(1);

        // Allow the event bus stream to deliver published events.
        await Future<void>.delayed(Duration.zero);

        expect(emitted.whereType<SessionExpired>().length, 1);
        expect(emitted.whereType<SessionCleared>().length, 1);
        expect(
          emitted.whereType<SessionExpired>().single.reason,
          'refresh_failed',
        );
        expect(
          emitted.whereType<SessionCleared>().single.reason,
          'refresh_failed',
        );

        await sub.cancel();
        events.dispose();
        manager.dispose();
      },
    );

    test('does not log out on transient failures (e.g. network)', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      when(() => repo.clearSession()).thenAnswer((_) async {});

      final refreshUsecase = _MockRefreshTokenUsecase();
      when(
        () => refreshUsecase(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final events = AppEventBus();
      final emitted = <AppEvent>[];
      final sub = events.stream.listen(emitted.add);

      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      final initialSession = AuthSessionEntity(
        tokens: const AuthTokensEntity(
          accessToken: 'access_old',
          refreshToken: 'refresh_old',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: const UserEntity(id: 'u1', email: 'user@example.com'),
      );

      await manager.login(initialSession);

      final ok = await manager.refreshTokens();
      expect(ok, false);
      expect(manager.session, isNotNull);
      expect(
        manager.session?.tokens.accessToken,
        initialSession.tokens.accessToken,
      );
      expect(
        manager.session?.tokens.refreshToken,
        initialSession.tokens.refreshToken,
      );
      expect(
        manager.session?.tokens.expiresIn,
        initialSession.tokens.expiresIn,
      );
      expect(manager.session?.user, initialSession.user);

      verifyNever(() => repo.clearSession());
      expect(emitted.whereType<SessionExpired>(), isEmpty);

      await sub.cancel();
      events.dispose();
      manager.dispose();
    });

    test('persists updated tokens on success', () async {
      final repo = _MockSessionRepository();
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
      when(() => repo.clearSession()).thenAnswer((_) async {});

      final refreshUsecase = _MockRefreshTokenUsecase();
      const newTokens = AuthTokensEntity(
        accessToken: 'access_new',
        refreshToken: 'refresh_new',
        tokenType: 'Bearer',
        expiresIn: 900,
      );
      when(
        () => refreshUsecase(any()),
      ).thenAnswer((_) async => right(newTokens));

      final events = AppEventBus();
      final manager = SessionManager(
        repo,
        refreshUsecase: refreshUsecase,
        events: events,
      );

      final initialSession = AuthSessionEntity(
        tokens: const AuthTokensEntity(
          accessToken: 'access_old',
          refreshToken: 'refresh_old',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: const UserEntity(id: 'u1', email: 'user@example.com'),
      );

      await manager.login(initialSession);

      final ok = await manager.refreshTokens();
      expect(ok, true);
      expect(manager.session?.tokens.accessToken, newTokens.accessToken);
      expect(manager.session?.tokens.refreshToken, newTokens.refreshToken);
      expect(manager.session?.tokens.tokenType, newTokens.tokenType);
      expect(manager.session?.tokens.expiresIn, newTokens.expiresIn);
      expect(manager.session?.tokens.expiresAt, isNotNull);
      expect(manager.session?.user, initialSession.user);

      final captured = verify(() => repo.saveSession(captureAny())).captured;
      expect(captured.length, 2); // login + refresh update
      final last = captured.last as AuthSessionEntity;
      expect(last.tokens.accessToken, newTokens.accessToken);
      expect(last.tokens.refreshToken, newTokens.refreshToken);
      expect(last.tokens.tokenType, newTokens.tokenType);
      expect(last.tokens.expiresIn, newTokens.expiresIn);
      expect(last.tokens.expiresAt, isNotNull);
      expect(last.user, initialSession.user);

      events.dispose();
      manager.dispose();
    });

    test(
      'does not persist tokens if session is cleared during refresh',
      () async {
        final repo = _MockSessionRepository();
        when(() => repo.saveSession(any())).thenAnswer((_) async {});
        when(() => repo.clearSession()).thenAnswer((_) async {});

        final refreshCompleter =
            Completer<Either<AuthFailure, AuthTokensEntity>>();
        final refreshUsecase = _MockRefreshTokenUsecase();
        when(
          () => refreshUsecase(any()),
        ).thenAnswer((_) => refreshCompleter.future);

        final events = AppEventBus();
        final manager = SessionManager(
          repo,
          refreshUsecase: refreshUsecase,
          events: events,
        );

        await manager.login(
          AuthSessionEntity(
            tokens: const AuthTokensEntity(
              accessToken: 'access_old',
              refreshToken: 'refresh_old',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
            user: const UserEntity(id: 'u1', email: 'user@example.com'),
          ),
        );

        final refreshFuture = manager.refreshTokens();
        await Future<void>.delayed(Duration.zero);

        await manager.logout(reason: 'manual_logout');

        refreshCompleter.complete(
          right(
            const AuthTokensEntity(
              accessToken: 'access_new',
              refreshToken: 'refresh_new',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
          ),
        );

        final ok = await refreshFuture;
        expect(ok, false);
        expect(manager.session, isNull);

        final captured = verify(() => repo.saveSession(captureAny())).captured;
        expect(captured.length, 1); // login only; refresh must not persist

        events.dispose();
        manager.dispose();
      },
    );
  });
}
