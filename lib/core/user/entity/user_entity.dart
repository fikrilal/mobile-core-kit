import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    bool? emailVerified,
    String? createdAt,
  }) = _UserEntity;
}
