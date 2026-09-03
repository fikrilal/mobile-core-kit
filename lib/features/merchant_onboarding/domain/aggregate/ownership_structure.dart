import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_value_objects.dart';

class OwnerRow {
  const OwnerRow._({
    required this.id,
    required this.fullName,
    required this.roleId,
    required this.percentage,
    required this.email,
    required this.isPrimaryContact,
  });

  final OwnerRowId id;
  final PersonName fullName;
  final OwnerRoleId roleId;

  final OwnershipPercentage? percentage;
  final EmailAddress email;
  final bool isPrimaryContact;
}

class OwnershipStructure {
  OwnershipStructure._(List<OwnerRow> rows) : rows = List.unmodifiable(rows);

  static const int minRows = 1;
  static const int maxRows = 5;
  static const int requiredTotalBasisPoints = 10000;

  final List<OwnerRow> rows;

  bool containsRow(String ownerRowId) =>
      rows.any((row) => row.id.value == ownerRowId);

  static Either<List<MerchantValidationFailure>, OwnershipStructure> create({
    required List<OwnerInput> rows,
    required MerchantReferenceData reference,
  }) {
    if (rows.length < minRows) {
      return left([
        const MerchantValidationFailure(
          code: MerchantValidationCodes.ownersRequired,
          path: 'owners',
        ),
      ]);
    }
    if (rows.length > maxRows) {
      return left([
        const MerchantValidationFailure(
          code: MerchantValidationCodes.ownersLimitExceeded,
          path: 'owners',
        ),
      ]);
    }

    final errors = <MerchantValidationFailure>[];
    final validRows = <OwnerRow>[];
    final seenEmails = <String>{};
    final seenRowIds = <String>{};
    final duplicateLaterRowIds = <String>[];
    var primaryCount = 0;
    var summedBasisPoints = 0;

    for (final row in rows) {
      final rowPath = 'owners.${row.ownerRowId}';
      PersonName? fullName;
      OwnerRoleId? roleId;
      OwnershipPercentage? percentage;
      EmailAddress? email;

      final parsedRowId = OwnerRowId.create(row.ownerRowId, path: rowPath).fold(
        (failure) {
          errors.add(failure);
          return null;
        },
        (value) => value,
      );

      if (parsedRowId != null && seenRowIds.contains(parsedRowId.value)) {
        errors.add(
          MerchantValidationFailure(
            code: MerchantValidationCodes.ownersRowIdDuplicate,
            path: '$rowPath.ownerRowId',
          ),
        );
      } else if (parsedRowId != null) {
        seenRowIds.add(parsedRowId.value);
      }

      PersonName.create(
        row.fullName,
        path: '$rowPath.fullName',
      ).fold(errors.add, (value) => fullName = value);

      OwnerRoleId.create(
        row.roleId,
        reference,
        path: '$rowPath.roleId',
      ).fold(errors.add, (value) => roleId = value);

      final role = roleId == null
          ? null
          : reference.ownerRoleById(roleId!.value);
      if (role != null) {
        final percentageRaw = row.ownershipPercentage.trim();
        if (role.contributesOwnership) {
          OwnershipPercentage.create(
            row.ownershipPercentage,
            path: '$rowPath.ownershipPercentage',
          ).fold(errors.add, (value) => percentage = value);
        } else if (percentageRaw.isNotEmpty) {
          errors.add(
            MerchantValidationFailure(
              code: MerchantValidationCodes.ownerPercentageNotAllowed,
              path: '$rowPath.ownershipPercentage',
            ),
          );
        }
      }

      EmailAddress.create(
        row.email,
        path: '$rowPath.email',
        emptyCode: MerchantValidationCodes.ownerEmailRequired,
        invalidCode: MerchantValidationCodes.ownerEmailInvalid,
      ).fold(errors.add, (value) => email = value);

      final parsedName = fullName;
      final parsedRoleId = roleId;
      final parsedPercentage = percentage;
      final parsedEmail = email;

      if (parsedEmail != null) {
        if (seenEmails.contains(parsedEmail.value)) {
          duplicateLaterRowIds.add(row.ownerRowId);
        } else {
          seenEmails.add(parsedEmail.value);
        }
      }

      if (row.isPrimaryContact) primaryCount++;

      if (role != null &&
          role.contributesOwnership &&
          parsedPercentage != null) {
        summedBasisPoints += parsedPercentage.basisPoints;
      }

      if (parsedName != null &&
          parsedRoleId != null &&
          parsedEmail != null &&
          parsedRowId != null) {
        validRows.add(
          OwnerRow._(
            id: parsedRowId,
            fullName: parsedName,
            roleId: parsedRoleId,
            percentage: parsedPercentage,
            email: parsedEmail,
            isPrimaryContact: row.isPrimaryContact,
          ),
        );
      }
    }

    for (final ownerRowId in duplicateLaterRowIds) {
      errors.add(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownersEmailDuplicate,
          path: 'owners.$ownerRowId.email',
        ),
      );
    }

    if (primaryCount != 1) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.ownersPrimaryInvalid,
          path: 'owners',
        ),
      );
    }

    if (summedBasisPoints != requiredTotalBasisPoints) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.ownersTotalInvalid,
          path: 'owners',
        ),
      );
    }

    if (errors.isNotEmpty) return left(errors);

    return right(OwnershipStructure._(validRows));
  }
}
