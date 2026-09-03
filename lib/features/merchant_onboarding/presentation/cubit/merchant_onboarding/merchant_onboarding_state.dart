import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';

part 'merchant_onboarding_state.freezed.dart';

enum MerchantOnboardingStep { business, owners, settlement, review }

enum MerchantReferenceStatus { loading, ready, failure }

enum MerchantSubmissionStatus { idle, submitting, success, failure }

@freezed
abstract class MerchantOnboardingState with _$MerchantOnboardingState {
  const factory MerchantOnboardingState({
    @Default(MerchantOnboardingStep.business) MerchantOnboardingStep step,
    @Default(MerchantReferenceStatus.loading)
    MerchantReferenceStatus referenceStatus,
    MerchantReferenceData? referenceData,
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
