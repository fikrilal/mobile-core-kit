import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/ownership_structure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_owner_row_card.dart';

/// Step 2: dynamic owner rows plus the ownership aggregate summary.
class OwnersStepWidget extends StatelessWidget {
  const OwnersStepWidget({
    super.key,
    required this.owners,
    required this.reference,
    required this.cubit,
    required this.failures,
    required this.registerFocus,
  });

  final List<OwnerInput> owners;
  final MerchantReferenceData reference;
  final MerchantOnboardingCubit cubit;
  final List<MerchantValidationFailure> failures;
  final RegisterFocus registerFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final aggregateFailures = failures.where((f) => f.path == 'owners');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final failure in aggregateFailures)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: Text(
              messageForMerchantValidationFailure(failure, l10n),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        for (final (index, row) in owners.indexed)
          MerchantOwnerRowCard(
            row: row,
            index: index,
            reference: reference,
            cubit: cubit,
            failures: failures,
            registerFocus: registerFocus,
          ),
        AppButton.outline(
          text: l10n.merchantOnboardingActionAddOwner,
          icon: const Icon(Icons.add),
          isExpanded: true,
          isDisabled: owners.length >= OwnershipStructure.maxRows,
          onPressed: cubit.ownerAdded,
        ),
      ],
    );
  }
}
