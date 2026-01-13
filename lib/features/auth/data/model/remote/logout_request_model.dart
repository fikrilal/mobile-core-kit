import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/logout_request_entity.dart';

part 'logout_request_model.freezed.dart';
part 'logout_request_model.g.dart';

@freezed
abstract class LogoutRequestModel with _$LogoutRequestModel {
  const factory LogoutRequestModel({required String refreshToken}) =
      _LogoutRequestModel;

  const LogoutRequestModel._();

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestModelFromJson(json);

  factory LogoutRequestModel.fromEntity(LogoutRequestEntity e) =>
      LogoutRequestModel(refreshToken: e.refreshToken);
}
