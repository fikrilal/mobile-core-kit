import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_response_model.freezed.dart';
part 'refresh_response_model.g.dart';

@freezed
abstract class RefreshResponseModel with _$RefreshResponseModel {
  const factory RefreshResponseModel({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _RefreshResponseModel;

  const RefreshResponseModel._();

  factory RefreshResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseModelFromJson(json);
}
