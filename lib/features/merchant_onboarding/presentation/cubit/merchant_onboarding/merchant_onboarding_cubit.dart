import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/business_profile.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_declarations.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/ownership_structure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/settlement_account.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_value_objects.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_effect.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';

enum OwnerMoveDirection { up, down }

class MerchantOnboardingCubit extends Cubit<MerchantOnboardingState> {
  MerchantOnboardingCubit(this._repository, this._submitOnboarding)
    : super(MerchantOnboardingState.initial());

  final MerchantOnboardingRepository _repository;
  final SubmitMerchantOnboardingUseCase _submitOnboarding;

  final _effects = StreamController<MerchantOnboardingEffect>.broadcast();

  Stream<MerchantOnboardingEffect> get effects => _effects.stream;

  Future<void> loadReferenceData() async {
    if (state.isSubmitting) return;

    emit(state.copyWith(referenceStatus: MerchantReferenceStatus.loading));

    final result = await _repository.loadReferenceData();
    result.match(
      (failure) {
        emit(state.copyWith(referenceStatus: MerchantReferenceStatus.failure));
      },
      (reference) {
        emit(
          state.copyWith(
            referenceStatus: MerchantReferenceStatus.ready,
            referenceData: reference,
            input: state.input.copyWith(
              declarations: state.input.declarations.copyWith(
                termsVersion: reference.termsVersion,
              ),
            ),
          ),
        );
      },
    );
  }

  void businessLegalNameChanged(String value) => _updateBusiness(
    (business) => business.copyWith(legalName: value),
    touched: 'business.legalName',
  );

  void businessTypeChanged(String? id) => _updateBusiness(
    (business) =>
        business.copyWith(businessTypeId: id, clearBusinessTypeId: id == null),
    touched: 'business.businessTypeId',
  );

  void businessRegistrationNumberChanged(String value) => _updateBusiness(
    (business) => business.copyWith(registrationNumber: value),
    touched: 'business.registrationNumber',
  );

  void businessIndustryChanged(String? id) => _updateBusiness(
    (business) =>
        business.copyWith(industryId: id, clearIndustryId: id == null),
    touched: 'business.industryId',
  );

  void businessMonthlySalesRangeChanged(String? id) => _updateBusiness(
    (business) => business.copyWith(
      monthlySalesRangeId: id,
      clearMonthlySalesRangeId: id == null,
    ),
    touched: 'business.monthlySalesRangeId',
  );

  void businessContactEmailChanged(String value) => _updateBusiness(
    (business) => business.copyWith(contactEmail: value),
    touched: 'business.contactEmail',
  );

  void businessContactPhoneChanged(String value) => _updateBusiness(
    (business) => business.copyWith(contactPhone: value),
    touched: 'business.contactPhone',
  );

  void ownerNameChanged(String ownerRowId, String value) => _updateOwner(
    ownerRowId,
    (row) => row.copyWith(fullName: value),
    touched: 'owners.$ownerRowId.fullName',
  );

  void ownerRoleChanged(String ownerRowId, String? id) => _updateOwner(
    ownerRowId,
    (row) => row.copyWith(roleId: id, clearRoleId: id == null),
    touched: 'owners.$ownerRowId.roleId',
  );

  void ownerPercentageChanged(String ownerRowId, String value) => _updateOwner(
    ownerRowId,
    (row) => row.copyWith(ownershipPercentage: value),
    touched: 'owners.$ownerRowId.ownershipPercentage',
  );

  void ownerEmailChanged(String ownerRowId, String value) => _updateOwner(
    ownerRowId,
    (row) => row.copyWith(email: value),
    touched: 'owners.$ownerRowId.email',
  );

  void ownerPrimaryToggled(String ownerRowId, bool isPrimary) => _updateInput(
    (input) => input.copyWith(
      owners: input.owners
          .map(
            (row) => row.ownerRowId == ownerRowId
                ? row.copyWith(isPrimaryContact: isPrimary)
                : (isPrimary ? row.copyWith(isPrimaryContact: false) : row),
          )
          .toList(),
    ),
    material: true,
    touched: {'owners.$ownerRowId.isPrimaryContact'},
  );

