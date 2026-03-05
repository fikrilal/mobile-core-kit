import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/revoke_me_session_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/list_me_sessions_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/revoke_me_session_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/me_sessions/me_sessions_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/me_sessions/me_sessions_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockListMeSessionsUseCase extends Mock
    implements ListMeSessionsUseCase {}

class _MockRevokeMeSessionUseCase extends Mock
    implements RevokeMeSessionUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ListMeSessionsRequestEntity());
    registerFallbackValue(
      const RevokeMeSessionRequestEntity(sessionId: 's-fallback'),
    );
  });

  late _MockListMeSessionsUseCase listMeSessions;
  late _MockRevokeMeSessionUseCase revokeMeSession;

  final session1 = MeSessionEntity(
    id: 's1',
    deviceId: 'device-1',
    deviceName: 'Pixel 9',
    ip: '203.0.113.1',
    userAgent: 'UA-1',
    lastSeenAt: DateTime.utc(2026, 3, 5, 10),
    createdAt: DateTime.utc(2026, 3, 1, 10),
    expiresAt: DateTime.utc(2026, 4, 1, 10),
    current: true,
    status: MeSessionStatus.active,
  );

  final session2 = MeSessionEntity(
    id: 's2',
    deviceId: 'device-2',
    deviceName: 'iPhone',
    ip: '203.0.113.2',
    userAgent: 'UA-2',
    lastSeenAt: DateTime.utc(2026, 3, 5, 11),
    createdAt: DateTime.utc(2026, 2, 28, 10),
    expiresAt: DateTime.utc(2026, 4, 1, 11),
    current: false,
    status: MeSessionStatus.active,
  );

  setUp(() {
    listMeSessions = _MockListMeSessionsUseCase();
    revokeMeSession = _MockRevokeMeSessionUseCase();
  });

  blocTest<MeSessionsCubit, MeSessionsState>(
    'load emits loading then success when page has items',
    build: () {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async => right(
          MeSessionsPageEntity(
            items: [session1],
            nextCursor: 'cursor-1',
            limit: 25,
            hasMore: true,
          ),
        ),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));
      return MeSessionsCubit(listMeSessions, revokeMeSession);
    },
    act: (cubit) async => cubit.load(),
    expect: () => [
      const MeSessionsState(status: MeSessionsStatus.loading),
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [session1],
        nextCursor: 'cursor-1',
        limit: 25,
        hasMore: true,
      ),
    ],
    verify: (_) {
      final request =
          verify(() => listMeSessions(captureAny())).captured.single
              as ListMeSessionsRequestEntity;
      expect(request.limit, MeSessionsCubit.defaultLimit);
      expect(request.sort, MeSessionsCubit.defaultSort);
      expect(request.cursor, isNull);
    },
  );

  blocTest<MeSessionsCubit, MeSessionsState>(
    'load emits loading then empty when page has no items',
    build: () {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async => right(
          const MeSessionsPageEntity(
            items: [],
            nextCursor: null,
            limit: 25,
            hasMore: false,
          ),
        ),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));
      return MeSessionsCubit(listMeSessions, revokeMeSession);
    },
    act: (cubit) async => cubit.load(),
    expect: () => const [
      MeSessionsState(status: MeSessionsStatus.loading),
      MeSessionsState(
        status: MeSessionsStatus.empty,
        sessions: [],
        limit: 25,
        hasMore: false,
      ),
    ],
  );

  blocTest<MeSessionsCubit, MeSessionsState>(
    'load emits loading then failure when list usecase fails',
    build: () {
      when(
        () => listMeSessions(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));
      return MeSessionsCubit(listMeSessions, revokeMeSession);
    },
    act: (cubit) async => cubit.load(),
    expect: () => const [
      MeSessionsState(status: MeSessionsStatus.loading),
      MeSessionsState(
        status: MeSessionsStatus.failure,
        failure: AuthFailure.network(),
      ),
    ],
  );

  blocTest<MeSessionsCubit, MeSessionsState>(
    'loadMore emits loadingMore then success with appended unique sessions',
    build: () {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async => right(
          MeSessionsPageEntity(
            items: [session2, session1],
            nextCursor: null,
            limit: 25,
            hasMore: false,
          ),
        ),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));
      return MeSessionsCubit(listMeSessions, revokeMeSession);
    },
    seed: () => MeSessionsState(
      status: MeSessionsStatus.success,
      sessions: [session1],
      nextCursor: 'cursor-1',
      limit: 25,
      hasMore: true,
    ),
    act: (cubit) async => cubit.loadMore(),
    expect: () => [
      MeSessionsState(
        status: MeSessionsStatus.loadingMore,
        sessions: [session1],
        nextCursor: 'cursor-1',
        limit: 25,
        hasMore: true,
      ),
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [session1, session2],
        nextCursor: null,
        limit: 25,
        hasMore: false,
      ),
    ],
    verify: (_) {
      final request =
          verify(() => listMeSessions(captureAny())).captured.single
              as ListMeSessionsRequestEntity;
      expect(request.cursor, 'cursor-1');
      expect(request.limit, MeSessionsCubit.defaultLimit);
      expect(request.sort, MeSessionsCubit.defaultSort);
    },
  );

  blocTest<MeSessionsCubit, MeSessionsState>(
    'revokeSession emits submitting then success and marks target session revoked',
    build: () {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async =>
            right(const MeSessionsPageEntity(items: [], hasMore: false)),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));
      return MeSessionsCubit(
        listMeSessions,
        revokeMeSession,
        now: () => DateTime.utc(2026, 3, 5, 12),
      );
    },
    seed: () => MeSessionsState(
      status: MeSessionsStatus.success,
      sessions: [session1],
      hasMore: false,
    ),
    act: (cubit) async => cubit.revokeSession('s1'),
    expect: () => [
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [session1],
        hasMore: false,
        revokeStatus: MeSessionRevokeStatus.submitting,
        pendingRevokeSessionId: 's1',
      ),
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [
          session1.copyWith(
            status: MeSessionStatus.revoked,
            revokedAt: DateTime.utc(2026, 3, 5, 12),
          ),
        ],
        hasMore: false,
        revokeStatus: MeSessionRevokeStatus.success,
        lastRevokedSessionId: 's1',
      ),
    ],
    verify: (_) {
      final request =
          verify(() => revokeMeSession(captureAny())).captured.single
              as RevokeMeSessionRequestEntity;
      expect(request.sessionId, 's1');
    },
  );

  blocTest<MeSessionsCubit, MeSessionsState>(
    'revokeSession emits submitting then failure when revoke usecase fails',
    build: () {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async =>
            right(const MeSessionsPageEntity(items: [], hasMore: false)),
      );
      when(
        () => revokeMeSession(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      return MeSessionsCubit(listMeSessions, revokeMeSession);
    },
    seed: () => MeSessionsState(
      status: MeSessionsStatus.success,
      sessions: [session1],
      hasMore: false,
    ),
    act: (cubit) async => cubit.revokeSession('s1'),
    expect: () => [
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [session1],
        hasMore: false,
        revokeStatus: MeSessionRevokeStatus.submitting,
        pendingRevokeSessionId: 's1',
      ),
      MeSessionsState(
        status: MeSessionsStatus.success,
        sessions: [session1],
        hasMore: false,
        revokeStatus: MeSessionRevokeStatus.failure,
        revokeFailure: const AuthFailure.network(),
      ),
    ],
  );
}
