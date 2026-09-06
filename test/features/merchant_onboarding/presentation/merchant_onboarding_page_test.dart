import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../domain/merchant_test_fixtures.dart';
import '../support/fake_merchant_onboarding_repository.dart';

class _MockRepository extends Mock implements MerchantOnboardingRepository {}

MerchantOnboardingCubit buildCubit(MerchantOnboardingRepository repo) =>
    MerchantOnboardingCubit(repo, SubmitMerchantOnboardingUseCase(repo));

Widget wrap(MerchantOnboardingCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
    home: AdaptiveScope(
      navigationPolicy: const NavigationPolicy.none(),
      child: BlocProvider<MerchantOnboardingCubit>(
        create: (_) => cubit..loadReferenceData(),
        child: const MerchantOnboardingPage(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      MerchantOnboardingApplication.create(
        input: validInput(),
        reference: buildReferenceData(),
      ).getRight().toNullable()!,
    );
  });

  testWidgets('shows loading then renders the business step after reference', (
    tester,
  ) async {
    final repo = _MockRepository();
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

    await tester.pumpWidget(wrap(buildCubit(repo)));
    await tester.pumpAndSettle();

    expect(find.text('Kopi Nusantara'), findsNothing);
    expect(
      find.text(
        FakeMerchantOnboardingRepository.demoReferenceData()
            .businessTypes
            .first
            .label,
      ),
      findsNothing,
    );
    expect(find.byType(MerchantOnboardingPage), findsOneWidget);
  });

  testWidgets('retry renders after a reference load failure', (tester) async {
    var calls = 0;
    final repo = _MockRepository();
    when(() => repo.loadReferenceData()).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? left(const MerchantUnexpectedFailure())
          : right(FakeMerchantOnboardingRepository.demoReferenceData());
    });
    when(() => repo.submitApplication(any())).thenAnswer(
      (_) async => right(
        const MerchantApplicationReceipt(
          applicationId: FakeMerchantOnboardingRepository.demoApplicationId,
        ),
      ),
    );

    await tester.pumpWidget(wrap(buildCubit(repo)));
    await tester.pumpAndSettle();

    expect(find.text('Reference data failed to load.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Reference data failed to load.'), findsNothing);
  });

  testWidgets('happy path reaches review and submits', (tester) async {
    final repo = _MockRepository();
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
    final cubit = buildCubit(repo);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('business_legal_name')),
      'Kopi Nusantara',
    );
    cubit.businessTypeChanged('sole_proprietorship');
    cubit.businessIndustryChanged('retail');
    cubit.businessMonthlySalesRangeChanged('10m_to_50m_idr');
    cubit.businessContactEmailChanged('contact@kopinusantara.id');
    cubit.businessContactPhoneChanged('+62 812-3456-7890');
    cubit.nextTapped();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add owner'));
    await tester.tap(find.text('Add owner'));
    await tester.pumpAndSettle();
    final ownerId = cubit.state.input.owners.single.ownerRowId;
    cubit.ownerNameChanged(ownerId, 'Budi Santoso');
    cubit.ownerRoleChanged(ownerId, 'owner');
    cubit.ownerPercentageChanged(ownerId, '100');
    cubit.ownerEmailChanged(ownerId, 'budi@example.com');
    cubit.nextTapped();
    await tester.pumpAndSettle();

    cubit.settlementBankChanged('demo_bank_alpha');
    cubit.settlementHolderNameChanged('Budi Santoso');
    cubit.settlementAccountNumberChanged('0123456789');
    cubit.settlementHolderTypeChanged('business');
    cubit.settlementPayoutScheduleChanged('daily');
    cubit.nextTapped();
    await tester.pumpAndSettle();

    expect(find.text('0123456789'), findsNothing);
    expect(find.text('****6789'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('declaration_information_accurate')),
    );
    await tester.tap(
      find.byKey(const ValueKey('declaration_information_accurate')),
    );
    await tester.tap(
      find.byKey(const ValueKey('declaration_authorized_to_submit')),
    );
    await tester.tap(find.byKey(const ValueKey('declaration_terms_accepted')));
    await tester.pumpAndSettle();

    cubit.submitTapped();
    await tester.pumpAndSettle();

    expect(cubit.state.submissionStatus, MerchantSubmissionStatus.success);
    expect(cubit.state.input.owners, isEmpty);
  });

  testWidgets(
    'successful submission pops back to the caller screen and shows snackbar',
    (tester) async {
      final repo = _MockRepository();
      when(() => repo.loadReferenceData()).thenAnswer(
        (_) async =>
            right(FakeMerchantOnboardingRepository.demoReferenceData()),
      );
      when(() => repo.submitApplication(any())).thenAnswer(
        (_) async => right(
          const MerchantApplicationReceipt(
            applicationId: FakeMerchantOnboardingRepository.demoApplicationId,
          ),
        ),
      );
      final cubit = buildCubit(repo);
      await cubit.loadReferenceData();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light().copyWith(
            splashFactory: NoSplash.splashFactory,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdaptiveScope(
                          navigationPolicy: const NavigationPolicy.none(),
                          child: BlocProvider<MerchantOnboardingCubit>.value(
                            value: cubit,
                            child: const MerchantOnboardingPage(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Onboarding'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Onboarding'));
      await tester.pumpAndSettle();

      expect(find.byType(MerchantOnboardingPage), findsOneWidget);

      cubit.businessLegalNameChanged('Kopi Nusantara');
      cubit.businessTypeChanged('sole_proprietorship');
      cubit.businessIndustryChanged('retail');
      cubit.businessMonthlySalesRangeChanged('10m_to_50m_idr');
      cubit.businessContactEmailChanged('contact@kopinusantara.id');
      cubit.businessContactPhoneChanged('+62 812-3456-7890');
      cubit.nextTapped();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add owner'));
      await tester.tap(find.text('Add owner'));
      await tester.pumpAndSettle();
      final ownerId = cubit.state.input.owners.single.ownerRowId;
      cubit.ownerNameChanged(ownerId, 'Budi Santoso');
      cubit.ownerRoleChanged(ownerId, 'owner');
      cubit.ownerPercentageChanged(ownerId, '100');
      cubit.ownerEmailChanged(ownerId, 'budi@example.com');
      cubit.nextTapped();
      await tester.pumpAndSettle();

      cubit.settlementBankChanged('demo_bank_alpha');
      cubit.settlementHolderNameChanged('Budi Santoso');
      cubit.settlementAccountNumberChanged('0123456789');
      cubit.settlementHolderTypeChanged('business');
      cubit.settlementPayoutScheduleChanged('daily');
      cubit.nextTapped();
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('declaration_information_accurate')),
      );
      await tester.tap(
        find.byKey(const ValueKey('declaration_information_accurate')),
      );
      await tester.tap(
        find.byKey(const ValueKey('declaration_authorized_to_submit')),
      );
      await tester.tap(
        find.byKey(const ValueKey('declaration_terms_accepted')),
      );
      await tester.pumpAndSettle();

      cubit.submitTapped();
      await tester.pumpAndSettle();

      expect(find.byType(MerchantOnboardingPage), findsNothing);
      expect(find.text('Open Onboarding'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining(FakeMerchantOnboardingRepository.demoApplicationId),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'system back navigates to previous step on steps 2-4 instead of exiting',
    (tester) async {
      final repo = _MockRepository();
      when(() => repo.loadReferenceData()).thenAnswer(
        (_) async =>
            right(FakeMerchantOnboardingRepository.demoReferenceData()),
      );

      final cubit = buildCubit(repo);
      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      // Advance to Owners step
      cubit.editStepRequested(MerchantOnboardingStep.owners);
      await tester.pumpAndSettle();
      expect(cubit.state.step, MerchantOnboardingStep.owners);

      // Trigger system back
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Must navigate back to Business step, not pop the page
      expect(cubit.state.step, MerchantOnboardingStep.business);
      expect(find.byType(MerchantOnboardingPage), findsOneWidget);
    },
  );
}
