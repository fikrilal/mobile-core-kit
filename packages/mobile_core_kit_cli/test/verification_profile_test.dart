import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';
import 'package:test/test.dart';

void main() {
  test('registry defines every verification profile exactly once', () {
    expect(
      verificationProfiles.keys.toSet(),
      VerificationProfile.values.toSet(),
    );
    for (final profile in VerificationProfile.values) {
      expect(verificationProfiles[profile]!.profile, profile);
      expect(verificationProfiles[profile]!.steps, isNotEmpty);
    }
  });

  test('full and ci prove application and harness packages', () {
    for (final profile in [VerificationProfile.full, VerificationProfile.ci]) {
      final steps = verificationProfiles[profile]!.steps;
      expect(steps, contains(VerificationStep.cliTests));
      expect(steps, contains(VerificationStep.lintTests));
      expect(steps, contains(VerificationStep.applicationTests));
      expect(steps, contains(VerificationStep.codegen));
      expect(steps, contains(VerificationStep.lint));
    }
  });

  test('ci and full share the same repository proof sequence', () {
    expect(
      verificationProfiles[VerificationProfile.ci]!.steps,
      verificationProfiles[VerificationProfile.full]!.steps,
    );
  });

  test('runtime delegates only to the device evidence owner', () {
    expect(verificationProfiles[VerificationProfile.runtime]!.steps, [
      VerificationStep.runtimeEvidence,
    ]);
  });

  test('profile parser rejects unsupported values', () {
    expect(
      () => VerificationProfile.parse('quick'),
      throwsA(isA<FormatException>()),
    );
  });
}
