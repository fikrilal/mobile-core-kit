import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_sign_in_request_model.freezed.dart';
part 'google_sign_in_request_model.g.dart';

@freezed
abstract class GoogleSignInRequestModel with _$GoogleSignInRequestModel {
  const factory GoogleSignInRequestModel(String idToken) =
      _GoogleSignInRequestModel;

  const GoogleSignInRequestModel._();

  factory GoogleSignInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleSignInRequestModelFromJson(json);
}
