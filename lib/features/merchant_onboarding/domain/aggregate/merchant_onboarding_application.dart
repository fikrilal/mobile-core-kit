import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/business_profile.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_declarations.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/ownership_structure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/settlement_account.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class MerchantOnboardingApplication {
  const MerchantOnboardingApplication._({
    required this.business,
    required this.owners,
    required this.settlement,
    required this.declarations,
  });

  final BusinessProfile business;
  final OwnershipStructure owners;
  final SettlementAccount settlement;
  final MerchantDeclarations declarations;

  static Either<List<MerchantValidationFailure>, MerchantOnboardingApplication>
  create({
    required MerchantOnboardingInput input,
    required MerchantReferenceDataEntity reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    BusinessProfile? business;
    OwnershipStructure? owners;
    SettlementAccount? settlement;
    MerchantDeclarations? declarations;

    BusinessProfile.create(
      input: input.business,
      reference: reference,
    ).fold(errors.addAll, (value) => business = value);

    OwnershipStructure.create(
      rows: input.owners,
      reference: reference,
    ).fold(errors.addAll, (value) => owners = value);

    SettlementAccount.create(
      input: input.settlement,
      reference: reference,
    ).fold(errors.addAll, (value) => settlement = value);

    MerchantDeclarations.create(
      input: input.declarations,
      reference: reference,
    ).fold(errors.addAll, (value) => declarations = value);

    final ownerHeld = settlement?.ownerRowId != null;
    if (ownerHeld && owners != null) {
      if (!owners!.containsRow(settlement!.ownerRowId!)) {
        errors.add(
          const MerchantValidationFailure(
            code: MerchantValidationCodes.settlementOwnerUnknown,
            path: 'settlement.ownerRowId',
          ),
        );
      }
    }

    if (errors.isNotEmpty) return left(errors);

    return right(
      MerchantOnboardingApplication._(
        business: business!,
        owners: owners!,
        settlement: settlement!,
        declarations: declarations!,
      ),
    );
  }
}
