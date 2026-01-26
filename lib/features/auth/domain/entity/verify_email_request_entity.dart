import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_email_request_entity.freezed.dart';

@freezed
abstract class VerifyEmailRequestEntity with _$VerifyEmailRequestEntity {
  const factory VerifyEmailRequestEntity({required String token}) =
      _VerifyEmailRequestEntity;
}
