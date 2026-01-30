import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/events/app_event.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionManager extends Mock implements SessionManager {}

class _MockCurrentUserFetcher extends Mock implements CurrentUserFetcher {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const UserEntity(id: 'u', email: 'u@example.com'));
  });

  group('UserContextService', () {
    late ValueNotifier<AuthSessionEntity?> sessionNotifier;
    late AppEventBus events;
    late _MockSessionManager sessionManager;
    late _MockCurrentUserFetcher currentUserFetcher;
    late UserContextService service;

    setUp(() {
      sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      events = AppEventBus();
      sessionManager = _MockSessionManager();
      currentUserFetcher = _MockCurrentUserFetcher();

      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(
        () => sessionManager.refreshToken,
      ).thenAnswer((_) => sessionNotifier.value?.tokens.refreshToken);

      when(() => sessionManager.setUser(any())).thenAnswer((invocation) async {
        final current = sessionNotifier.value;
        if (current == null) return;
        final user = invocation.positionalArguments.single as UserEntity;
        sessionNotifier.value = current.copyWith(user: user);
      });

      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((invocation) async {
        final reason = invocation.namedArguments[#reason] as String?;
        sessionNotifier.value = null;
        events.publish(SessionCleared(reason: reason));
      });

      service = UserContextService(
        sessionManager: sessionManager,
        currentUserFetcher: currentUserFetcher,
        events: events,
        now: () => DateTime(2026, 1, 20),
      );
    });

    tearDown(() {
      service.dispose();
      events.dispose();
      sessionNotifier.dispose();
    });

    test('defaults to signedOut when no session exists', () {
      expect(service.state.status, CurrentUserStatus.signedOut);
      expect(service.isAuthenticated, false);
      expect(service.user, isNull);
    });

    test('reflects authPending when tokens exist but user is not yet set', () {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      expect(service.state.status, CurrentUserStatus.authPending);
      expect(service.isAuthPending, true);
      expect(service.user, isNull);
    });

    test('reflects available when session has user', () {
      const user = UserEntity(
        id: 'u1',
        email: 'user@example.com',
        profile: UserProfileEntity(givenName: 'First', familyName: 'Last'),
      );
      sessionNotifier.value = _session(refreshToken: 'rt1', user: user);

      expect(service.state.status, CurrentUserStatus.available);
      expect(service.user, user);
      expect(service.displayName, 'First Last');
      expect(service.email, 'user@example.com');
      expect(service.initials, 'FL');
    });

    test(
      'ensureUserFresh returns existing user without calling fetch',
      () async {
        const user = UserEntity(id: 'u1', email: 'user@example.com');
        sessionNotifier.value = _session(refreshToken: 'rt1', user: user);

        final result = await service.ensureUserFresh();

        expect(result.isRight(), true);
        result.match((_) => fail('Expected Right'), (u) => expect(u, user));
        verifyNever(() => currentUserFetcher.fetch());
      },
    );

    test('refreshUser dedupes concurrent refresh (single-flight)', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      final completer = Completer<Either<SessionFailure, UserEntity>>();
      when(
        () => currentUserFetcher.fetch(),
      ).thenAnswer((_) => completer.future);

      final future1 = service.refreshUser();
      final future2 = service.refreshUser();

      verify(() => currentUserFetcher.fetch()).called(1);

      const fetchedUser = UserEntity(
        id: 'u1',
        email: 'user@example.com',
        profile: UserProfileEntity(givenName: 'First', familyName: 'Last'),
      );
      completer.complete(right(fetchedUser));

      final results = await Future.wait([future1, future2]);

      for (final result in results) {
        expect(result.isRight(), true);
        result.match(
          (_) => fail('Expected Right'),
          (u) => expect(u, fetchedUser),
        );
      }

      verify(() => sessionManager.setUser(fetchedUser)).called(1);
      expect(service.user, fetchedUser);
    });

    test('refreshUser ignores result if session changes mid-flight', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      final completer = Completer<Either<SessionFailure, UserEntity>>();
      when(
        () => currentUserFetcher.fetch(),
      ).thenAnswer((_) => completer.future);

      final future = service.refreshUser();

      // Simulate account switch while refresh is in-flight.
      sessionNotifier.value = _session(refreshToken: 'rt2');

      const fetchedUser = UserEntity(id: 'u1', email: 'user@example.com');
      completer.complete(right(fetchedUser));

      final result = await future;

      expect(result.isLeft(), true);
      result.match(
        (failure) =>
            expect(failure, const SessionFailure.unexpected('session_changed')),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => sessionManager.setUser(any()));
      expect(service.isAuthPending, true);
      expect(service.user, isNull);
    });

    test('refreshUser logs out on unauthenticated by default', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      when(
        () => currentUserFetcher.fetch(),
      ).thenAnswer((_) async => left(const SessionFailure.unauthenticated()));

      final result = await service.refreshUser();

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, const SessionFailure.unauthenticated()),
        (_) => fail('Expected Left'),
      );

      verify(
        () => sessionManager.logout(reason: 'user_refresh_unauthenticated'),
      ).called(1);
      expect(service.state.status, CurrentUserStatus.signedOut);
    });
  });
}

AuthSessionEntity _session({required String refreshToken, UserEntity? user}) {
  return AuthSessionEntity(
    tokens: AuthTokensEntity(
      accessToken: 'at_$refreshToken',
      refreshToken: refreshToken,
      tokenType: 'Bearer',
      expiresIn: 3600,
      expiresAt: DateTime(2026, 1, 20),
    ),
    user: user,
  );
}
