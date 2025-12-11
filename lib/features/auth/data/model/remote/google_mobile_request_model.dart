import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_mobile_request_model.freezed.dart';
part 'google_mobile_request_model.g.dart';

@freezed
abstract class GoogleMobileRequestModel with _$GoogleMobileRequestModel {
  const factory GoogleMobileRequestModel(String idToken) =
      _GoogleMobileRequestModel;

  const GoogleMobileRequestModel._();

  factory GoogleMobileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleMobileRequestModelFromJson(json);
}
