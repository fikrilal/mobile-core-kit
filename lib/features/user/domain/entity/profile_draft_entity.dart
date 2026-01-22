import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_draft_entity.freezed.dart';

/// Client-only draft for profile completion forms.
///
/// This is *not* authoritative user data and is never sent to the backend as-is.
/// It exists to persist in-progress form inputs so the user can resume after the
/// app is closed/killed mid-form.
@freezed
abstract class ProfileDraftEntity with _$ProfileDraftEntity {
  const factory ProfileDraftEntity({
    /// Schema version of this draft payload (for forward-compatible evolution).
    @Default(1) int schemaVersion,

    /// Given name input (can be invalid/untrimmed while user is typing).
    required String givenName,

    /// Optional family name input (can be invalid/untrimmed while user is typing).
    String? familyName,

    /// Optional display name input (may be enabled by some products).
    String? displayName,

    /// When this draft was last updated (for TTL/cleanup).
    required DateTime updatedAt,
  }) = _ProfileDraftEntity;
}

