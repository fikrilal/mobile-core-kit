import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/events/app_event.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/refresh_token_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockRefreshTokenUsecase extends Mock implements RefreshTokenUsecase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RefreshRequestEntity(refreshToken: 'refresh'),
    );
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

  group('SessionManager.refreshTokens', () {
    test(
      'logs out only when unauthenticated (e.g. invalid refresh token)',
      () async {
        final repo = _MockSessionRepository();
        when(() => repo.saveSession(any())).thenAnswer((_) async {});
        when(() => repo.clearSession()).thenAnswer((_) async {});

        final refreshUsecase = _MockRefreshTokenUsecase();
        when(() => refreshUsecase(any())).thenAnswer(
          (_) async => left(const AuthFailure.unauthenticated()),
        );

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
      when(() => refreshUsecase(any())).thenAnswer(
        (_) async => left(const AuthFailure.network()),
      );

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
      expect(manager.session, initialSession);

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
      when(() => refreshUsecase(any())).thenAnswer(
        (_) async => right(newTokens),
      );

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
      expect(manager.session?.tokens, newTokens);
      expect(manager.session?.user, initialSession.user);

      final captured = verify(() => repo.saveSession(captureAny())).captured;
      expect(captured.length, 2); // login + refresh update
      final last = captured.last as AuthSessionEntity;
      expect(last.tokens, newTokens);
      expect(last.user, initialSession.user);

      events.dispose();
      manager.dispose();
    });
  });
}
