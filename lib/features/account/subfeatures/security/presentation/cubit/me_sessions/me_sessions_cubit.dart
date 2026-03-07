import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/revoke_me_session_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/list_me_sessions_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/revoke_me_session_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_state.dart';

class MeSessionsCubit extends Cubit<MeSessionsState> {
  MeSessionsCubit(
    this._listMeSessions,
    this._revokeMeSession, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(MeSessionsState.initial());

  static const int defaultLimit = 25;
  static const String defaultSort = '-createdAt';

  final ListMeSessionsUseCase _listMeSessions;
  final RevokeMeSessionUseCase _revokeMeSession;
  final DateTime Function() _now;

  Future<void> load({
    int limit = defaultLimit,
    String sort = defaultSort,
  }) async {
    if (state.isLoading || state.isLoadingMore) return;

    emit(
      state.copyWith(
        status: MeSessionsStatus.loading,
        failure: null,
        revokeFailure: null,
        revokeStatus: MeSessionRevokeStatus.idle,
        pendingRevokeSessionId: null,
        lastRevokedSessionId: null,
      ),
    );

    await _emitPage(
      resultFuture: _listMeSessions(
        ListMeSessionsRequestEntity(limit: limit, sort: sort),
      ),
      append: false,
    );
  }

  Future<void> refresh({
    int limit = defaultLimit,
    String sort = defaultSort,
  }) async {
    await load(limit: limit, sort: sort);
  }

  Future<void> loadMore({
    int limit = defaultLimit,
    String sort = defaultSort,
  }) async {
    final cursor = state.nextCursor;
    if (state.isLoading || state.isLoadingMore) return;
    if (!state.hasMore || cursor == null || cursor.trim().isEmpty) return;

    emit(state.copyWith(status: MeSessionsStatus.loadingMore, failure: null));

    await _emitPage(
      resultFuture: _listMeSessions(
        ListMeSessionsRequestEntity(limit: limit, cursor: cursor, sort: sort),
      ),
      append: true,
    );
  }

  Future<void> revokeSession(String sessionId) async {
    final normalized = sessionId.trim();
    if (normalized.isEmpty || state.isRevokeSubmitting) return;

    emit(
      state.copyWith(
        revokeStatus: MeSessionRevokeStatus.submitting,
        pendingRevokeSessionId: normalized,
        lastRevokedSessionId: null,
        revokeFailure: null,
      ),
    );

    final result = await _revokeMeSession(
      RevokeMeSessionRequestEntity(sessionId: normalized),
    );

    if (isClosed) return;

    result.match(
      (failure) {
        emit(
          state.copyWith(
            revokeStatus: MeSessionRevokeStatus.failure,
            pendingRevokeSessionId: null,
            lastRevokedSessionId: null,
            revokeFailure: failure,
          ),
        );
      },
      (_) {
        final updatedSessions = state.sessions
            .map(
              (session) => session.id == normalized
                  ? session.copyWith(
                      status: MeSessionStatus.revoked,
                      revokedAt: session.revokedAt ?? _now(),
                    )
                  : session,
            )
            .toList(growable: false);

        emit(
          state.copyWith(
            status: _listStatusFor(updatedSessions),
            sessions: updatedSessions,
            revokeStatus: MeSessionRevokeStatus.success,
            pendingRevokeSessionId: null,
            lastRevokedSessionId: normalized,
            revokeFailure: null,
          ),
        );
      },
    );
  }

  void resetRevokeStatus() {
    if (state.revokeStatus == MeSessionRevokeStatus.idle &&
        state.pendingRevokeSessionId == null &&
        state.lastRevokedSessionId == null &&
        state.revokeFailure == null) {
      return;
    }

    emit(
      state.copyWith(
        revokeStatus: MeSessionRevokeStatus.idle,
        pendingRevokeSessionId: null,
        lastRevokedSessionId: null,
        revokeFailure: null,
      ),
    );
  }

  void clearFailure() {
    if (state.failure == null) return;
    emit(state.copyWith(failure: null));
  }

  Future<void> _emitPage({
    required Future<Either<AuthFailure, MeSessionsPageEntity>> resultFuture,
    required bool append,
  }) async {
    final result = await resultFuture;
    if (isClosed) return;

    result.match(
      (failure) {
        final status = append
            ? _listStatusFor(state.sessions)
            : MeSessionsStatus.failure;

        emit(state.copyWith(status: status, failure: failure));
      },
      (page) {
        final merged = append
            ? _mergeSessions(state.sessions, page.items)
            : page.items;
        emit(
          state.copyWith(
            status: _listStatusFor(merged),
            sessions: merged,
            nextCursor: page.nextCursor,
            limit: page.limit,
            hasMore: page.hasMore,
            failure: null,
          ),
        );
      },
    );
  }

  static List<MeSessionEntity> _mergeSessions(
    List<MeSessionEntity> current,
    List<MeSessionEntity> incoming,
  ) {
    if (current.isEmpty) return incoming;
    if (incoming.isEmpty) return current;

    final existingIds = current.map((e) => e.id).toSet();
    final appended = incoming.where((e) => !existingIds.contains(e.id));
    return [...current, ...appended];
  }

  static MeSessionsStatus _listStatusFor(List<MeSessionEntity> sessions) {
    if (sessions.isEmpty) return MeSessionsStatus.empty;
    return MeSessionsStatus.success;
  }
}
