import 'dart:convert';

import 'package:mobile_core_kit/features/user/data/model/local/profile_draft_local_model.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for the Complete Profile in-progress form.
///
/// Contract:
/// - Drafts are scoped per user (`user_profile_draft:<userId>`).
/// - Expired/invalid drafts are cleared (fail safe).
class ProfileDraftLocalDataSource {
  ProfileDraftLocalDataSource({
    Future<SharedPreferences>? prefs,
    Duration ttl = const Duration(days: 7),
    DateTime Function()? now,
  }) : _prefsFuture = prefs ?? SharedPreferences.getInstance(),
       _ttl = ttl,
       _now = now ?? DateTime.now;

  static const String _kPrefix = 'user_profile_draft:';

  final Future<SharedPreferences> _prefsFuture;
  final Duration _ttl;
  final DateTime Function() _now;

  String _keyFor(String userId) => '$_kPrefix$userId';

  Future<ProfileDraftEntity?> getDraft({required String userId}) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) return null;

    final prefs = await _prefsFuture;
    final raw = prefs.getString(_keyFor(normalizedId));
    if (raw == null || raw.trim().isEmpty) return null;

    final model = ProfileDraftLocalModel.tryParse(raw);
    if (model == null) {
      await prefs.remove(_keyFor(normalizedId));
      return null;
    }

    final updatedAt = DateTime.fromMillisecondsSinceEpoch(model.updatedAtMs);
    final age = _now().difference(updatedAt);
    if (age >= _ttl) {
      await prefs.remove(_keyFor(normalizedId));
      return null;
    }

    return model.toEntity();
  }

  Future<void> saveDraft({
    required String userId,
    required ProfileDraftEntity draft,
  }) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) return;

    final prefs = await _prefsFuture;
    final model = ProfileDraftLocalModel.fromEntity(draft);
    final encoded = jsonEncode(model.toJson());
    await prefs.setString(_keyFor(normalizedId), encoded);
  }

  Future<void> clearDraft({required String userId}) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) return;

    final prefs = await _prefsFuture;
    await prefs.remove(_keyFor(normalizedId));
  }
}
