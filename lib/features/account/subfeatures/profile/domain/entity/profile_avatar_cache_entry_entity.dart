import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_avatar_cache_entry_entity.freezed.dart';

@freezed
abstract class ProfileAvatarCacheEntryEntity
    with _$ProfileAvatarCacheEntryEntity {
  const factory ProfileAvatarCacheEntryEntity({
    required String filePath,
    required DateTime cachedAt,
    required bool isExpired,
  }) = _ProfileAvatarCacheEntryEntity;
}
