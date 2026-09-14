import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/legal_business_name.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/phone_number.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/registration_number.dart';

class BusinessProfile {
  const BusinessProfile._({
    required this.legalName,
    required this.businessTypeId,
    required this.registrationNumber,
    required this.industryId,
    required this.monthlySalesRangeId,
    required this.contactEmail,
    required this.contactPhone,
  });

  final LegalBusinessName legalName;
  final String businessTypeId;
  final RegistrationNumber? registrationNumber;
  final String industryId;
  final String monthlySalesRangeId;
  final EmailAddress contactEmail;
  final PhoneNumber contactPhone;

  static Either<List<MerchantValidationFailure>, BusinessProfile> create({
    required BusinessProfileInput input,
    required MerchantReferenceDataEntity reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    LegalBusinessName? legalName;
    String? businessTypeId;
    RegistrationNumber? registrationNumber;
    String? industryId;
    String? monthlySalesRangeId;
    EmailAddress? contactEmail;
    PhoneNumber? contactPhone;

    LegalBusinessName.create(
      input.legalName,
    ).fold(errors.add, (value) => legalName = value);

    final rawBusinessTypeId = input.businessTypeId?.trim() ?? '';
    if (rawBusinessTypeId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeRequired,
          path: 'business.businessTypeId',
        ),
      );
    } else if (reference.businessTypeById(rawBusinessTypeId) == null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeUnsupported,
          path: 'business.businessTypeId',
        ),
      );
    } else {
      businessTypeId = rawBusinessTypeId;
    }

    final businessType = businessTypeId == null
        ? null
        : reference.businessTypeById(businessTypeId);
    final registrationRaw = input.registrationNumber.trim();
    if (businessType != null &&
        businessType.requiresRegistrationNumber &&
        registrationRaw.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessRegistrationRequired,
          path: 'business.registrationNumber',
        ),
      );
    }
    if (registrationRaw.isNotEmpty) {
      RegistrationNumber.create(
        input.registrationNumber,
      ).fold(errors.add, (value) => registrationNumber = value);
    }

    final rawIndustryId = input.industryId?.trim() ?? '';
    if (rawIndustryId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryRequired,
          path: 'business.industryId',
        ),
      );
    } else if (reference.industryById(rawIndustryId) == null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryUnsupported,
          path: 'business.industryId',
        ),
      );
    } else {
      industryId = rawIndustryId;
    }

    final rawMonthlySalesRangeId = input.monthlySalesRangeId?.trim() ?? '';
    if (rawMonthlySalesRangeId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeRequired,
          path: 'business.monthlySalesRangeId',
        ),
      );
    } else if (reference.monthlySalesRangeById(rawMonthlySalesRangeId) ==
        null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeUnsupported,
          path: 'business.monthlySalesRangeId',
        ),
      );
    } else {
      monthlySalesRangeId = rawMonthlySalesRangeId;
    }

    EmailAddress.create(
      input.contactEmail,
      path: 'business.contactEmail',
    ).fold(errors.add, (value) => contactEmail = value);

    PhoneNumber.create(
      input.contactPhone,
      path: 'business.contactPhone',
    ).fold(errors.add, (value) => contactPhone = value);

    if (errors.isNotEmpty) return left(errors);

    return right(
      BusinessProfile._(
        legalName: legalName!,
        businessTypeId: businessTypeId!,
        registrationNumber: registrationNumber,
        industryId: industryId!,
        monthlySalesRangeId: monthlySalesRangeId!,
        contactEmail: contactEmail!,
        contactPhone: contactPhone!,
      ),
    );
  }
}
