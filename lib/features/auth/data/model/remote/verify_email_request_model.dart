import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';

part 'verify_email_request_model.freezed.dart';
part 'verify_email_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
abstract class VerifyEmailRequestModel with _$VerifyEmailRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory VerifyEmailRequestModel({required String token}) =
      _VerifyEmailRequestModel;

  const VerifyEmailRequestModel._();

  factory VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestModelFromJson(json);

  factory VerifyEmailRequestModel.fromEntity(VerifyEmailRequestEntity entity) =>
      VerifyEmailRequestModel(token: entity.token);
}
