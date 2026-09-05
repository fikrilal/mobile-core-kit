import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/business_type_id.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/industry_id.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/legal_business_name.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/monthly_sales_range_id.dart';
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
  final BusinessTypeId businessTypeId;
  final RegistrationNumber? registrationNumber;
  final IndustryId industryId;
  final MonthlySalesRangeId monthlySalesRangeId;
  final EmailAddress contactEmail;
  final PhoneNumber contactPhone;

  static Either<List<MerchantValidationFailure>, BusinessProfile> create({
    required BusinessProfileInput input,
    required MerchantReferenceDataEntity reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    LegalBusinessName? legalName;
    BusinessTypeId? businessTypeId;
    RegistrationNumber? registrationNumber;
    IndustryId? industryId;
    MonthlySalesRangeId? monthlySalesRangeId;
    EmailAddress? contactEmail;
    PhoneNumber? contactPhone;

    LegalBusinessName.create(
      input.legalName,
    ).fold(errors.add, (value) => legalName = value);

    BusinessTypeId.create(
      input.businessTypeId,
      reference,
    ).fold(errors.add, (value) => businessTypeId = value);

    final businessType = businessTypeId == null
        ? null
        : reference.businessTypeById(businessTypeId!.value);
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

    IndustryId.create(
      input.industryId,
      reference,
    ).fold(errors.add, (value) => industryId = value);

    MonthlySalesRangeId.create(
      input.monthlySalesRangeId,
      reference,
    ).fold(errors.add, (value) => monthlySalesRangeId = value);

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
