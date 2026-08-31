import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant_reference_data_models.freezed.dart';
part 'merchant_reference_data_models.g.dart';

/// Wire models for `GET /v1/merchant-onboarding/reference-data`.
/// The standard `{data}` envelope is unwrapped by [ApiHelper]; these types
/// mirror the accepted OpenAPI schemas exactly.

@freezed
abstract class MerchantReferenceDataDto with _$MerchantReferenceDataDto {
  const factory MerchantReferenceDataDto({
    required List<MerchantBusinessTypeOptionDto> businessTypes,
    required List<MerchantLabeledOptionDto> industries,
    required List<MerchantLabeledOptionDto> monthlySalesRanges,
    required List<MerchantOwnerRoleOptionDto> ownerRoles,
    required List<MerchantBankOptionDto> banks,
    required List<MerchantAccountHolderTypeOptionDto> accountHolderTypes,
    required List<MerchantLabeledOptionDto> payoutSchedules,
    required String termsVersion,
  }) = _MerchantReferenceDataDto;

  factory MerchantReferenceDataDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantReferenceDataDtoFromJson(json);
}

@freezed
abstract class MerchantBusinessTypeOptionDto
    with _$MerchantBusinessTypeOptionDto {
  const factory MerchantBusinessTypeOptionDto({
    required String id,
    required String label,
    required bool requiresRegistrationNumber,
  }) = _MerchantBusinessTypeOptionDto;

  factory MerchantBusinessTypeOptionDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantBusinessTypeOptionDtoFromJson(json);
}

@freezed
abstract class MerchantLabeledOptionDto with _$MerchantLabeledOptionDto {
  const factory MerchantLabeledOptionDto({
    required String id,
    required String label,
  }) = _MerchantLabeledOptionDto;

  factory MerchantLabeledOptionDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantLabeledOptionDtoFromJson(json);
}

@freezed
abstract class MerchantOwnerRoleOptionDto with _$MerchantOwnerRoleOptionDto {
  const factory MerchantOwnerRoleOptionDto({
    required String id,
    required String label,
    required bool contributesOwnership,
  }) = _MerchantOwnerRoleOptionDto;

  factory MerchantOwnerRoleOptionDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantOwnerRoleOptionDtoFromJson(json);
}

@freezed
abstract class MerchantBankOptionDto with _$MerchantBankOptionDto {
  const factory MerchantBankOptionDto({
    required String id,
    required String label,
    required List<String> supportedPayoutScheduleIds,
  }) = _MerchantBankOptionDto;

  factory MerchantBankOptionDto.fromJson(Map<String, dynamic> json) =>
      _$MerchantBankOptionDtoFromJson(json);
}

@freezed
abstract class MerchantAccountHolderTypeOptionDto
    with _$MerchantAccountHolderTypeOptionDto {
  const factory MerchantAccountHolderTypeOptionDto({
    required String id,
    required String label,
    required bool requiresOwnerReference,
  }) = _MerchantAccountHolderTypeOptionDto;

  factory MerchantAccountHolderTypeOptionDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MerchantAccountHolderTypeOptionDtoFromJson(json);
}