  void ownerAdded() {
    _updateInput(
      (input) => input.copyWith(
        owners: [
          ...input.owners,
          OwnerInput(
            ownerRowId: OwnerRowId.generate().value,
            isPrimaryContact: input.owners.isEmpty,
          ),
        ],
      ),
      material: true,
      touched: {},
    );
  }

  void ownerRemoved(String ownerRowId) {
    _updateInput(
      (input) => input.copyWith(
        owners: input.owners
            .where((row) => row.ownerRowId != ownerRowId)
            .toList(),
        settlement: input.settlement.ownerRowId == ownerRowId
            ? input.settlement.copyWith(clearOwnerRowId: true)
            : input.settlement,
      ),
      material: true,
      touched: {},
    );
  }

  void ownerMoved(String ownerRowId, OwnerMoveDirection direction) {
    final owners = state.input.owners;
    final index = owners.indexWhere((row) => row.ownerRowId == ownerRowId);
    if (index < 0) return;

    final target = direction == OwnerMoveDirection.up ? index - 1 : index + 1;
    if (target < 0 || target >= owners.length) return;

    final reordered = [...owners];
    final moved = reordered.removeAt(index);
    reordered.insert(target, moved);

    _updateInput(
      (input) => input.copyWith(owners: reordered),
      material: true,
      touched: {},
    );
  }

  void settlementBankChanged(String? id) => _updateSettlement(
    (settlement) => settlement.copyWith(bankId: id, clearBankId: id == null),
    touched: 'settlement.bankId',
  );

  void settlementHolderNameChanged(String value) => _updateSettlement(
    (settlement) => settlement.copyWith(accountHolderName: value),
    touched: 'settlement.accountHolderName',
  );

  void settlementAccountNumberChanged(String value) => _updateSettlement(
    (settlement) => settlement.copyWith(accountNumber: value),
    touched: 'settlement.accountNumber',
  );

  void settlementHolderTypeChanged(String? id) {
    final holderType = state.referenceData?.holderTypeById(id);
    final requiresOwner = holderType?.requiresOwnerReference ?? false;

    _updateSettlement(
      (settlement) => settlement.copyWith(
        holderTypeId: id,
        clearHolderTypeId: id == null,

        clearOwnerRowId: !requiresOwner,
      ),
      touched: 'settlement.holderTypeId',
    );
  }

  void settlementOwnerReferenceChanged(String? ownerRowId) => _updateSettlement(
    (settlement) => settlement.copyWith(
      ownerRowId: ownerRowId,
      clearOwnerRowId: ownerRowId == null,
    ),
    touched: 'settlement.ownerRowId',
  );

  void settlementPayoutScheduleChanged(String? id) => _updateSettlement(
    (settlement) => settlement.copyWith(
      payoutScheduleId: id,
      clearPayoutScheduleId: id == null,
    ),
    touched: 'settlement.payoutScheduleId',
  );

  void declarationInformationAccurateToggled(bool value) => _updateInput(
    (input) => input.copyWith(
      declarations: input.declarations.copyWith(informationAccurate: value),
    ),
    material: false,
    touched: {'declarations.informationAccurate'},
  );

  void declarationAuthorizedToSubmitToggled(bool value) => _updateInput(
    (input) => input.copyWith(
      declarations: input.declarations.copyWith(authorizedToSubmit: value),
    ),
    material: false,
    touched: {'declarations.authorizedToSubmit'},
  );

  void declarationTermsAcceptedToggled(bool value) => _updateInput(
    (input) => input.copyWith(
      declarations: input.declarations.copyWith(termsAccepted: value),
    ),
    material: false,
    touched: {'declarations.termsAccepted'},
  );

  void nextTapped() {
    if (!state.isReferenceReady || state.isSubmitting) return;
    if (state.step == MerchantOnboardingStep.review) {
      unawaited(submitTapped());
      return;
    }

    final failures = _validateStep(state.step, state.input);
    final touched = _stepFieldPaths(state.step, state.input);

    if (failures.isNotEmpty) {
      emit(
        state.copyWith(
          touchedPaths: state.touchedPaths.union(touched),
          attemptedSteps: state.attemptedSteps.union({state.step}),
          localFailures: failures,
        ),
      );
      _effects.add(
        MerchantFocusFieldEffect(failures.first.path ?? failures.first.code),
      );
      return;
    }

    emit(
      state.copyWith(
        step: _nextStep(state.step),
        touchedPaths: state.touchedPaths.union(touched),
        attemptedSteps: state.attemptedSteps.union({state.step}),
        localFailures: [],
      ),
    );
  }

