import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/business_profile.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

import '../merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  MerchantValidationFailure? failureFor(
    BusinessProfileInput input, {
    required String code,
  }) {
    final result = BusinessProfile.create(input: input, reference: reference);
    final failures = result.getLeft().toNullable();
    return failures?.where((f) => f.code == code).firstOrNull;
  }

  test('constructs a valid profile with normalized values', () {
    final result = BusinessProfile.create(
      input: validBusinessInput(
        legalName: '  Kopi Nusantara  ',
        contactEmail: ' Contact@Example.COM ',
        contactPhone: '6281234567890',
      ),
      reference: reference,
    );

    final profile = result.getRight().toNullable()!;
    expect(profile.legalName.value, 'Kopi Nusantara');
    expect(profile.businessTypeId, 'sole_proprietorship');
    expect(profile.registrationNumber, isNull);
    expect(profile.contactEmail.value, 'contact@example.com');
    expect(profile.contactPhone.value, '+6281234567890');
  });

  test('requires registration number when the business type demands it', () {
    final failure = failureFor(
      validBusinessInput(
        businessTypeId: 'private_company',
        registrationNumber: '',
      ),
      code: MerchantValidationCodes.businessRegistrationRequired,
    );
    expect(failure, isNotNull);
    expect(failure!.path, 'business.registrationNumber');
  });

  test('accepts an optional supplied registration number and preserves it', () {
    final profile = BusinessProfile.create(
      input: validBusinessInput(registrationNumber: ' pt-2026-x1 '),
      reference: reference,
    ).getRight().toNullable()!;
    expect(profile.registrationNumber!.value, 'PT-2026-X1');
  });

  test('rejects a malformed optional registration number', () {
    expect(
      failureFor(
        validBusinessInput(registrationNumber: 'AB'),
        code: MerchantValidationCodes.businessRegistrationInvalid,
      ),
      isNotNull,
    );
  });

  test('rejects missing, unsupported, and empty catalog ids', () {
    expect(
      failureFor(
        validBusinessInput(businessTypeId: null),
        code: MerchantValidationCodes.businessTypeRequired,
      ),
      isNotNull,
    );
    expect(
      failureFor(
        validBusinessInput(businessTypeId: 'foreign_llc'),
        code: MerchantValidationCodes.businessTypeUnsupported,
      ),
      isNotNull,
    );
    expect(
      failureFor(
        validBusinessInput(industryId: 'mining'),
        code: MerchantValidationCodes.businessIndustryUnsupported,
      ),
      isNotNull,
    );
    expect(
      failureFor(
        validBusinessInput(monthlySalesRangeId: null),
        code: MerchantValidationCodes.businessSalesRangeRequired,
      ),
      isNotNull,
    );
  });

  test(
    'requires registration even when the type id has surrounding whitespace',
    () {
      // ' private_company ' normalizes to private_company, so the conditional
      // registration requirement must apply (acceptance: no bypass).
      final failures = BusinessProfile.create(
        input: validBusinessInput(
          businessTypeId: ' private_company ',
          registrationNumber: '',
        ),
        reference: reference,
      ).getLeft().toNullable()!;

      expect(
        failures.any(
          (f) => f.code == MerchantValidationCodes.businessRegistrationRequired,
        ),
        true,
      );
    },
  );

  test('aggregates all deterministic field failures in field order', () {
    final failures = BusinessProfile.create(
      input: validBusinessInput(
        legalName: '',
        businessTypeId: null,
        contactEmail: 'broken',
        contactPhone: '',
      ),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(failures.map((f) => f.code), [
      MerchantValidationCodes.businessLegalNameRequired,
      MerchantValidationCodes.businessTypeRequired,
      MerchantValidationCodes.contactEmailInvalid,
      MerchantValidationCodes.contactPhoneRequired,
    ]);
  });
}
