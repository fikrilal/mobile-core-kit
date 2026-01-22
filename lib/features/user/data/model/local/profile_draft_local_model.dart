import 'dart:convert';

import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';

class ProfileDraftLocalModel {
  const ProfileDraftLocalModel({
    required this.schemaVersion,
    required this.givenName,
    this.familyName,
    this.displayName,
    required this.updatedAtMs,
  });

  final int schemaVersion;
  final String givenName;
  final String? familyName;
  final String? displayName;
  final int updatedAtMs;

  ProfileDraftEntity toEntity() => ProfileDraftEntity(
    schemaVersion: schemaVersion,
    givenName: givenName,
    familyName: familyName,
    displayName: displayName,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
  );

  static ProfileDraftLocalModel fromEntity(ProfileDraftEntity entity) =>
      ProfileDraftLocalModel(
        schemaVersion: entity.schemaVersion,
        givenName: entity.givenName,
        familyName: entity.familyName,
        displayName: entity.displayName,
        updatedAtMs: entity.updatedAt.millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'givenName': givenName,
    'familyName': familyName,
    'displayName': displayName,
    'updatedAtMs': updatedAtMs,
  };

  static ProfileDraftLocalModel? tryParse(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return null;

    try {
      final decoded = jsonDecode(normalized);
      return fromDecoded(decoded);
    } catch (_) {
      return null;
    }
  }

  static ProfileDraftLocalModel? fromDecoded(Object? decoded) {
    if (decoded is! Map) return null;

    final map = <String, dynamic>{};
    for (final entry in decoded.entries) {
      map[entry.key.toString()] = entry.value;
    }

    final schemaVersion = _readInt(map['schemaVersion']) ?? 1;

    final givenNameRaw = map['givenName'];
    if (givenNameRaw is! String) return null;

    final updatedAtMs = _readInt(map['updatedAtMs']);
    if (updatedAtMs == null || updatedAtMs <= 0) return null;

    final familyName = map['familyName'];
    final displayName = map['displayName'];

    return ProfileDraftLocalModel(
      schemaVersion: schemaVersion,
      givenName: givenNameRaw,
      familyName: familyName is String ? familyName : null,
      displayName: displayName is String ? displayName : null,
      updatedAtMs: updatedAtMs,
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

