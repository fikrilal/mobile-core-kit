import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_holder_type_option_entity.freezed.dart';

@freezed
abstract class AccountHolderTypeOptionEntity
    with _$AccountHolderTypeOptionEntity {
  const factory AccountHolderTypeOptionEntity({
    required String id,
    required String label,
    required bool requiresOwnerReference,
  }) = _AccountHolderTypeOptionEntity;
}
