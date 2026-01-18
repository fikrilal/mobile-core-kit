import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/features/auth/domain/entity/refresh_request_entity.dart';

part 'refresh_request_model.freezed.dart';
part 'refresh_request_model.g.dart';

@freezed
abstract class RefreshRequestModel with _$RefreshRequestModel {
  const factory RefreshRequestModel({required String refreshToken}) =
      _RefreshRequestModel;

  const RefreshRequestModel._();

  factory RefreshRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestModelFromJson(json);

  factory RefreshRequestModel.fromEntity(RefreshRequestEntity e) =>
      RefreshRequestModel(refreshToken: e.refreshToken);
}
