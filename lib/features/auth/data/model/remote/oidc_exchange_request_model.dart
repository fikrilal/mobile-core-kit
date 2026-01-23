import 'package:freezed_annotation/freezed_annotation.dart';

part 'oidc_exchange_request_model.freezed.dart';
part 'oidc_exchange_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

/// Request model for backend-core-kit OIDC exchange.
///
/// Backend contract: `POST /v1/auth/oidc/exchange`
/// - `provider`: currently only `GOOGLE`
/// - `idToken`: OIDC `id_token` returned by the provider SDK (Google Sign-In)
@freezed
abstract class OidcExchangeRequestModel with _$OidcExchangeRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory OidcExchangeRequestModel({
    required String provider,
    required String idToken,
    String? deviceId,
    String? deviceName,
  }) = _OidcExchangeRequestModel;

  const OidcExchangeRequestModel._();

  factory OidcExchangeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OidcExchangeRequestModelFromJson(json);
}
