import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/me_session_entity.dart';

part 'me_sessions_state.freezed.dart';

enum MeSessionsStatus { initial, loading, success, empty, failure, loadingMore }

enum MeSessionRevokeStatus { idle, submitting, success, failure }

@freezed
abstract class MeSessionsState with _$MeSessionsState {
  const factory MeSessionsState({
    @Default(MeSessionsStatus.initial) MeSessionsStatus status,
    @Default(<MeSessionEntity>[]) List<MeSessionEntity> sessions,
    String? nextCursor,
    int? limit,
    @Default(false) bool hasMore,
    AuthFailure? failure,
    @Default(MeSessionRevokeStatus.idle) MeSessionRevokeStatus revokeStatus,
    String? pendingRevokeSessionId,
    String? lastRevokedSessionId,
    AuthFailure? revokeFailure,
  }) = _MeSessionsState;

  const MeSessionsState._();

  bool get isLoading => status == MeSessionsStatus.loading;
  bool get isLoadingMore => status == MeSessionsStatus.loadingMore;
  bool get isRevokeSubmitting =>
      revokeStatus == MeSessionRevokeStatus.submitting;

  factory MeSessionsState.initial() => const MeSessionsState();
}
