import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_option_entity.freezed.dart';

@freezed
abstract class ReferenceOptionEntity with _$ReferenceOptionEntity {
  const factory ReferenceOptionEntity({
    required String id,
    required String label,
  }) = _ReferenceOptionEntity;
}
