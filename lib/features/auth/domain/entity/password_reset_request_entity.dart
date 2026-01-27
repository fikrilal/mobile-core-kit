import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_request_entity.freezed.dart';

@freezed
abstract class PasswordResetRequestEntity with _$PasswordResetRequestEntity {
  const factory PasswordResetRequestEntity({required String email}) =
      _PasswordResetRequestEntity;
}
