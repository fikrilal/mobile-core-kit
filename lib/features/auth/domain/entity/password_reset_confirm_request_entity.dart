import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_confirm_request_entity.freezed.dart';

@freezed
abstract class PasswordResetConfirmRequestEntity
    with _$PasswordResetConfirmRequestEntity {
  const factory PasswordResetConfirmRequestEntity({
    required String token,
    required String newPassword,
  }) = _PasswordResetConfirmRequestEntity;
}
