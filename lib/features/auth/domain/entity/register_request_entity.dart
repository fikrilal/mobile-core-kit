import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_entity.freezed.dart';

@freezed
abstract class RegisterRequestEntity with _$RegisterRequestEntity {
  const factory RegisterRequestEntity({
    required String displayName,
    required String email,
    required String password,
    required String timezone,
    required String profileVisibility,
  }) = _RegisterRequestEntity;
}
