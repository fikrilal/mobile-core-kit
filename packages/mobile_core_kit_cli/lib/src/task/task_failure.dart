import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';

enum TaskFailureCategory {
  policy,
  infrastructure,
  configuration,
  generation,
  knowledge,
  formatting,
  analysis,
  test,
  duplication,
  runtime,
  timeout,
  unknown,
}

class TaskFailureDefinition {
  const TaskFailureDefinition({required this.boundary, required this.category});

  final String boundary;
  final TaskFailureCategory category;
}

const verificationFailureTaxonomy = <VerificationStep, TaskFailureDefinition>{
  VerificationStep.dependencies: TaskFailureDefinition(
    boundary: 'infrastructure.dependencies',
    category: TaskFailureCategory.infrastructure,
  ),
  VerificationStep.environment: TaskFailureDefinition(
    boundary: 'configuration.environment',
    category: TaskFailureCategory.configuration,
  ),
  VerificationStep.codegen: TaskFailureDefinition(
    boundary: 'codegen.drift',
    category: TaskFailureCategory.generation,
  ),
  VerificationStep.buildConfig: TaskFailureDefinition(
    boundary: 'configuration.build',
    category: TaskFailureCategory.configuration,
  ),
  VerificationStep.localizationGeneration: TaskFailureDefinition(
    boundary: 'generation.localization',
    category: TaskFailureCategory.generation,
  ),
  VerificationStep.localizationValidation: TaskFailureDefinition(
    boundary: 'localization.missing',
    category: TaskFailureCategory.generation,
  ),
  VerificationStep.knowledge: TaskFailureDefinition(
    boundary: 'knowledge.repository',
    category: TaskFailureCategory.knowledge,
  ),
  VerificationStep.format: TaskFailureDefinition(
    boundary: 'format.dart',
    category: TaskFailureCategory.formatting,
  ),
  VerificationStep.lint: TaskFailureDefinition(
    boundary: 'analysis.repository',
    category: TaskFailureCategory.analysis,
  ),
  VerificationStep.cliTests: TaskFailureDefinition(
    boundary: 'test.mobilekit_cli',
    category: TaskFailureCategory.test,
  ),
  VerificationStep.lintTests: TaskFailureDefinition(
    boundary: 'test.custom_lints',
    category: TaskFailureCategory.test,
  ),
  VerificationStep.focusedApplicationTests: TaskFailureDefinition(
    boundary: 'test.application.focused',
    category: TaskFailureCategory.test,
  ),
  VerificationStep.duplicationCore: TaskFailureDefinition(
    boundary: 'duplication.core',
    category: TaskFailureCategory.duplication,
  ),
  VerificationStep.duplicationSmallHelpers: TaskFailureDefinition(
    boundary: 'duplication.small_helpers',
    category: TaskFailureCategory.duplication,
  ),
  VerificationStep.applicationTests: TaskFailureDefinition(
    boundary: 'test.application',
    category: TaskFailureCategory.test,
  ),
  VerificationStep.runtimeEvidence: TaskFailureDefinition(
    boundary: 'runtime.device',
    category: TaskFailureCategory.runtime,
  ),
};

String sanitizeTaskDiagnostic(String value, {int maximumLength = 4096}) {
  var sanitized = value
      .replaceAll(
        RegExp(r'bearer\s+[a-z0-9._~+/=-]+', caseSensitive: false),
        'Bearer [REDACTED]',
      )
      .replaceAll(
        RegExp(
          r'(token|secret|password|api[_-]?key)\s*[:=]\s*[^\s,;]+',
          caseSensitive: false,
        ),
        r'$1=[REDACTED]',
      )
      .replaceAll(
        RegExp(
          r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
          caseSensitive: false,
        ),
        '[REDACTED_EMAIL]',
      );
  final lines = sanitized.split('\n').take(40).toList();
  sanitized = lines.join('\n').trim();
  if (sanitized.length > maximumLength) {
    sanitized = '${sanitized.substring(0, maximumLength)}…';
  }
  return sanitized;
}
