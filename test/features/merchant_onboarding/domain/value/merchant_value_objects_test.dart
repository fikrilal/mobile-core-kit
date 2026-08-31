import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_value_objects.dart';

import '../merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  group('LegalBusinessName', () {
    test('trims and accepts 2-100 characters', () {
      expect(
        LegalBusinessName.create(
          '  Kopi Nusantara  ',
        ).getRight().toNullable()!.value,
        'Kopi Nusantara',
      );
      expect(LegalBusinessName.create('A${'b' * 99}').isRight(), true);
    });

    test('rejects empty and out-of-bound lengths', () {
      expect(
        LegalBusinessName.create('   ').getLeft().toNullable()!.code,
        MerchantValidationCodes.businessLegalNameRequired,
      );
      expect(LegalBusinessName.create('a').isLeft(), true);
      expect(LegalBusinessName.create('a' * 101).isLeft(), true);
    });
  });

  group('EmailAddress', () {
    test('trims and lowercases', () {
      final email = EmailAddress.create(
        '  Contact@Example.COM ',
        path: 'business.contactEmail',
      ).getRight().toNullable()!;
      expect(email.value, 'contact@example.com');
    });

    test('requires and validates syntax', () {
      expect(
        EmailAddress.create('  ', path: 'p').getLeft().toNullable()!.code,
        MerchantValidationCodes.contactEmailRequired,
      );
      expect(
        EmailAddress.create(
          'not-an-email',
          path: 'p',
        ).getLeft().toNullable()!.code,
        MerchantValidationCodes.contactEmailInvalid,
      );
    });
  });

  group('PhoneNumber', () {
    test('normalizes to E.164 shape ignoring formatting', () {
      final phone = PhoneNumber.create(
        '+62 812-3456-7890',
        path: 'p',
      ).getRight().toNullable()!;
      expect(phone.value, '+6281234567890');

      final withoutPlus = PhoneNumber.create(
        '6281234567890',
        path: 'p',
      ).getRight().toNullable()!;
      expect(withoutPlus.value, '+6281234567890');
    });

    test('rejects empty, short, long, and non-digit values', () {
      expect(
        PhoneNumber.create('', path: 'p').getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneRequired,
      );
      expect(
        PhoneNumber.create('+6212345', path: 'p').getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneInvalid,
      );
      // E.164: a bare national number starting with 0 is not valid.
      expect(
        PhoneNumber.create(
          '0812345678',
          path: 'p',
        ).getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneInvalid,
      );
      // A leading zero directly after '+' is not a valid country code.
      expect(
        PhoneNumber.create(
          '+0812345678',
          path: 'p',
        ).getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneInvalid,
      );
      expect(
        PhoneNumber.create(
          '+${'6' * 16}',
          path: 'p',
        ).getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneInvalid,
      );
      expect(
        PhoneNumber.create('+62abc', path: 'p').getLeft().toNullable()!.code,
        MerchantValidationCodes.contactPhoneInvalid,
      );
    });
  });

  group('RegistrationNumber', () {
    test('trims, uppercases, and allows letters, digits, dashes', () {
      final value = RegistrationNumber.create(
        '  pt-2026-x1 ',
      ).getRight().toNullable()!.value;
      expect(value, 'PT-2026-X1');
    });

    test('rejects empty and malformed values', () {
      expect(
        RegistrationNumber.create('  ').getLeft().toNullable()!.code,
        MerchantValidationCodes.businessRegistrationRequired,
      );
      expect(RegistrationNumber.create('abc').isLeft(), true);
      expect(RegistrationNumber.create('a' * 31).isLeft(), true);
      expect(RegistrationNumber.create('AB#12').isLeft(), true);
    });
  });

  group('OwnershipPercentage', () {
    test('converts decimals to exact basis points', () {
      int bps(String raw) => OwnershipPercentage.create(
        raw,
        path: 'p',
      ).getRight().toNullable()!.basisPoints;

      expect(bps('33.33'), 3333);
      expect(bps('66.67'), 6667);
      expect(bps('100'), 10000);
      expect(bps('100.00'), 10000);
      expect(bps('0.01'), 1);
    });

    test('rejects out-of-range and malformed values', () {
      expect(
        OwnershipPercentage.create('', path: 'p').getLeft().toNullable()!.code,
        MerchantValidationCodes.ownerPercentageRequired,
      );
      for (final raw in ['0', '0.00', '100.01', '150', '33.333', 'abc', '-5']) {
        expect(
          OwnershipPercentage.create(
            raw,
            path: 'p',
          ).getLeft().toNullable()!.code,
          MerchantValidationCodes.ownerPercentageInvalid,
          reason: 'raw: $raw',
        );
      }
    });
  });

  group('BankAccountNumber', () {
    test('removes spaces, preserves leading zeroes, stays text', () {
      final value = BankAccountNumber.create(
        ' 0123 4567 89 ',
      ).getRight().toNullable()!.value;
      expect(value, '0123456789');
    });

    test('rejects empty, short, long, and non-digit values', () {
      expect(
        BankAccountNumber.create('').getLeft().toNullable()!.code,
        MerchantValidationCodes.settlementAccountNumberRequired,
      );
      expect(BankAccountNumber.create('12345').isLeft(), true);
      expect(BankAccountNumber.create('1' * 25).isLeft(), true);
      expect(BankAccountNumber.create('1234abc9').isLeft(), true);
    });

    test('masks everything except the last four digits', () {
      expect(
        BankAccountNumber.create('0123456789').getRight().toNullable()!.masked,
        '****6789',
      );
    });
  });

  group('TermsVersion', () {
    test('accepts the snapshot version', () {
      expect(TermsVersion.create('2026-08-30', reference).isRight(), true);
    });

    test('rejects stale or empty versions', () {
      expect(
        TermsVersion.create(
          '2026-01-01',
          reference,
        ).getLeft().toNullable()!.code,
        MerchantValidationCodes.declarationsTermsVersionStale,
      );
      expect(
        TermsVersion.create('', reference).getLeft().toNullable()!.code,
        MerchantValidationCodes.declarationsTermsVersionStale,
      );
    });
  });

  group('OwnerRowId', () {
    test('generates unique UUID-shaped ids', () {
      final a = OwnerRowId.generate();
      final b = OwnerRowId.generate();
      expect(a.value, isNot(b.value));
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(a.value),
        true,
      );
    });
  });
}
