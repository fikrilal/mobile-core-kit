import 'dart:math';

import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';

/// Shared 2–100 character trimmed-name rule for legal business names, person
/// names, and bank account holder names.
MerchantValidationFailure? _validateTrimmedName({
  required String raw,
  required String requiredCode,
  required String invalidCode,
  required String? path,
}) {
  final value = raw.trim();
  if (value.isEmpty) {
    return MerchantValidationFailure(code: requiredCode, path: path);
  }
  if (value.length < 2 || value.length > 100) {
    return MerchantValidationFailure(code: invalidCode, path: path);
  }
  return null;
}

class LegalBusinessName {
  const LegalBusinessName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, LegalBusinessName> create(
    String raw,
  ) {
    final failure = _validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.businessLegalNameRequired,
      invalidCode: MerchantValidationCodes.businessLegalNameInvalid,
      path: 'business.legalName',
    );
    if (failure != null) return left(failure);
    return right(LegalBusinessName._(raw.trim()));
  }
}

class PersonName {
  const PersonName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, PersonName> create(
    String raw, {
    required String path,
  }) {
    final failure = _validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.ownerNameRequired,
      invalidCode: MerchantValidationCodes.ownerNameInvalid,
      path: path,
    );
    if (failure != null) return left(failure);
    return right(PersonName._(raw.trim()));
  }
}

class BankAccountHolderName {
  const BankAccountHolderName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, BankAccountHolderName> create(
    String raw,
  ) {
    final failure = _validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.settlementHolderNameRequired,
      invalidCode: MerchantValidationCodes.settlementHolderNameInvalid,
      path: 'settlement.accountHolderName',
    );
    if (failure != null) return left(failure);
    return right(BankAccountHolderName._(raw.trim()));
  }
}

/// Trimmed, lowercased email address with pragmatic syntax validation.
class EmailAddress {
  const EmailAddress._(this.value);

  final String value;

  static Either<MerchantValidationFailure, EmailAddress> create(
    String raw, {
    required String path,
    String emptyCode = MerchantValidationCodes.contactEmailRequired,
    String invalidCode = MerchantValidationCodes.contactEmailInvalid,
  }) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return left(MerchantValidationFailure(code: emptyCode, path: path));
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(value)) {
      return left(MerchantValidationFailure(code: invalidCode, path: path));
    }
    return right(EmailAddress._(value));
  }
}

/// Phone number normalized to `+<digits>` (E.164 shape) with a supported
/// total digit length of 8–15. Formatting characters are ignored.
class PhoneNumber {
  const PhoneNumber._(this.value);

  final String value;

  static Either<MerchantValidationFailure, PhoneNumber> create(
    String raw, {
    required String path,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.contactPhoneRequired,
          path: path,
        ),
      );
    }

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[\s\-().]'), '');
    final digitCount = hasPlus ? digits.length - 1 : digits.length;
    final allDigits = RegExp(r'^\+?\d+$').hasMatch(digits);
    final nationalNumber = hasPlus ? digits.substring(1) : digits;

    // E.164 requires a country code; a leading zero after '+' (or a bare
    // national number starting with 0) is not a valid E.164 number.
    final hasCountryCode =
        digitCount >= 8 && digitCount <= 15 && !nationalNumber.startsWith('0');

    if (!allDigits || !hasCountryCode) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.contactPhoneInvalid,
          path: path,
        ),
      );
    }

    final value = hasPlus ? digits : '+$digits';
    return right(PhoneNumber._(value));
  }
}

/// Trimmed, uppercased registration number: 4–30 ASCII letters, digits, or
/// dashes.
class RegistrationNumber {
  const RegistrationNumber._(this.value);

  final String value;

  static Either<MerchantValidationFailure, RegistrationNumber> create(
    String raw,
  ) {
    final value = raw.trim().toUpperCase();
    if (value.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessRegistrationRequired,
          path: 'business.registrationNumber',
        ),
      );
    }
    if (!RegExp(r'^[A-Z0-9-]{4,30}$').hasMatch(value)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessRegistrationInvalid,
          path: 'business.registrationNumber',
        ),
      );
    }
    return right(RegistrationNumber._(value));
  }
}

/// Ownership share stored as exact integer basis points (100.00% = 10000).
/// Accepts 0.01–100.00 with at most two fractional digits.
class OwnershipPercentage {
  const OwnershipPercentage._(this.basisPoints);

  final int basisPoints;

  double get asPercent => basisPoints / 100;

  static Either<MerchantValidationFailure, OwnershipPercentage> create(
    String raw, {
    required String path,
  }) {
    final value = raw.trim();
    if (value.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageRequired,
          path: path,
        ),
      );
    }

    final match = RegExp(r'^(\d{1,3})(\.(\d{1,2}))?$').firstMatch(value);
    if (match == null) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageInvalid,
          path: path,
        ),
      );
    }

    final whole = int.parse(match.group(1)!);
    final fraction = match.group(3) ?? '';
    final basisPoints = whole * 100 + int.parse(fraction.padRight(2, '0'));

    if (basisPoints < 1 || basisPoints > 10000) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageInvalid,
          path: path,
        ),
      );
    }

    return right(OwnershipPercentage._(basisPoints));
  }
}

/// Bank account number as text: spaces removed, 6–24 digits, leading zeroes
/// preserved. Never a numeric value.
class BankAccountNumber {
  const BankAccountNumber._(this.value);

  final String value;

  String get masked =>
      value.length <= 4 ? value : '****${value.substring(value.length - 4)}';

  static Either<MerchantValidationFailure, BankAccountNumber> create(
    String raw,
  ) {
    final value = raw.replaceAll(' ', '');
    if (value.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementAccountNumberRequired,
          path: 'settlement.accountNumber',
        ),
      );
    }
    if (!RegExp(r'^\d{6,24}$').hasMatch(value)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementAccountNumberInvalid,
          path: 'settlement.accountNumber',
        ),
      );
    }
    return right(BankAccountNumber._(value));
  }
}

/// Stable local identifier for one owners-step row. Generated when the row is
/// added; edits, reordering, and deletion of other rows never change it.
class OwnerRowId {
  const OwnerRowId._(this.value);

  final String value;

  static Either<MerchantValidationFailure, OwnerRowId> create(
    String raw, {
    required String path,
  }) {
    final value = raw.trim();
    if (value.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownersRequired,
          path: path,
        ),
      );
    }
    return right(OwnerRowId._(value));
  }

  /// Generates a random UUID-shaped identifier (version 4 style).
  static OwnerRowId generate() {
    final values = List<int>.generate(16, (_) => _rowIdRandom.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return OwnerRowId._(
      '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}',
    );
  }

  static final Random _rowIdRandom = Random();
}

/// Terms version accepted by the user; must equal the snapshot version.
class TermsVersion {
  const TermsVersion._(this.value);

  final String value;

  static Either<MerchantValidationFailure, TermsVersion> create(
    String raw,
    MerchantReferenceData reference,
  ) {
    final value = raw.trim();
    if (value.isEmpty || value != reference.termsVersion) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.declarationsTermsVersionStale,
          path: 'declarations.termsVersion',
        ),
      );
    }
    return right(TermsVersion._(value));
  }
}
