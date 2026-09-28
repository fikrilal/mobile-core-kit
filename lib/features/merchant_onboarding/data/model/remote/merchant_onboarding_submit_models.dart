import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';

part 'merchant_onboarding_submit_models.freezed.dart';
part 'merchant_onboarding_submit_models.g.dart';

@freezed
abstract class MerchantOnboardingSubmitRequestModel
    with _$MerchantOnboardingSubmitRequestModel {
  const factory MerchantOnboardingSubmitRequestModel({
    required MerchantBusinessInputModel business,
    required List<MerchantOwnerInputModel> owners,
    required MerchantSettlementInputModel settlement,
    required MerchantDeclarationsInputModel declarations,
  }) = _MerchantOnboardingSubmitRequestModel;

  const MerchantOnboardingSubmitRequestModel._();

  factory MerchantOnboardingSubmitRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$MerchantOnboardingSubmitRequestModelFromJson(json);

  factory MerchantOnboardingSubmitRequestModel.fromApplication(
    MerchantOnboardingApplication application,
  ) {
    return MerchantOnboardingSubmitRequestModel(
      business: MerchantBusinessInputModel(
        legalName: application.business.legalName.value,
        businessTypeId: application.business.businessTypeId,
        registrationNumber: application.business.registrationNumber?.value,
        industryId: application.business.industryId,
        monthlySalesRangeId: application.business.monthlySalesRangeId,
        contactEmail: application.business.contactEmail.value,
        contactPhone: application.business.contactPhone.value,
      ),
      owners: [
        for (final row in application.owners.rows)
          MerchantOwnerInputModel(
            ownerRowId: row.id,
            fullName: row.fullName.value,
            roleId: row.roleId,
            ownershipBasisPoints: row.percentage?.basisPoints,
            email: row.email.value,
            isPrimaryContact: row.isPrimaryContact,
          ),
      ],
      settlement: MerchantSettlementInputModel(
        bankId: application.settlement.bankId,
        accountHolderName: application.settlement.accountHolderName.value,
        accountNumber: application.settlement.accountNumber.value,
        holderTypeId: application.settlement.holderTypeId,
        ownerRowId: application.settlement.ownerRowId,
        payoutScheduleId: application.settlement.payoutScheduleId,
      ),
      declarations: MerchantDeclarationsInputModel(
        informationAccurate: application.declarations.informationAccurate,
        authorizedToSubmit: application.declarations.authorizedToSubmit,
        termsAccepted: application.declarations.termsAccepted,
        termsVersion: application.declarations.termsVersion.value,
      ),
    );
  }
}

@freezed
abstract class MerchantBusinessInputModel with _$MerchantBusinessInputModel {
  const factory MerchantBusinessInputModel({
    required String legalName,
    required String businessTypeId,
    String? registrationNumber,
    required String industryId,
    required String monthlySalesRangeId,
    required String contactEmail,
    required String contactPhone,
  }) = _MerchantBusinessInputModel;

  factory MerchantBusinessInputModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantBusinessInputModelFromJson(json);
}

@freezed
abstract class MerchantOwnerInputModel with _$MerchantOwnerInputModel {
  const factory MerchantOwnerInputModel({
    required String ownerRowId,
    required String fullName,
    required String roleId,
    int? ownershipBasisPoints,
    required String email,
    required bool isPrimaryContact,
  }) = _MerchantOwnerInputModel;

  factory MerchantOwnerInputModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantOwnerInputModelFromJson(json);
}

@freezed
abstract class MerchantSettlementInputModel
    with _$MerchantSettlementInputModel {
  const factory MerchantSettlementInputModel({
    required String bankId,
    required String accountHolderName,
    required String accountNumber,
    required String holderTypeId,
    String? ownerRowId,
    required String payoutScheduleId,
  }) = _MerchantSettlementInputModel;

  factory MerchantSettlementInputModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantSettlementInputModelFromJson(json);
}

@freezed
abstract class MerchantDeclarationsInputModel
    with _$MerchantDeclarationsInputModel {
  const factory MerchantDeclarationsInputModel({
    required bool informationAccurate,
    required bool authorizedToSubmit,
    required bool termsAccepted,
    required String termsVersion,
  }) = _MerchantDeclarationsInputModel;

  factory MerchantDeclarationsInputModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantDeclarationsInputModelFromJson(json);
}

@freezed
abstract class MerchantSubmitResultModel with _$MerchantSubmitResultModel {
  const factory MerchantSubmitResultModel({
    required String applicationId,
    required String submittedAt,
    MerchantSubmitSettlementModel? settlement,
  }) = _MerchantSubmitResultModel;

  factory MerchantSubmitResultModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantSubmitResultModelFromJson(json);
}

@freezed
abstract class MerchantSubmitSettlementModel
    with _$MerchantSubmitSettlementModel {
  const factory MerchantSubmitSettlementModel({
    required String bankId,
    required String accountNumberLast4,
  }) = _MerchantSubmitSettlementModel;

  factory MerchantSubmitSettlementModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantSubmitSettlementModelFromJson(json);
}
