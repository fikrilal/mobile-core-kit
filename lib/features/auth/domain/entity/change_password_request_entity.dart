import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password_request_entity.freezed.dart';

@freezed
abstract class ChangePasswordRequestEntity with _$ChangePasswordRequestEntity {
  const factory ChangePasswordRequestEntity({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequestEntity;
}
