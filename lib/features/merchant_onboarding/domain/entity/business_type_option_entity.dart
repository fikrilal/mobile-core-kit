import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_type_option_entity.freezed.dart';

@freezed
abstract class BusinessTypeOptionEntity with _$BusinessTypeOptionEntity {
  const factory BusinessTypeOptionEntity({
    required String id,
    required String label,
    required bool requiresRegistrationNumber,
  }) = _BusinessTypeOptionEntity;
}
