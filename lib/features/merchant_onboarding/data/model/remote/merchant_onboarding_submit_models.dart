import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant_onboarding_submit_models.freezed.dart';
part 'merchant_onboarding_submit_models.g.dart';

/// Wire models for `POST /v1/merchant-onboarding/applications`. The request
/// mirrors the accepted OpenAPI schema; ownership is transported as exact
/// integer basis points and the account number stays a JSON string.

@freezed
abstract class MerchantOnboardingSubmitRequestDto
    with _$MerchantOnboardingSubmitRequestDto {
  const factory MerchantOnboardingSubmitRequestDto({
    required MerchantBusinessInputDto business,
    required List<MerchantOwnerInputDto> owners,
    required MerchantSettlementInputDto settlement,
    required MerchantDeclarationsInputDto declarations,
  }) = _MerchantOnboardingSubmitRequestDto;

  factory MerchantOnboardingSubmitRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MerchantOnboardingSubmitRequestDtoFromJson(json);
}

@freezed
abstract class MerchantBusinessInputDto with _$MerchantBusinessInputDto {
  const factory MerchantBusinessInputDto({
    required String legalName,
    required String businessTypeId,
    String? registrationNumber,
    required String industryId,
    required String monthlySalesRangeId,
    required String contactEmail,
    required String contactPhone,
  }) = _MerchantBusinessInputDto;

  factory MerchantBusinessInputDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantBusinessInputDtoFromJson(json);
}

@freezed
abstract class MerchantOwnerInputDto with _$MerchantOwnerInputDto {
  const factory MerchantOwnerInputDto({
    required String ownerRowId,
    required String fullName,
    required String roleId,
    int? ownershipBasisPoints,
    required String email,
    required bool isPrimaryContact,
  }) = _MerchantOwnerInputDto;

  factory MerchantOwnerInputDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantOwnerInputDtoFromJson(json);
}

@freezed
abstract class MerchantSettlementInputDto with _$MerchantSettlementInputDto {
  const factory MerchantSettlementInputDto({
    required String bankId,
    required String accountHolderName,
    required String accountNumber,
    required String holderTypeId,
    String? ownerRowId,
    required String payoutScheduleId,
  }) = _MerchantSettlementInputDto;

  factory MerchantSettlementInputDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantSettlementInputDtoFromJson(json);
}

@freezed
abstract class MerchantDeclarationsInputDto
    with _$MerchantDeclarationsInputDto {
  const factory MerchantDeclarationsInputDto({
    required bool informationAccurate,
    required bool authorizedToSubmit,
    required bool termsAccepted,
    required String termsVersion,
  }) = _MerchantDeclarationsInputDto;

  factory MerchantDeclarationsInputDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantDeclarationsInputDtoFromJson(json);
}

/// `201` response body (`{data: MerchantSubmitResultDto}`; envelope unwrapped
/// by [ApiHelper]). Only the application id is consumed by the UI; account
/// data stays inside the data boundary.
@freezed
abstract class MerchantSubmitResultDto with _$MerchantSubmitResultDto {
  const factory MerchantSubmitResultDto({
    required String applicationId,
    required String submittedAt,
    MerchantSubmitSettlementDto? settlement,
  }) = _MerchantSubmitResultDto;

  factory MerchantSubmitResultDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantSubmitResultDtoFromJson(json);
}

@freezed
abstract class MerchantSubmitSettlementDto with _$MerchantSubmitSettlementDto {
  const factory MerchantSubmitSettlementDto({
    required String bankId,
    required String accountNumberLast4,
  }) = _MerchantSubmitSettlementDto;

  factory MerchantSubmitSettlementDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantSubmitSettlementDtoFromJson(json);
}
