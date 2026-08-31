import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/ownership_structure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

import '../merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  List<String> codes(List<MerchantValidationFailure> failures) =>
      failures.map((f) => f.code).toList();

  test('constructs a single 100% owning primary-contact row', () {
    final result = OwnershipStructure.create(
      rows: [validOwnerInput()],
      reference: reference,
    );

    final structure = result.getRight().toNullable()!;
    expect(structure.rows, hasLength(1));
    expect(structure.rows.first.percentage!.basisPoints, 10000);
    expect(structure.rows.first.isPrimaryContact, true);
  });

  test('requires at least one row', () {
    final failures = OwnershipStructure.create(
      rows: const [],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(codes(failures), [MerchantValidationCodes.ownersRequired]);
    expect(failures.first.path, 'owners');
  });

  test('rejects more than five rows', () {
    final failures = OwnershipStructure.create(
      rows: List.generate(6, (i) => validOwnerInput(ownerRowId: 'row-$i')),
      reference: reference,
    ).getLeft().toNullable()!;
    expect(codes(failures), [MerchantValidationCodes.ownersLimitExceeded]);
  });

  test('attaches duplicate normalized email to the later row', () {
    final failures = OwnershipStructure.create(
      rows: [
        validOwnerInput(ownerRowId: 'row-1', email: 'owner@example.com'),
        validOwnerInput(
          ownerRowId: 'row-2',
          email: '  Owner@Example.com ',
          ownershipPercentage: '',
          roleId: 'director',
        ),
      ],
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      codes(failures),
      contains(MerchantValidationCodes.ownersEmailDuplicate),
    );
    expect(
      failures
          .firstWhere(
            (f) => f.code == MerchantValidationCodes.ownersEmailDuplicate,
          )
          .path,
      'owners.row-2.email',
    );
  });

  test('rejects zero or multiple primary contacts', () {
    final noPrimary = OwnershipStructure.create(
      rows: [validOwnerInput(isPrimaryContact: false)],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(
      codes(noPrimary),
      contains(MerchantValidationCodes.ownersPrimaryInvalid),
    );

    final twoPrimary = OwnershipStructure.create(
      rows: [
        validOwnerInput(ownerRowId: 'row-1', ownershipPercentage: '50'),
        validOwnerInput(ownerRowId: 'row-2', ownershipPercentage: '50'),
      ],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(
      codes(twoPrimary),
      contains(MerchantValidationCodes.ownersPrimaryInvalid),
    );
  });

  test('rejects ownership totals that are not exactly 100%', () {
    final failures = OwnershipStructure.create(
      rows: [
        validOwnerInput(ownerRowId: 'row-1', ownershipPercentage: '50.00'),
        validOwnerInput(ownerRowId: 'row-2', ownershipPercentage: '49.99'),
      ],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(
      codes(failures),
      contains(MerchantValidationCodes.ownersTotalInvalid),
    );
  });

  test('accepts multiple rows totaling exactly 100%', () {
    final result = OwnershipStructure.create(
      rows: [
        validOwnerInput(
          ownerRowId: 'row-1',
          fullName: 'Budi Santoso',
          ownershipPercentage: '33.33',
        ),
        validOwnerInput(
          ownerRowId: 'row-2',
          fullName: 'Sari Dewi',
          ownershipPercentage: '66.67',
          email: 'sari@example.com',
          isPrimaryContact: false,
        ),
      ],
      reference: reference,
    );

    expect(result.isRight(), true);
  });

  test('requires percentage for owning roles and forbids it otherwise', () {
    final missing = OwnershipStructure.create(
      rows: [validOwnerInput(ownershipPercentage: '')],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(
      missing.any(
        (f) =>
            f.code == MerchantValidationCodes.ownerPercentageRequired &&
            f.path == 'owners.row-1.ownershipPercentage',
      ),
      true,
    );

    final notAllowed = OwnershipStructure.create(
      rows: [validOwnerInput(roleId: 'director', ownershipPercentage: '50')],
      reference: reference,
    ).getLeft().toNullable()!;
    expect(
      notAllowed.any(
        (f) =>
            f.code == MerchantValidationCodes.ownerPercentageNotAllowed &&
            f.path == 'owners.row-1.ownershipPercentage',
      ),
      true,
    );
  });

  test('normalizes row ids before duplicate detection', () {
    // 'row-1' and ' row-1 ' normalize to the same id and must collide.
    final failures = OwnershipStructure.create(
      rows: [
        validOwnerInput(ownerRowId: 'row-1'),
        validOwnerInput(
          ownerRowId: ' row-1 ',
          email: 'sari@example.com',
          isPrimaryContact: false,
        ),
      ],
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.any(
        (f) => f.code == MerchantValidationCodes.ownersRowIdDuplicate,
      ),
      true,
    );
  });

  test(
    'reports row field failures with stable row-scoped paths in row order',
    () {
      final failures = OwnershipStructure.create(
        rows: [
          validOwnerInput(
            ownerRowId: 'row-1',
            fullName: '',
            email: 'broken',
            isPrimaryContact: false,
          ),
          validOwnerInput(
            ownerRowId: 'row-2',
            fullName: 'Sari Dewi',
            roleId: 'unknown-role',
          ),
        ],
        reference: reference,
      ).getLeft().toNullable()!;

      expect(failures.map((f) => f.code), [
        MerchantValidationCodes.ownerNameRequired,
        MerchantValidationCodes.ownerEmailInvalid,
        MerchantValidationCodes.ownerRoleUnsupported,
      ]);
      expect(failures.map((f) => f.path), [
        'owners.row-1.fullName',
        'owners.row-1.email',
        'owners.row-2.roleId',
      ]);
    },
  );
}
