enum VerificationProfile {
  fast('fast'),
  full('full'),
  runtime('runtime'),
  ci('ci');

  const VerificationProfile(this.label);

  final String label;

  static VerificationProfile parse(String value) {
    return values.firstWhere(
      (profile) => profile.label == value,
      orElse: () => throw FormatException(
        "Unknown verification profile '$value'. Expected one of: "
        '${values.map((profile) => profile.label).join(', ')}',
      ),
    );
  }
}

enum VerificationStep {
  dependencies(
    id: 'verify.dependencies',
    title: 'Resolve Flutter dependencies',
    remediation: 'Run `fvm flutter pub get` and resolve dependency errors.',
  ),
  environment(
    id: 'verify.environment',
    title: 'Verify environment schemas',
    remediation: 'Fix the reported `.env/*.yaml` schema violation.',
  ),
  codegen(
    id: 'verify.codegen',
    title: 'Verify generated outputs',
    remediation: 'Run `dart run build_runner build` and review the diff.',
  ),
  buildConfig(
    id: 'verify.build-config',
    title: 'Generate build configuration',
    remediation: 'Fix the selected environment file or config generator.',
  ),
  localizationGeneration(
    id: 'verify.l10n-generate',
    title: 'Generate localizations',
    remediation: 'Fix ARB or `l10n.yaml` errors and rerun generation.',
  ),
  localizationValidation(
    id: 'verify.l10n-validate',
    title: 'Verify untranslated messages',
    remediation: 'Add every missing key to all supported locale files.',
  ),
  knowledge(
    id: 'verify.knowledge',
    title: 'Verify repository knowledge',
    remediation: 'Repair the reported project-map, link, or plan metadata.',
  ),
  oracles(
    id: 'verify.oracles',
    title: 'Verify behavioral oracle registry',
    remediation: 'Repair missing oracle targets or task impact coverage.',
  ),
  contracts(
    id: 'verify.contracts',
    title: 'Verify pinned API contracts',
    remediation: 'Review and explicitly sync the accepted OpenAPI snapshot.',
  ),
  format(
    id: 'verify.format',
    title: 'Verify Dart formatting',
    remediation: 'Run `dart run mobile_core_kit_cli:mobilekit fix --apply`.',
  ),
  lint(
    id: 'verify.lint',
    title: 'Run analyzer and architecture guardrails',
    remediation: 'Fix analyzer/custom-lint findings without weakening policy.',
  ),
  cliTests(
    id: 'verify.tests.cli',
    title: 'Run mobilekit CLI tests',
    remediation: 'Fix the failing repository-harness test.',
  ),
  lintTests(
    id: 'verify.tests.lints',
    title: 'Run custom-lint package tests',
    remediation: 'Fix the failing lint rule or its fixture.',
  ),
  focusedApplicationTests(
    id: 'verify.tests.focused',
    title: 'Run focused application tests',
    remediation: 'Fix the selected test or the behavior it protects.',
  ),
  duplicationCore(
    id: 'verify.duplication.core',
    title: 'Review core duplication',
    remediation: 'Refactor or record a reviewed allowlist decision.',
  ),
  duplicationSmallHelpers(
    id: 'verify.duplication.small-helpers',
    title: 'Review small-helper duplication',
    remediation: 'Refactor or record a reviewed allowlist decision.',
  ),
  applicationTests(
    id: 'verify.tests.application',
    title: 'Run all application tests',
    remediation: 'Fix the failing application test or protected behavior.',
  ),
  runtimeEvidence(
    id: 'verify.runtime',
    title: 'Collect device runtime evidence',
    remediation: 'Inspect the evidence summary and repair the failing target.',
  );

  const VerificationStep({
    required this.id,
    required this.title,
    required this.remediation,
  });

  final String id;
  final String title;
  final String remediation;
}

class VerificationProfileDefinition {
  const VerificationProfileDefinition({
    required this.profile,
    required this.steps,
  });

  final VerificationProfile profile;
  final List<VerificationStep> steps;
}

const verificationProfiles =
    <VerificationProfile, VerificationProfileDefinition>{
      VerificationProfile.fast: VerificationProfileDefinition(
        profile: VerificationProfile.fast,
        steps: [
          VerificationStep.dependencies,
          VerificationStep.environment,
          VerificationStep.buildConfig,
          VerificationStep.localizationGeneration,
          VerificationStep.localizationValidation,
          VerificationStep.knowledge,
          VerificationStep.format,
          VerificationStep.lint,
          VerificationStep.cliTests,
          VerificationStep.lintTests,
          VerificationStep.focusedApplicationTests,
        ],
      ),
      VerificationProfile.full: VerificationProfileDefinition(
        profile: VerificationProfile.full,
        steps: [
          VerificationStep.dependencies,
          VerificationStep.environment,
          VerificationStep.codegen,
          VerificationStep.buildConfig,
          VerificationStep.localizationGeneration,
          VerificationStep.localizationValidation,
          VerificationStep.knowledge,
          VerificationStep.oracles,
          VerificationStep.contracts,
          VerificationStep.format,
          VerificationStep.lint,
          VerificationStep.cliTests,
          VerificationStep.lintTests,
          VerificationStep.duplicationCore,
          VerificationStep.duplicationSmallHelpers,
          VerificationStep.applicationTests,
        ],
      ),
      VerificationProfile.runtime: VerificationProfileDefinition(
        profile: VerificationProfile.runtime,
        steps: [VerificationStep.runtimeEvidence],
      ),
      VerificationProfile.ci: VerificationProfileDefinition(
        profile: VerificationProfile.ci,
        steps: [
          VerificationStep.dependencies,
          VerificationStep.environment,
          VerificationStep.codegen,
          VerificationStep.buildConfig,
          VerificationStep.localizationGeneration,
          VerificationStep.localizationValidation,
          VerificationStep.knowledge,
          VerificationStep.oracles,
          VerificationStep.contracts,
          VerificationStep.format,
          VerificationStep.lint,
          VerificationStep.cliTests,
          VerificationStep.lintTests,
          VerificationStep.duplicationCore,
          VerificationStep.duplicationSmallHelpers,
          VerificationStep.applicationTests,
        ],
      ),
    };