  void backTapped() {
    if (state.isSubmitting) return;
    if (state.step == MerchantOnboardingStep.business) {
      _requestLeave();
      return;
    }
    emit(state.copyWith(step: _previousStep(state.step)));
  }

  void editStepRequested(MerchantOnboardingStep step) {
    if (state.isSubmitting) return;
    emit(state.copyWith(step: step));
  }

  void systemBackRequested() {
    if (state.isSubmitting) return;
    _requestLeave();
  }

  void discardConfirmed() {
    if (state.isSubmitting) return;
    _effects.add(const MerchantLeaveEffect());
  }

  Future<void> submitTapped() async {
    final reference = state.referenceData;
    if (!state.canSubmit || reference == null) return;

    emit(
      state.copyWith(
        submissionStatus: MerchantSubmissionStatus.submitting,
        submissionFailure: null,
      ),
    );

    final result = await _submitOnboarding(
      input: state.input,
      reference: reference,
    );

    if (isClosed) return;

    result.match(
      (failure) {
        if (failure is MerchantLocalValidationFailure ||
            failure is MerchantServerValidationFailure) {
          final failures = switch (failure) {
            MerchantLocalValidationFailure(:final failures) => failures,
            MerchantServerValidationFailure(:final failures) => failures,
            _ => const <MerchantValidationFailure>[],
          };
          final targetStep = _stepForPath(failures.first.path);
          emit(
            state.copyWith(
              submissionStatus: MerchantSubmissionStatus.failure,
              localFailures: failures,
              attemptedSteps: state.attemptedSteps.union({targetStep}),
              step: targetStep,
            ),
          );
          _effects.add(
            MerchantFocusFieldEffect(
              failures.first.path ?? failures.first.code,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            submissionStatus: MerchantSubmissionStatus.failure,
            submissionFailure: failure,
          ),
        );
      },
      (receipt) {
        emit(
          state.copyWith(
            submissionStatus: MerchantSubmissionStatus.success,
            localFailures: [],

            input: MerchantOnboardingInput(),
            touchedPaths: {},
            attemptedSteps: {},
            isMateriallyEdited: false,
          ),
        );
        _effects.add(MerchantSubmittedEffect(receipt.applicationId));
      },
    );
  }

  void _requestLeave() {
    if (state.isMateriallyEdited &&
        state.submissionStatus != MerchantSubmissionStatus.success) {
      _effects.add(const MerchantConfirmDiscardEffect());
      return;
    }
    _effects.add(const MerchantLeaveEffect());
  }

  void _updateBusiness(
    BusinessProfileInput Function(BusinessProfileInput) update, {
    required String touched,
  }) {
    _updateInput(
      (input) => input.copyWith(business: update(input.business)),
      material: true,
      touched: {touched},
    );
  }

  void _updateOwner(
    String ownerRowId,
    OwnerInput Function(OwnerInput) update, {
    required String touched,
  }) {
    _updateInput(
      (input) => input.copyWith(
        owners: input.owners
            .map((row) => row.ownerRowId == ownerRowId ? update(row) : row)
            .toList(),
      ),
      material: true,
      touched: {touched},
    );
  }

  void _updateSettlement(
    SettlementInput Function(SettlementInput) update, {
    required String touched,
  }) {
    _updateInput(
      (input) => input.copyWith(settlement: update(input.settlement)),
      material: true,
      touched: {touched},
    );
  }

  void _updateInput(
    MerchantOnboardingInput Function(MerchantOnboardingInput) update, {
    required bool material,
    required Set<String> touched,
  }) {
    if (!state.isReferenceReady || state.isSubmitting) return;

    var nextInput = update(state.input);
    if (material) {
      nextInput = nextInput.copyWith(
        declarations: nextInput.declarations.copyWith(
          informationAccurate: false,
          authorizedToSubmit: false,
          termsAccepted: false,
        ),
      );
    }

    final failures = _validateStep(state.step, nextInput).where((failure) {
      return _isFailureVisibleDuringEdit(failure, touched);
    }).toList();

    emit(
      state.copyWith(
        input: nextInput,
        touchedPaths: state.touchedPaths.union(touched),
        isMateriallyEdited: state.isMateriallyEdited || material,
        localFailures: failures,
      ),
    );
  }

  bool _isFailureVisibleDuringEdit(
    MerchantValidationFailure failure,
    Set<String> justTouched,
  ) {
    final path = failure.path;
    if (path == null) return true;
    if (state.touchedPaths.contains(path) || justTouched.contains(path)) {
      return true;
    }
    return switch (path) {
      'owners' => attemptedContains(state.step),
      _ => false,
    };
  }

  bool attemptedContains(MerchantOnboardingStep step) =>
      state.attemptedSteps.contains(step);

  List<MerchantValidationFailure> _validateStep(
    MerchantOnboardingStep step,
    MerchantOnboardingInput input,
  ) {
    final reference = state.referenceData;
    if (reference == null) return const [];

    return switch (step) {
      MerchantOnboardingStep.business => BusinessProfile.create(
        input: input.business,
        reference: reference,
      ).fold((f) => f, (_) => []),
      MerchantOnboardingStep.owners => OwnershipStructure.create(
        rows: input.owners,
        reference: reference,
      ).fold((f) => f, (_) => []),
      MerchantOnboardingStep.settlement => SettlementAccount.create(
        input: input.settlement,
        reference: reference,
      ).fold((f) => f, (_) => []),
      MerchantOnboardingStep.review => MerchantDeclarations.create(
        input: input.declarations,
        reference: reference,
      ).fold((f) => f, (_) => []),
    };
  }

  Set<String> _stepFieldPaths(
    MerchantOnboardingStep step,
    MerchantOnboardingInput input,
  ) {
    switch (step) {
      case MerchantOnboardingStep.business:
        return const {
          'business.legalName',
          'business.businessTypeId',
          'business.registrationNumber',
          'business.industryId',
          'business.monthlySalesRangeId',
          'business.contactEmail',
          'business.contactPhone',
        };
      case MerchantOnboardingStep.owners:
        return {
          for (final row in input.owners) ...[
            'owners.${row.ownerRowId}.fullName',
            'owners.${row.ownerRowId}.roleId',
            'owners.${row.ownerRowId}.ownershipPercentage',
            'owners.${row.ownerRowId}.email',
            'owners.${row.ownerRowId}.isPrimaryContact',
          ],
          'owners',
        };
      case MerchantOnboardingStep.settlement:
        return const {
          'settlement.bankId',
          'settlement.accountHolderName',
          'settlement.accountNumber',
          'settlement.holderTypeId',
          'settlement.ownerRowId',
          'settlement.payoutScheduleId',
        };
      case MerchantOnboardingStep.review:
        return const {
          'declarations.informationAccurate',
          'declarations.authorizedToSubmit',
          'declarations.termsAccepted',
          'declarations.termsVersion',
        };
    }
  }

  MerchantOnboardingStep _nextStep(MerchantOnboardingStep step) =>
      switch (step) {
        MerchantOnboardingStep.business => MerchantOnboardingStep.owners,
        MerchantOnboardingStep.owners => MerchantOnboardingStep.settlement,
        MerchantOnboardingStep.settlement => MerchantOnboardingStep.review,
        MerchantOnboardingStep.review => MerchantOnboardingStep.review,
      };

  MerchantOnboardingStep _previousStep(MerchantOnboardingStep step) =>
      switch (step) {
        MerchantOnboardingStep.business => MerchantOnboardingStep.business,
        MerchantOnboardingStep.owners => MerchantOnboardingStep.business,
        MerchantOnboardingStep.settlement => MerchantOnboardingStep.owners,
        MerchantOnboardingStep.review => MerchantOnboardingStep.settlement,
      };

  MerchantOnboardingStep _stepForPath(String? path) {
    if (path == null) return MerchantOnboardingStep.review;
    if (path.startsWith('business.') || path.startsWith('contact.')) {
      return MerchantOnboardingStep.business;
    }
    if (path == 'owners' || path.startsWith('owners.')) {
      return MerchantOnboardingStep.owners;
    }
    if (path.startsWith('settlement.')) {
      return MerchantOnboardingStep.settlement;
    }
    return MerchantOnboardingStep.review;
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
