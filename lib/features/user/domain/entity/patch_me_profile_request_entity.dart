import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_me_profile_request_entity.freezed.dart';

@freezed
abstract class PatchMeProfileRequestEntity with _$PatchMeProfileRequestEntity {
  const factory PatchMeProfileRequestEntity({
    required String givenName,
    String? familyName,
    String? displayName,
  }) = _PatchMeProfileRequestEntity;
}
