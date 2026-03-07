import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_paginated_result.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';

part 'me_session_model.freezed.dart';
part 'me_session_model.g.dart';

// ignore_for_file: invalid_annotation_target

enum MeSessionStatusModel {
  @JsonValue('active')
  active,
  @JsonValue('revoked')
  revoked,
  @JsonValue('expired')
  expired,
}

/// Session item returned by `GET /v1/me/sessions`.
@freezed
abstract class MeSessionModel with _$MeSessionModel {
  @JsonSerializable(includeIfNull: false)
  const factory MeSessionModel({
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
    required MeSessionStatusModel status,
  }) = _MeSessionModel;

  const MeSessionModel._();

  factory MeSessionModel.fromJson(Map<String, dynamic> json) =>
      _$MeSessionModelFromJson(json);

  MeSessionEntity toEntity() {
    return MeSessionEntity(
      id: id,
      deviceId: deviceId,
      deviceName: deviceName,
      ip: ip,
      userAgent: userAgent,
      lastSeenAt: lastSeenAt,
      createdAt: createdAt,
      expiresAt: expiresAt,
      revokedAt: revokedAt,
      current: current,
      status: status.toEntity(),
    );
  }
}

extension MeSessionStatusModelX on MeSessionStatusModel {
  MeSessionStatus toEntity() {
    return switch (this) {
      MeSessionStatusModel.active => MeSessionStatus.active,
      MeSessionStatusModel.revoked => MeSessionStatus.revoked,
      MeSessionStatusModel.expired => MeSessionStatus.expired,
    };
  }
}

extension ApiMeSessionsResultX on ApiPaginatedResult<MeSessionModel> {
  MeSessionsPageEntity toEntity() {
    final meta = additionalMeta;
    final hasMoreValue = meta?['hasMore'];
    final hasMore = hasMoreValue is bool ? hasMoreValue : hasNext;
    return MeSessionsPageEntity(
      items: items.map((item) => item.toEntity()).toList(growable: false),
      nextCursor: nextCursor,
      limit: limit,
      hasMore: hasMore,
    );
  }
}
