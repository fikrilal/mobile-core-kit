import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';

/// Returns the first validation error whose field matches one of the provided
/// candidates exactly or by suffix.
ValidationError? findFirstValidationErrorForFields(
  List<ValidationError> errors,
  List<String> fieldCandidates,
) {
  for (final err in errors) {
    final field = err.field;
    if (field == null || field.isEmpty) continue;

    for (final candidate in fieldCandidates) {
      if (field == candidate || field.endsWith(candidate)) return err;
    }
  }
  return null;
}
