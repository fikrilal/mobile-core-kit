import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/repository/fake_merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/load_merchant_reference_data_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_effect.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../domain/merchant_test_fixtures.dart';

class _MockMerchantOnboardingRepository extends Mock
    implements MerchantOnboardingRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      MerchantOnboardingApplication.create(
        input: validInput(),
        reference: buildReferenceData(),
      ).getRight().toNullable()!,
    );
  });

  late _MockMerchantOnboardingRepository repo;
  late MerchantOnboardingCubit cubit;
  late List<MerchantOnboardingEffect> effects;

  setUp(() {
    repo = _MockMerchantOnboardingRepository();
    when(() => repo.loadReferenceData()).thenAnswer(
      (_) async => right(FakeMerchantOnboardingRepository.demoReferenceData()),
    );
    when(() => repo.submitApplication(any())).thenAnswer(
      (_) async => right(
        const MerchantApplicationReceipt(
          applicationId: FakeMerchantOnboardingRepository.demoApplicationId,
        ),
      ),
    );

    cubit = MerchantOnboardingCubit(
      LoadMerchantReferenceDataUseCase(repo),
      SubmitMerchantOnboardingUseCase(repo),
    );
    effects = [];
    cubit.effects.listen(effects.add);
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> loadReady() async {
    await cubit.loadReferenceData();
  }

  /// Fills business + owners + settlement and walks to the review step.
  /// Returns the generated owner row id.
  Future<String> walkToReview() async {
    await loadReady();
    cubit.businessLegalNameChanged('Kopi Nusantara');
    cubit.businessTypeChanged('sole_proprietorship');
    cubit.businessIndustryChanged('retail');
    cubit.businessMonthlySalesRangeChanged('10m_to_50m_idr');
    cubit.businessContactEmailChanged('contact@kopinusantara.id');
    cubit.businessContactPhoneChanged('+62 812-3456-7890');
    cubit.nextTapped();

    cubit.ownerAdded();
    final ownerId = cubit.state.input.owners.single.ownerRowId;
    cubit.ownerNameChanged(ownerId, 'Budi Santoso');
    cubit.ownerRoleChanged(ownerId, 'owner');
    cubit.ownerPercentageChanged(ownerId, '100');
    cubit.ownerEmailChanged(ownerId, 'budi@example.com');
    cubit.ownerPrimaryToggled(ownerId, true);
    cubit.nextTapped();

    cubit.settlementBankChanged('demo_bank_alpha');
    cubit.settlementHolderNameChanged('Budi Santoso');
    cubit.settlementAccountNumberChanged('0123456789');
    cubit.settlementHolderTypeChanged('business');
    cubit.settlementPayoutScheduleChanged('daily');
    cubit.nextTapped();
    await pumpEventQueue();
    return ownerId;
  }

  group('reference data', () {
    test('loads the snapshot and stamps the terms version', () async {
      await loadReady();

      expect(cubit.state.referenceStatus, MerchantReferenceStatus.ready);
      expect(cubit.state.referenceData, isNotNull);
      expect(cubit.state.input.declarations.termsVersion, '2026-08-30');
    });

    test('exposes failure state for a failed load', () async {
      when(
        () => repo.loadReferenceData(),
      ).thenAnswer((_) async => left(const MerchantUnexpectedFailure()));

      await cubit.loadReferenceData();

      expect(cubit.state.referenceStatus, MerchantReferenceStatus.failure);
    });

    test('retry loads the snapshot again', () async {
      var calls = 0;
      when(() => repo.loadReferenceData()).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? left<MerchantOnboardingFailure, MerchantReferenceData>(
                const MerchantUnexpectedFailure(),
              )
            : right(FakeMerchantOnboardingRepository.demoReferenceData());
      });

      await cubit.loadReferenceData();
      await cubit.loadReferenceData();

      expect(cubit.state.referenceStatus, MerchantReferenceStatus.ready);
    });
  });

  group('step preflight (acceptance scenarios 2 and 3)', () {
    test(
      'stays on step one, shows all failures, focuses the first field',
      () async {
        await loadReady();

        cubit.nextTapped();
        await pumpEventQueue();

        expect(cubit.state.step, MerchantOnboardingStep.business);
        expect(cubit.state.localFailures, isNotEmpty);
        expect(cubit.state.localFailures.first.path, 'business.legalName');
        expect(
          effects.whereType<MerchantFocusFieldEffect>().single.path,
          'business.legalName',
        );
      },
    );

    test(
      'requires registration even when the widget was never touched',
      () async {
        await loadReady();
        cubit.businessLegalNameChanged('Kopi Nusantara');
        cubit.businessTypeChanged('private_company');

        cubit.nextTapped();
        await pumpEventQueue();

        expect(cubit.state.step, MerchantOnboardingStep.business);
        expect(
          cubit.state.localFailures.any(
            (f) => f.code == 'business.registration.required',
          ),
          true,
        );
      },
    );
  });

  group('owner rows', () {
    test('edits preserve stable row ids', () async {
      await loadReady();

      cubit.ownerAdded();
      final firstId = cubit.state.input.owners.single.ownerRowId;
      cubit.ownerNameChanged(firstId, 'Budi Santoso');

      cubit.ownerAdded();
      final secondId = cubit.state.input.owners.last.ownerRowId;
      expect(secondId, isNot(firstId));

      cubit.ownerNameChanged(secondId, 'Sari Dewi');
      cubit.ownerEmailChanged(secondId, 'sari@example.com');

      expect(
        cubit.state.input.owners.map((r) => r.ownerRowId),
        containsAll([firstId, secondId]),
      );
      expect(cubit.state.input.owners.last.fullName, 'Sari Dewi');
      expect(cubit.state.input.owners.first.fullName, 'Budi Santoso');
    });

    test('moving rows keeps ids attached to their values', () async {
      await loadReady();

      cubit.ownerAdded();
      final firstId = cubit.state.input.owners.first.ownerRowId;
      cubit.ownerAdded();
      final secondId = cubit.state.input.owners.last.ownerRowId;
      cubit.ownerNameChanged(secondId, 'Sari Dewi');

      cubit.ownerMoved(secondId, OwnerMoveDirection.up);

      expect(cubit.state.input.owners.first.ownerRowId, secondId);
      expect(cubit.state.input.owners.first.fullName, 'Sari Dewi');
      expect(cubit.state.input.owners.last.ownerRowId, firstId);
    });

    test(
      'removing the settlement-referenced owner clears the reference (acceptance 6)',
      () async {
        await loadReady();

        cubit.ownerAdded();
        final ownerId = cubit.state.input.owners.single.ownerRowId;
        cubit.settlementHolderTypeChanged('owner');
        cubit.settlementOwnerReferenceChanged(ownerId);
        expect(cubit.state.input.settlement.ownerRowId, ownerId);

        cubit.ownerRemoved(ownerId);

        expect(cubit.state.input.settlement.ownerRowId, isNull);
        expect(cubit.state.input.owners, isEmpty);
      },
    );
  });

  group('declaration reset (acceptance 8)', () {
    test('material edits reset declarations but keep the draft', () async {
      await walkToReview();

      cubit.declarationInformationAccurateToggled(true);
      cubit.declarationAuthorizedToSubmitToggled(true);
      cubit.declarationTermsAcceptedToggled(true);
      expect(cubit.state.input.declarations.informationAccurate, true);

      cubit.editStepRequested(MerchantOnboardingStep.business);
      cubit.businessLegalNameChanged('Kopi Nusantara Baru');

      expect(cubit.state.input.declarations.informationAccurate, false);
      expect(cubit.state.input.declarations.authorizedToSubmit, false);
      expect(cubit.state.input.declarations.termsAccepted, false);
      expect(cubit.state.input.business.legalName, 'Kopi Nusantara Baru');
      expect(cubit.state.isMateriallyEdited, true);

      // Pure step movement does not reset declarations again.
      final afterMovement = cubit.state.input.declarations;
      cubit.editStepRequested(MerchantOnboardingStep.review);
      cubit.backTapped();
      expect(cubit.state.input.declarations, afterMovement);
    });
  });

  group('submit', () {
    test('valid input reaches the fake repository exactly once (11)', () async {
      await walkToReview();
      cubit.declarationInformationAccurateToggled(true);
      cubit.declarationAuthorizedToSubmitToggled(true);
      cubit.declarationTermsAcceptedToggled(true);

      await cubit.submitTapped();
      await cubit.submitTapped(); // rapid double tap

      verify(() => repo.submitApplication(any())).called(1);
      expect(cubit.state.submissionStatus, MerchantSubmissionStatus.success);
      await pumpEventQueue();
      expect(
        effects.whereType<MerchantSubmittedEffect>().single.applicationId,
        FakeMerchantOnboardingRepository.demoApplicationId,
      );
      // The in-memory draft was cleared on success.
      expect(cubit.state.input.owners, isEmpty);
      expect(cubit.state.input.business, const BusinessProfileInput());
      expect(cubit.state.input.declarations, const DeclarationsInput());
    });

    test('invalid final input never reaches the repository (10)', () async {
      await walkToReview();
      // Invalidate the settlement after every step previously passed.
      cubit.settlementBankChanged(null);

      await cubit.submitTapped();
      await pumpEventQueue();

      verifyNever(() => repo.submitApplication(any()));
      expect(cubit.state.submissionStatus, MerchantSubmissionStatus.failure);
      expect(cubit.state.step, MerchantOnboardingStep.settlement);
      expect(
        effects.whereType<MerchantFocusFieldEffect>().last.path,
        'settlement.bankId',
      );
    });

    test(
      'non-validation failures stay on review with a banner failure',
      () async {
        await walkToReview();
        cubit.declarationInformationAccurateToggled(true);
        cubit.declarationAuthorizedToSubmitToggled(true);
        cubit.declarationTermsAcceptedToggled(true);
        when(() => repo.submitApplication(any())).thenAnswer(
          (_) async => left(const MerchantDuplicateApplicationFailure()),
        );

        await cubit.submitTapped();
        await pumpEventQueue();

        expect(cubit.state.step, MerchantOnboardingStep.review);
        expect(
          cubit.state.submissionFailure,
          isA<MerchantDuplicateApplicationFailure>(),
        );
      },
    );
  });

  group('discard confirmation (acceptance 13)', () {
    test(
      'materially edited draft asks for confirmation before leaving',
      () async {
        await loadReady();
        cubit.businessLegalNameChanged('Kopi Nusantara');

        cubit.systemBackRequested();
        await pumpEventQueue();

        expect(effects.whereType<MerchantConfirmDiscardEffect>(), hasLength(1));
        expect(effects.whereType<MerchantLeaveEffect>(), isEmpty);
      },
    );

    test('untouched draft leaves without confirmation', () async {
      await loadReady();

      cubit.systemBackRequested();
      await pumpEventQueue();

      expect(effects.whereType<MerchantLeaveEffect>(), hasLength(1));
      expect(effects.whereType<MerchantConfirmDiscardEffect>(), isEmpty);
    });

    test('confirming discard requests leave', () async {
      await loadReady();
      cubit.businessLegalNameChanged('Kopi Nusantara');
      cubit.systemBackRequested();
      await pumpEventQueue();

      cubit.discardConfirmed();
      await pumpEventQueue();

      expect(effects.whereType<MerchantLeaveEffect>(), hasLength(1));
    });
  });
}
