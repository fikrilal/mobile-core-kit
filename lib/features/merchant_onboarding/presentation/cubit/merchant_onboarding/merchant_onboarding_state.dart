import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

part 'merchant_onboarding_state.freezed.dart';

enum MerchantOnboardingStep {
  business,
  owners,
  settlement,
  review;

  MerchantOnboardingStep get next => switch (this) {
    business => owners,
    owners => settlement,
    settlement => review,
    review => review,
  };

  MerchantOnboardingStep get previous => switch (this) {
    business => business,
    owners => business,
    settlement => owners,
    review => settlement,
  };

  Set<String> fieldPaths(MerchantOnboardingInput input) => switch (this) {
    business => const {
      'business.legalName',
      'business.businessTypeId',
      'business.registrationNumber',
      'business.industryId',
      'business.monthlySalesRangeId',
      'business.contactEmail',
      'business.contactPhone',
    },
    owners => {
      for (final row in input.owners) ...[
        'owners.${row.ownerRowId}.fullName',
        'owners.${row.ownerRowId}.roleId',
        'owners.${row.ownerRowId}.ownershipPercentage',
        'owners.${row.ownerRowId}.email',
        'owners.${row.ownerRowId}.isPrimaryContact',
      ],
      'owners',
    },
    settlement => const {
      'settlement.bankId',
      'settlement.accountHolderName',
      'settlement.accountNumber',
      'settlement.holderTypeId',
      'settlement.ownerRowId',
      'settlement.payoutScheduleId',
    },
    review => const {
      'declarations.informationAccurate',
      'declarations.authorizedToSubmit',
      'declarations.termsAccepted',
      'declarations.termsVersion',
    },
  };

  static MerchantOnboardingStep forPath(String? path) {
    if (path == null) return review;
    if (path.startsWith('business.') || path.startsWith('contact.')) {
      return business;
    }
    if (path == 'owners' || path.startsWith('owners.')) return owners;
    if (path.startsWith('settlement.')) return settlement;
    return review;
  }
}

enum MerchantReferenceStatus { loading, ready, failure }

enum MerchantSubmissionStatus { idle, submitting, success, failure }

@freezed
abstract class MerchantOnboardingState with _$MerchantOnboardingState {
  const factory MerchantOnboardingState({
    @Default(MerchantOnboardingStep.business) MerchantOnboardingStep step,
    @Default(MerchantReferenceStatus.loading)
    MerchantReferenceStatus referenceStatus,
    MerchantReferenceDataEntity? referenceData,
    required MerchantOnboardingInput input,
    @Default(<String>{}) Set<String> touchedPaths,
    @Default(<MerchantOnboardingStep>{})
    Set<MerchantOnboardingStep> attemptedSteps,
    @Default(<MerchantValidationFailure>[])
    List<MerchantValidationFailure> localFailures,
    @Default(MerchantSubmissionStatus.idle)
    MerchantSubmissionStatus submissionStatus,
    MerchantOnboardingFailure? submissionFailure,
    @Default(false) bool isMateriallyEdited,
  }) = _MerchantOnboardingState;

  factory MerchantOnboardingState.initial() =>
      MerchantOnboardingState(input: MerchantOnboardingInput());
}

extension MerchantOnboardingStateX on MerchantOnboardingState {
  bool get isReferenceReady => referenceStatus == MerchantReferenceStatus.ready;

  bool get isSubmitting =>
      submissionStatus == MerchantSubmissionStatus.submitting;

  bool get canSubmit =>
      isReferenceReady &&
      !isSubmitting &&
      submissionStatus != MerchantSubmissionStatus.success;

  MerchantValidationFailure? failureForPath(String path) =>
      localFailures.where((f) => f.path == path).firstOrNull;

  bool isFailureVisible(MerchantValidationFailure failure) {
    final path = failure.path;
    if (path == null) return true;
    if (touchedPaths.contains(path)) return true;
    return switch (path) {
      'owners' => attemptedSteps.contains(MerchantOnboardingStep.owners),
      _ => attemptedSteps.contains(MerchantOnboardingStep.review),
    };
  }
}
