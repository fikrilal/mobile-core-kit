import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/foundation/utilities/uuid_v4_utils.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/business_profile.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_declarations.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/ownership_structure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/settlement_account.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_effect.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/models/owner_move_direction.dart';

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
      (_) => emit(
        state.copyWith(referenceStatus: MerchantReferenceStatus.failure),
      ),
      (reference) => emit(
        state.copyWith(
          referenceStatus: MerchantReferenceStatus.ready,
          referenceData: reference,
          input: state.input.copyWith(
            declarations: state.input.declarations.copyWith(
              termsVersion: reference.termsVersion,
            ),
          ),
        ),
      ),
    );
  }

  void businessLegalNameChanged(String v) =>
      _updateBusiness((b) => b.copyWith(legalName: v), 'business.legalName');

  void businessTypeChanged(String? id) => _updateBusiness(
    (b) => b.copyWith(businessTypeId: id, clearBusinessTypeId: id == null),
    'business.businessTypeId',
  );

  void businessRegistrationNumberChanged(String v) => _updateBusiness(
    (b) => b.copyWith(registrationNumber: v),
    'business.registrationNumber',
  );

  void businessIndustryChanged(String? id) => _updateBusiness(
    (b) => b.copyWith(industryId: id, clearIndustryId: id == null),
    'business.industryId',
  );

  void businessMonthlySalesRangeChanged(String? id) => _updateBusiness(
    (b) => b.copyWith(
      monthlySalesRangeId: id,
      clearMonthlySalesRangeId: id == null,
    ),
    'business.monthlySalesRangeId',
  );

  void businessContactEmailChanged(String v) => _updateBusiness(
    (b) => b.copyWith(contactEmail: v),
    'business.contactEmail',
  );

  void businessContactPhoneChanged(String v) => _updateBusiness(
    (b) => b.copyWith(contactPhone: v),
    'business.contactPhone',
  );

  void ownerNameChanged(String id, String v) =>
      _updateOwner(id, (r) => r.copyWith(fullName: v), 'owners.$id.fullName');

  void ownerRoleChanged(String id, String? roleId) => _updateOwner(
    id,
    (r) => r.copyWith(roleId: roleId, clearRoleId: roleId == null),
    'owners.$id.roleId',
  );

  void ownerPercentageChanged(String id, String v) => _updateOwner(
    id,
    (r) => r.copyWith(ownershipPercentage: v),
    'owners.$id.ownershipPercentage',
  );

  void ownerEmailChanged(String id, String v) =>
      _updateOwner(id, (r) => r.copyWith(email: v), 'owners.$id.email');

  void ownerPrimaryToggled(String id, bool isPrimary) => _updateInput(
    (i) => i.copyWith(
      owners: i.owners
          .map(
            (r) => r.ownerRowId == id
                ? r.copyWith(isPrimaryContact: isPrimary)
                : (isPrimary ? r.copyWith(isPrimaryContact: false) : r),
          )
          .toList(),
    ),
    material: true,
    touched: {'owners.$id.isPrimaryContact'},
  );

  void ownerAdded() => _updateInput(
    (i) => i.copyWith(
      owners: [
        ...i.owners,
        OwnerInput(
          ownerRowId: UuidV4Utils.generate(),
          isPrimaryContact: i.owners.isEmpty,
        ),
      ],
    ),
    material: true,
    touched: {},
  );

  void ownerRemoved(String id) => _updateInput(
    (i) => i.copyWith(
      owners: i.owners.where((r) => r.ownerRowId != id).toList(),
      settlement: i.settlement.ownerRowId == id
          ? i.settlement.copyWith(clearOwnerRowId: true)
          : i.settlement,
    ),
    material: true,
    touched: {},
  );

  void ownerMoved(String id, OwnerMoveDirection dir) {
    final owners = state.input.owners;
    final idx = owners.indexWhere((r) => r.ownerRowId == id);
    final target = dir == OwnerMoveDirection.up ? idx - 1 : idx + 1;
    if (idx < 0 || target < 0 || target >= owners.length) return;

    final reordered = [...owners];
    reordered.insert(target, reordered.removeAt(idx));
    _updateInput(
      (i) => i.copyWith(owners: reordered),
      material: true,
      touched: {},
    );
  }

  void settlementBankChanged(String? id) => _updateSettlement(
    (s) => s.copyWith(bankId: id, clearBankId: id == null),
    'settlement.bankId',
  );

  void settlementHolderNameChanged(String v) => _updateSettlement(
    (s) => s.copyWith(accountHolderName: v),
    'settlement.accountHolderName',
  );

  void settlementAccountNumberChanged(String v) => _updateSettlement(
    (s) => s.copyWith(accountNumber: v),
    'settlement.accountNumber',
  );

  void settlementHolderTypeChanged(String? id) {
    final requiresOwner =
        state.referenceData?.holderTypeById(id)?.requiresOwnerReference ??
        false;
    _updateSettlement(
      (s) => s.copyWith(
        holderTypeId: id,
        clearHolderTypeId: id == null,
        clearOwnerRowId: !requiresOwner,
      ),
      'settlement.holderTypeId',
    );
  }

  void settlementOwnerReferenceChanged(String? id) => _updateSettlement(
    (s) => s.copyWith(ownerRowId: id, clearOwnerRowId: id == null),
    'settlement.ownerRowId',
  );

  void settlementPayoutScheduleChanged(String? id) => _updateSettlement(
    (s) => s.copyWith(payoutScheduleId: id, clearPayoutScheduleId: id == null),
    'settlement.payoutScheduleId',
  );

  void declarationInformationAccurateToggled(bool v) => _updateInput(
    (i) => i.copyWith(
      declarations: i.declarations.copyWith(informationAccurate: v),
    ),
    material: false,
    touched: {'declarations.informationAccurate'},
  );

  void declarationAuthorizedToSubmitToggled(bool v) => _updateInput(
    (i) => i.copyWith(
      declarations: i.declarations.copyWith(authorizedToSubmit: v),
    ),
    material: false,
    touched: {'declarations.authorizedToSubmit'},
  );

  void declarationTermsAcceptedToggled(bool v) => _updateInput(
    (i) => i.copyWith(declarations: i.declarations.copyWith(termsAccepted: v)),
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
    final touched = state.step.fieldPaths(state.input);

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
        step: state.step.next,
        touchedPaths: state.touchedPaths.union(touched),
        attemptedSteps: state.attemptedSteps.union({state.step}),
        localFailures: const [],
      ),
    );
  }

  void backTapped() {
    if (state.isSubmitting) return;
    if (state.step == MerchantOnboardingStep.business) {
      _requestLeave();
      return;
    }
    emit(state.copyWith(step: state.step.previous));
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
          final targetStep = MerchantOnboardingStep.forPath(
            failures.first.path,
          );
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
            localFailures: const [],
            input: MerchantOnboardingInput(),
            touchedPaths: const {},
            attemptedSteps: const {},
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
    BusinessProfileInput Function(BusinessProfileInput) update,
    String touched,
  ) {
    _updateInput(
      (i) => i.copyWith(business: update(i.business)),
      material: true,
      touched: {touched},
    );
  }

  void _updateOwner(
    String id,
    OwnerInput Function(OwnerInput) update,
    String touched,
  ) {
    _updateInput(
      (i) => i.copyWith(
        owners: i.owners
            .map((r) => r.ownerRowId == id ? update(r) : r)
            .toList(),
      ),
      material: true,
      touched: {touched},
    );
  }

  void _updateSettlement(
    SettlementInput Function(SettlementInput) update,
    String touched,
  ) {
    _updateInput(
      (i) => i.copyWith(settlement: update(i.settlement)),
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

    final failures = _validateStep(state.step, nextInput).where((f) {
      final path = f.path;
      if (path == null) return true;
      if (state.touchedPaths.contains(path) || touched.contains(path)) {
        return true;
      }
      return path == 'owners' && state.attemptedSteps.contains(state.step);
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

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
