import 'package:mobile_core_kit_cli/src/duplication/duplication_runner.dart';

/// Whether actionable groups fail the command or stay a review report.
enum DuplicationEnforcement { blocking, advisory }

/// `core` is the blocking sensor. `small-helpers` and `presentation` stay
/// advisory because their actionable sets are large review signals.
DuplicationEnforcement enforcementFor(DuplicationProfile profile) {
  return switch (profile) {
    DuplicationProfile.core => DuplicationEnforcement.blocking,
    DuplicationProfile.smallHelpers ||
    DuplicationProfile.presentation => DuplicationEnforcement.advisory,
  };
}

/// Exit code for a filtered report. Zero groups always pass.
int exitCodeForActionableGroups({
  required DuplicationEnforcement enforcement,
  required int actionableGroupCount,
}) {
  if (actionableGroupCount <= 0) return 0;
  return enforcement == DuplicationEnforcement.blocking ? 1 : 0;
}
