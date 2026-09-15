import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_effect.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/models/owner_move_direction.dart';
import 'package:mocktail/mocktail.dart';

import '../../domain/merchant_test_fixtures.dart';

class _MockMerchantOnboardingRepository extends Mock
    implements MerchantOnboardingRepository {}

class _MockSubmitMerchantOnboardingUseCase extends Mock
    implements SubmitMerchantOnboardingUseCase {}

void main() {
  late _MockMerchantOnboardingRepository repository;
  late _MockSubmitMerchantOnboardingUseCase submitUseCase;
  late MerchantOnboardingCubit cubit;

  setUpAll(() {
    registerFallbackValue(MerchantOnboardingInput());
    registerFallbackValue(buildReferenceData());
  });

  setUp(() {
    repository = _MockMerchantOnboardingRepository();
    submitUseCase = _MockSubmitMerchantOnboardingUseCase();
    when(
      () => repository.loadReferenceData(),
    ).thenAnswer((_) async => Right(buildReferenceData()));
    cubit = MerchantOnboardingCubit(repository, submitUseCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.step, MerchantOnboardingStep.business);
    expect(cubit.state.referenceStatus, MerchantReferenceStatus.loading);
    expect(cubit.state.referenceData, isNull);
    expect(cubit.state.isMateriallyEdited, isFalse);
  });

  test('loadReferenceData succeeds and populates reference', () async {
    await cubit.loadReferenceData();

    expect(cubit.state.referenceStatus, MerchantReferenceStatus.ready);
    expect(cubit.state.referenceData, isNotNull);
    expect(cubit.state.input.declarations.termsVersion, '2026-08-30');
  });

  test('loadReferenceData sets failure status on error', () async {
    when(
      () => repository.loadReferenceData(),
    ).thenAnswer((_) async => const Left(MerchantUnexpectedFailure()));

    await cubit.loadReferenceData();

    expect(cubit.state.referenceStatus, MerchantReferenceStatus.failure);
    expect(cubit.state.referenceData, isNull);
  });

  test(
    'updating business fields updates state and resets declarations',
    () async {
      await cubit.loadReferenceData();
      cubit.declarationInformationAccurateToggled(true);
      expect(cubit.state.input.declarations.informationAccurate, isTrue);

      cubit.businessLegalNameChanged('PT Maju Jaya');
      expect(cubit.state.input.business.legalName, 'PT Maju Jaya');
      expect(cubit.state.touchedPaths, contains('business.legalName'));
      expect(cubit.state.isMateriallyEdited, isTrue);
      expect(cubit.state.input.declarations.informationAccurate, isFalse);

      cubit.businessTypeChanged('individual');
      expect(cubit.state.input.business.businessTypeId, 'individual');

      cubit.businessRegistrationNumberChanged('123456');
      expect(cubit.state.input.business.registrationNumber, '123456');

      cubit.businessIndustryChanged('retail');
      expect(cubit.state.input.business.industryId, 'retail');

      cubit.businessMonthlySalesRangeChanged('under_10m');
      expect(cubit.state.input.business.monthlySalesRangeId, 'under_10m');

      cubit.businessContactEmailChanged('test@example.com');
      expect(cubit.state.input.business.contactEmail, 'test@example.com');

      cubit.businessContactPhoneChanged('+628123456789');
      expect(cubit.state.input.business.contactPhone, '+628123456789');
    },
  );

  test('owner operations add, update, move, and remove correctly', () async {
    await cubit.loadReferenceData();

    cubit.ownerAdded();
    expect(cubit.state.input.owners.length, 1);
    final firstId = cubit.state.input.owners.first.ownerRowId;
    expect(cubit.state.input.owners.first.isPrimaryContact, isTrue);

    cubit.ownerAdded();
    expect(cubit.state.input.owners.length, 2);
    final secondId = cubit.state.input.owners[1].ownerRowId;
    expect(cubit.state.input.owners[1].isPrimaryContact, isFalse);

    cubit.ownerNameChanged(firstId, 'Alice');
    cubit.ownerRoleChanged(firstId, 'director');
    cubit.ownerPercentageChanged(firstId, '50');
    cubit.ownerEmailChanged(firstId, 'alice@example.com');

    expect(cubit.state.input.owners.first.fullName, 'Alice');
    expect(cubit.state.input.owners.first.roleId, 'director');
    expect(cubit.state.input.owners.first.ownershipPercentage, '50');
    expect(cubit.state.input.owners.first.email, 'alice@example.com');

    cubit.ownerPrimaryToggled(secondId, true);
    expect(
      cubit.state.input.owners
          .firstWhere((o) => o.ownerRowId == firstId)
          .isPrimaryContact,
      isFalse,
    );
    expect(
      cubit.state.input.owners
          .firstWhere((o) => o.ownerRowId == secondId)
          .isPrimaryContact,
      isTrue,
    );

    cubit.ownerMoved(secondId, OwnerMoveDirection.up);
    expect(cubit.state.input.owners.first.ownerRowId, secondId);

    cubit.settlementOwnerReferenceChanged(firstId);
    expect(cubit.state.input.settlement.ownerRowId, firstId);

    cubit.ownerRemoved(firstId);
    expect(cubit.state.input.owners.length, 1);
    expect(cubit.state.input.settlement.ownerRowId, isNull);
  });

  test('settlement field updates and clearing owner reference', () async {
    await cubit.loadReferenceData();

    cubit.settlementBankChanged('bca');
    cubit.settlementHolderNameChanged('PT Maju');
    cubit.settlementAccountNumberChanged('1234567890');
    cubit.settlementPayoutScheduleChanged('daily');

    expect(cubit.state.input.settlement.bankId, 'bca');
    expect(cubit.state.input.settlement.accountHolderName, 'PT Maju');
    expect(cubit.state.input.settlement.accountNumber, '1234567890');
    expect(cubit.state.input.settlement.payoutScheduleId, 'daily');

    cubit.settlementOwnerReferenceChanged('owner_1');
    expect(cubit.state.input.settlement.ownerRowId, 'owner_1');

    cubit.settlementHolderTypeChanged('business');
    expect(cubit.state.input.settlement.holderTypeId, 'business');
    expect(cubit.state.input.settlement.ownerRowId, isNull);
  });

  test('nextStep validates current step and stops on error', () async {
    await cubit.loadReferenceData();

    final effects = <MerchantOnboardingEffect>[];
    final sub = cubit.effects.listen(effects.add);

    cubit.nextTapped();
    await pumpEventQueue();

    expect(cubit.state.step, MerchantOnboardingStep.business);
    expect(cubit.state.localFailures, isNotEmpty);
    expect(effects.first, isA<MerchantFocusFieldEffect>());

    await sub.cancel();
  });

  test('nextStep advances when step is valid', () async {
    await cubit.loadReferenceData();

    cubit.businessLegalNameChanged('PT Valid Name');
    cubit.businessTypeChanged('sole_proprietorship');
    cubit.businessRegistrationNumberChanged('REG123456');
    cubit.businessIndustryChanged('retail');
    cubit.businessMonthlySalesRangeChanged('under_10m_idr');
    cubit.businessContactEmailChanged('contact@ptvalid.com');
    cubit.businessContactPhoneChanged('+6281234567890');

    cubit.nextTapped();
    await pumpEventQueue();

    expect(cubit.state.step, MerchantOnboardingStep.owners);
    expect(cubit.state.localFailures, isEmpty);
  });

  test('backStep navigates back or emits confirm discard', () async {
    await cubit.loadReferenceData();

    final effects = <MerchantOnboardingEffect>[];
    final sub = cubit.effects.listen(effects.add);

    cubit.backTapped();
    await pumpEventQueue();
    expect(effects.first, isA<MerchantLeaveEffect>());

    cubit.businessLegalNameChanged('PT Edited');
    cubit.backTapped();
    await pumpEventQueue();
    expect(effects[1], isA<MerchantConfirmDiscardEffect>());

    cubit.editStepRequested(MerchantOnboardingStep.owners);
    cubit.backTapped();
    await pumpEventQueue();
    expect(cubit.state.step, MerchantOnboardingStep.business);

    cubit.systemBackRequested();
    await pumpEventQueue();
    expect(effects.last, isA<MerchantConfirmDiscardEffect>());

    cubit.discardConfirmed();
    await pumpEventQueue();
    expect(effects.last, isA<MerchantLeaveEffect>());

    await sub.cancel();
  });

  test(
    'submit failure redirects to target step and emits focus effect',
    () async {
      await cubit.loadReferenceData();
      when(
        () => submitUseCase(
          input: any(named: 'input'),
          reference: any(named: 'reference'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          MerchantLocalValidationFailure([
            MerchantValidationFailure(
              code: 'required',
              path: 'business.legalName',
            ),
          ]),
        ),
      );

      final effects = <MerchantOnboardingEffect>[];
      final sub = cubit.effects.listen(effects.add);

      cubit.editStepRequested(MerchantOnboardingStep.review);
      await cubit.submitTapped();
      await pumpEventQueue();

      expect(cubit.state.submissionStatus, MerchantSubmissionStatus.failure);
      expect(cubit.state.step, MerchantOnboardingStep.business);
      expect(effects.single, isA<MerchantFocusFieldEffect>());
      expect(
        (effects.single as MerchantFocusFieldEffect).path,
        'business.legalName',
      );

      await sub.cancel();
    },
  );

  test('submit success updates state and emits submitted effect', () async {
    await cubit.loadReferenceData();
    when(
      () => submitUseCase(
        input: any(named: 'input'),
        reference: any(named: 'reference'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right(MerchantApplicationReceipt(applicationId: 'app_123')),
    );

    final effects = <MerchantOnboardingEffect>[];
    final sub = cubit.effects.listen(effects.add);

    cubit.editStepRequested(MerchantOnboardingStep.review);
    await cubit.submitTapped();
    await pumpEventQueue();

    expect(cubit.state.submissionStatus, MerchantSubmissionStatus.success);
    expect(cubit.state.isMateriallyEdited, isFalse);
    expect(effects.single, isA<MerchantSubmittedEffect>());
    expect(
      (effects.single as MerchantSubmittedEffect).applicationId,
      'app_123',
    );

    await sub.cancel();
  });

  test('submit transport failure emits submit-failure effect', () async {
    await cubit.loadReferenceData();
    when(
      () => submitUseCase(
        input: any(named: 'input'),
        reference: any(named: 'reference'),
      ),
    ).thenAnswer((_) async => const Left(MerchantRetryableFailure()));

    final effects = <MerchantOnboardingEffect>[];
    final sub = cubit.effects.listen(effects.add);

    cubit.editStepRequested(MerchantOnboardingStep.review);
    await cubit.submitTapped();
    await pumpEventQueue();

    expect(cubit.state.submissionStatus, MerchantSubmissionStatus.failure);
    expect(effects.single, isA<MerchantSubmitFailureEffect>());

    await sub.cancel();
  });
}
