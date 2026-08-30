import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/family_name.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/given_name.dart';

/// Validated profile details accepted by the profile repository boundary.
class ProfileDetails {
  const ProfileDetails._({
    required this.givenName,
    required this.familyName,
    required this.displayName,
  });

  final GivenName givenName;
  final FamilyName? familyName;

  /// Trim-only optional display name; blank becomes null. No length rule.
  final String? displayName;

  static Either<List<ValidationError>, ProfileDetails> create({
    required String givenName,
    String? familyName,
    String? displayName,
  }) {
    final givenResult = GivenName.create(givenName);
    final familyResult = FamilyName.createOptional(familyName ?? '');
    final errors = <ValidationError>[];
    GivenName? validGiven;
    FamilyName? validFamily;

    givenResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'givenName', message: '', code: failure.code),
      ),
      (value) => validGiven = value,
    );
    familyResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'familyName', message: '', code: failure.code),
      ),
      (value) => validFamily = value,
    );

    if (errors.isNotEmpty) return left(errors);

    final displayNameTrimmed = displayName?.trim();
    final normalizedDisplayName =
        (displayNameTrimmed == null || displayNameTrimmed.isEmpty)
        ? null
        : displayNameTrimmed;

    return right(
      ProfileDetails._(
        givenName: validGiven!,
        familyName: validFamily,
        displayName: normalizedDisplayName,
      ),
    );
  }
}
