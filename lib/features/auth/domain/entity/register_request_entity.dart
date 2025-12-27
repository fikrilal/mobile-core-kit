import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_entity.freezed.dart';

@freezed
abstract class RegisterRequestEntity with _$RegisterRequestEntity {
  const factory RegisterRequestEntity({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) = _RegisterRequestEntity;
}
