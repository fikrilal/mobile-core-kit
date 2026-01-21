import 'package:freezed_annotation/freezed_annotation.dart';

part 'oidc_exchange_request_model.freezed.dart';
part 'oidc_exchange_request_model.g.dart';

/// Request model for backend-core-kit OIDC exchange.
///
/// Backend contract: `POST /v1/auth/oidc/exchange`
/// - `provider`: currently only `GOOGLE`
/// - `idToken`: OIDC `id_token` returned by the provider SDK (Google Sign-In)
///
/// Note: backend supports optional `deviceId`/`deviceName`, but this template
/// keeps the baseline request minimal until device identity plumbing is added.
@freezed
abstract class OidcExchangeRequestModel with _$OidcExchangeRequestModel {
  const factory OidcExchangeRequestModel({
    required String provider,
    required String idToken,
  }) = _OidcExchangeRequestModel;

  const OidcExchangeRequestModel._();

  factory OidcExchangeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OidcExchangeRequestModelFromJson(json);
}
