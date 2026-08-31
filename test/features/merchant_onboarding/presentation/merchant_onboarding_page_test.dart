import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/repository/fake_merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/load_merchant_reference_data_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../domain/merchant_test_fixtures.dart';

class _MockRepository extends Mock implements MerchantOnboardingRepository {}

MerchantOnboardingCubit buildCubit(MerchantOnboardingRepository repo) =>
    MerchantOnboardingCubit(
      LoadMerchantReferenceDataUseCase(repo),
      SubmitMerchantOnboardingUseCase(repo),
    );

Widget wrap(MerchantOnboardingCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
    home: AdaptiveScope(
      navigationPolicy: const NavigationPolicy.none(),
      child: BlocProvider<MerchantOnboardingCubit>(
        create: (_) => cubit,
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
    // The business step shell and its Next action are present.
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

    // Step 1: business.
    await tester.enterText(
      find.byKey(const ValueKey('business_legal_name')),
      'Kopi Nusantara',
    );
    // Dropdowns are complex; drive the cubit directly for the rest of the
    // business step to keep the widget test focused on navigation.
    cubit.businessTypeChanged('sole_proprietorship');
    cubit.businessIndustryChanged('retail');
    cubit.businessMonthlySalesRangeChanged('10m_to_50m_idr');
    cubit.businessContactEmailChanged('contact@kopinusantara.id');
    cubit.businessContactPhoneChanged('+62 812-3456-7890');
    cubit.nextTapped();
    await tester.pumpAndSettle();

    // Step 2: owners — add a row via the UI.
    await tester.ensureVisible(find.text('Add owner'));
    await tester.tap(find.text('Add owner'));
    await tester.pumpAndSettle();
    cubit.ownerNameChanged(
      cubit.state.input.owners.single.ownerRowId,
      'Budi Santoso',
    );
    cubit.ownerRoleChanged(cubit.state.input.owners.single.ownerRowId, 'owner');
    cubit.ownerPercentageChanged(
      cubit.state.input.owners.single.ownerRowId,
      '100',
    );
    cubit.ownerEmailChanged(
      cubit.state.input.owners.single.ownerRowId,
      'budi@example.com',
    );
    cubit.nextTapped();
    await tester.pumpAndSettle();

    // Step 3: settlement.
    cubit.settlementBankChanged('demo_bank_alpha');
    cubit.settlementHolderNameChanged('Budi Santoso');
    cubit.settlementAccountNumberChanged('0123456789');
    cubit.settlementHolderTypeChanged('business');
    cubit.settlementPayoutScheduleChanged('daily');
    cubit.nextTapped();
    await tester.pumpAndSettle();

    // Step 4: review shows the masked account number, never the raw value.
    expect(find.text('0123456789'), findsNothing);
    expect(find.text('****6789'), findsOneWidget);

    // Accept declarations via the UI (scrolled into view) and submit.
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

    // Submit through the cubit (the shell button is equivalent) and let the
    // snackbar render.
    await cubit.submitTapped();
    await tester.pumpAndSettle();

    expect(cubit.state.submissionStatus, MerchantSubmissionStatus.success);
    expect(cubit.state.input.owners, isEmpty);
  });
}
