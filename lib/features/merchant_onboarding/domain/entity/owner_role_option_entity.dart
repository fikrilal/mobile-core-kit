import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_role_option_entity.freezed.dart';

@freezed
abstract class OwnerRoleOptionEntity with _$OwnerRoleOptionEntity {
  const factory OwnerRoleOptionEntity({
    required String id,
    required String label,
    required bool contributesOwnership,
  }) = _OwnerRoleOptionEntity;
}
