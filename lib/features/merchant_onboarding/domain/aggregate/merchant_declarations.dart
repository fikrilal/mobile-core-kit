import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_value_objects.dart';

/// Validated step-4 aggregate. All three declarations must be accepted and
/// the terms version must equal the reference snapshot version.
class MerchantDeclarations {
  const MerchantDeclarations._({
    required this.informationAccurate,
    required this.authorizedToSubmit,
    required this.termsAccepted,
    required this.termsVersion,
  });

  final bool informationAccurate;
  final bool authorizedToSubmit;
  final bool termsAccepted;
  final TermsVersion termsVersion;

  static Either<List<MerchantValidationFailure>, MerchantDeclarations> create({
    required DeclarationsInput input,
    required MerchantReferenceData reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    TermsVersion? termsVersion;

    if (!input.informationAccurate) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.declarationsInformationAccurateRequired,
          path: 'declarations.informationAccurate',
        ),
      );
    }
    if (!input.authorizedToSubmit) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.declarationsAuthorizedToSubmitRequired,
          path: 'declarations.authorizedToSubmit',
        ),
      );
    }
    if (!input.termsAccepted) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.declarationsTermsAcceptedRequired,
          path: 'declarations.termsAccepted',
        ),
      );
    }

    TermsVersion.create(
      input.termsVersion,
      reference,
    ).fold(errors.add, (value) => termsVersion = value);

    if (errors.isNotEmpty) return left(errors);

    return right(
      MerchantDeclarations._(
        informationAccurate: input.informationAccurate,
        authorizedToSubmit: input.authorizedToSubmit,
        termsAccepted: input.termsAccepted,
        termsVersion: termsVersion!,
      ),
    );
  }
}
