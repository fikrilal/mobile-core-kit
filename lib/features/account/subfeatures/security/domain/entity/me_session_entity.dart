import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_session_entity.freezed.dart';

enum MeSessionStatus { active, revoked, expired }

@freezed
abstract class MeSessionEntity with _$MeSessionEntity {
  const factory MeSessionEntity({
    required String id,
    String? deviceId,
    String? deviceName,
    String? ip,
    String? userAgent,
    required DateTime lastSeenAt,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? revokedAt,
    required bool current,
    required MeSessionStatus status,
  }) = _MeSessionEntity;
}

@freezed
abstract class MeSessionsPageEntity with _$MeSessionsPageEntity {
  const factory MeSessionsPageEntity({
    @Default(<MeSessionEntity>[]) List<MeSessionEntity> items,
    String? nextCursor,
    int? limit,
    @Default(false) bool hasMore,
  }) = _MeSessionsPageEntity;
}
