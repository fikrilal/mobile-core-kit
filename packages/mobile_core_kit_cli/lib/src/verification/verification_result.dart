import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';

class VerificationStepOutcome {
  const VerificationStepOutcome({
    required this.profile,
    required this.step,
    required this.exitCode,
    required this.duration,
  });

  final VerificationProfile profile;
  final VerificationStep step;
  final int exitCode;
  final Duration duration;

  bool get passed => exitCode == 0;
}

typedef VerificationObserver = void Function(VerificationStepOutcome outcome);
