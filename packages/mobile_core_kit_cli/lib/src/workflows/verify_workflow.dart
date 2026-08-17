import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/duplication/duplication_runner.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/codegen_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/env_config_reader.dart';
import 'package:mobile_core_kit_cli/src/workflows/environment_schema_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/knowledge_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/l10n_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/lint_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

typedef RuntimeVerification = Future<int> Function(List<String> arguments);

class VerifyWorkflow {
  const VerifyWorkflow(this.context, {this.runtimeVerification});

  final WorkflowContext context;
  final RuntimeVerification? runtimeVerification;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addOption(
        'profile',
        allowed: VerificationProfile.values.map((profile) => profile.label),
      )
      ..addOption('env', abbr: 'e', defaultsTo: 'dev')
      ..addMultiOption('test-path')
      ..addOption('device')
      ..addOption('artifacts-dir')
      ..addMultiOption('target')
      ..addFlag('no-example-env-fallback', negatable: false)
      ..addOption('google-services-json')
      ..addFlag('apply-fixes', defaultsTo: false)
      ..addFlag('check-codegen', defaultsTo: false)
      ..addFlag('skip-duplication', defaultsTo: false)
      ..addFlag('skip-format', defaultsTo: false)
      ..addFlag('skip-tests', defaultsTo: false);

    final args = parser.parse(argv);
    if (args.rest.isNotEmpty) {
      throw FormatException("Unexpected argument '${args.rest.first}'.");
    }

    final env = args.option('env')!;
    if (!supportedEnvs.contains(env)) {
      throw FormatException(
        "Unknown --env '$env'. Expected one of: ${supportedEnvs.join(', ')}",
      );
    }

    final explicitProfile = args.option('profile') != null;
    final profile = VerificationProfile.parse(
      args.option('profile') ?? VerificationProfile.full.label,
    );
    _validateOptions(args, profile, explicitProfile: explicitProfile);

    if (profile == VerificationProfile.runtime) {
      return _runRuntime(args, env);
    }

    if (!explicitProfile && args.flag('apply-fixes')) {
      final fixExit = await _applyCompatibilityFixes(
        skipFormat: args.flag('skip-format'),
      );
      if (fixExit != 0) return fixExit;
    }

    final definition = verificationProfiles[profile]!;
    final steps = List<VerificationStep>.from(definition.steps);
    if (!explicitProfile) {
      _applyCompatibilityOverrides(steps, args);
    }
    if (profile == VerificationProfile.fast && args.flag('check-codegen')) {
      steps.insert(
        steps.indexOf(VerificationStep.buildConfig),
        VerificationStep.codegen,
      );
    }

    context.output.writeln(
      'Verification profile: ${profile.label} '
      '${explicitProfile ? '(explicit)' : '(compatibility default)'}.',
    );
    for (final step in steps) {
      final exitCode = await _runStep(
        step,
        env: env,
        testPaths: args.multiOption('test-path'),
      );
      if (exitCode != 0) {
        context.errorOutput.writeln(
          'FAIL [${step.id}] ${step.title} (exit=$exitCode).',
        );
        context.errorOutput.writeln('Remediation: ${step.remediation}');
        return exitCode;
      }
    }

    context.output.writeln('\nOK [verify.${profile.label}]');
    return 0;
  }

  void _validateOptions(
    ArgResults args,
    VerificationProfile profile, {
    required bool explicitProfile,
  }) {
    final compatibilityOverrides = <String>[
      if (args.flag('apply-fixes')) '--apply-fixes',
      if (args.flag('skip-duplication')) '--skip-duplication',
      if (args.flag('skip-format')) '--skip-format',
      if (args.flag('skip-tests')) '--skip-tests',
    ];
    if (explicitProfile && compatibilityOverrides.isNotEmpty) {
      throw FormatException(
        'Explicit verification profiles cannot be weakened or mutate files. '
        'Remove: ${compatibilityOverrides.join(', ')}.',
      );
    }

    final testPaths = args.multiOption('test-path');
    if (testPaths.isNotEmpty && profile != VerificationProfile.fast) {
      throw const FormatException(
        '--test-path is supported only by the fast profile.',
      );
    }

    final hasRuntimeOptions =
        args.option('device') != null ||
        args.option('artifacts-dir') != null ||
        args.multiOption('target').isNotEmpty ||
        args.flag('no-example-env-fallback') ||
        args.option('google-services-json') != null;
    if (hasRuntimeOptions && profile != VerificationProfile.runtime) {
      throw const FormatException(
        'Device and artifact options require `--profile runtime`.',
      );
    }
  }

  void _applyCompatibilityOverrides(
    List<VerificationStep> steps,
    ArgResults args,
  ) {
    final skipped = <VerificationStep>{
      if (args.flag('skip-duplication')) VerificationStep.duplicationCore,
      if (args.flag('skip-duplication'))
        VerificationStep.duplicationSmallHelpers,
      if (args.flag('skip-format')) VerificationStep.format,
      if (args.flag('skip-tests')) VerificationStep.cliTests,
      if (args.flag('skip-tests')) VerificationStep.lintTests,
      if (args.flag('skip-tests')) VerificationStep.applicationTests,
    };
    if (skipped.isEmpty) return;

    steps.removeWhere(skipped.contains);
    context.output.writeln(
      'WARN [verify.compatibility-override] Legacy skip flags weakened the '
      'default full profile. Use an explicit profile for evidence claims.',
    );
  }

  Future<int> _applyCompatibilityFixes({required bool skipFormat}) async {
    var exitCode = await context.step(
      'Dart fix (apply: directives_ordering)',
      const ['dart', 'fix', '--apply', '--code', 'directives_ordering'],
    );
    if (exitCode != 0) return exitCode;
    if (!skipFormat) {
      exitCode = await context.step('Dart format (apply)', const [
        'dart',
        'format',
        '.',
      ]);
    }
    return exitCode;
  }

  Future<int> _runStep(
    VerificationStep step, {
    required String env,
    required List<String> testPaths,
  }) async {
    context.output.writeln('\n==> [${step.id}] ${step.title}');
    return switch (step) {
      VerificationStep.dependencies => context.execute(const [
        'flutter',
        'pub',
        'get',
      ]),
      VerificationStep.environment => EnvironmentSchemaWorkflow(
        context,
      ).run(['--all', if (env == 'prod') '--strict']),
      VerificationStep.codegen => CodegenWorkflow(context).run(const []),
      VerificationStep.buildConfig => BuildConfigWorkflow(
        context,
      ).run(['--env', env]),
      VerificationStep.localizationGeneration => context.execute(const [
        'flutter',
        'gen-l10n',
      ]),
      VerificationStep.localizationValidation => L10nWorkflow(
        context,
      ).run(const []),
      VerificationStep.knowledge => KnowledgeWorkflow(context).run(const []),
      VerificationStep.format => context.execute(const [
        'dart',
        'format',
        '--output',
        'none',
        '--set-exit-if-changed',
        '.',
      ]),
      VerificationStep.lint => LintWorkflow(context).run(const []),
      VerificationStep.cliTests => context.execute(const [
        'dart',
        'test',
        'packages/mobile_core_kit_cli/test',
      ]),
      VerificationStep.lintTests => context.execute(const [
        'dart',
        'test',
        'packages/mobile_core_kit_lints/test',
      ]),
      VerificationStep.focusedApplicationTests => _runFocusedTests(testPaths),
      VerificationStep.duplicationCore => _runDuplication(
        DuplicationProfile.core,
      ),
      VerificationStep.duplicationSmallHelpers => _runDuplication(
        DuplicationProfile.smallHelpers,
      ),
      VerificationStep.applicationTests => context.execute(const [
        'flutter',
        'test',
      ]),
      VerificationStep.runtimeEvidence => throw StateError(
        'Runtime evidence must be dispatched before repository steps.',
      ),
    };
  }

  Future<int> _runFocusedTests(List<String> testPaths) {
    if (testPaths.isEmpty) {
      context.output.writeln(
        'SKIP [verify.tests.focused] No --test-path values were supplied.',
      );
      return Future.value(0);
    }
    return context.execute(['flutter', 'test', ...testPaths]);
  }

  Future<int> _runDuplication(DuplicationProfile profile) {
    return DuplicationRunner(
      rootDirectory: context.rootDirectory,
      execute: context.execute,
      output: context.output,
      errorOutput: context.errorOutput,
    ).run(profile);
  }

  Future<int> _runRuntime(ArgResults args, String env) async {
    final runner = runtimeVerification;
    if (runner == null) {
      context.errorOutput.writeln(
        'FAIL [verify.runtime] Runtime evidence adapter is unavailable.',
      );
      return 1;
    }

    final device = args.option('device');
    if (device == null || device.isEmpty) {
      throw const FormatException('--device is required for runtime profile.');
    }
    final runtimeArguments = <String>[
      '--device',
      device,
      '--flavor',
      env,
      for (final target in args.multiOption('target')) ...['--target', target],
      if (args.option('artifacts-dir') case final directory?) ...[
        '--artifacts-dir',
        directory,
      ],
      if (args.flag('no-example-env-fallback')) '--no-example-env-fallback',
      if (args.option('google-services-json') case final path?) ...[
        '--google-services-json',
        path,
      ],
    ];
    context.output.writeln(
      'Verification profile: runtime (explicit).\n'
      '\n==> [verify.runtime] Collect device runtime evidence',
    );
    final exitCode = await runner(runtimeArguments);
    if (exitCode != 0) {
      final step = VerificationStep.runtimeEvidence;
      context.errorOutput.writeln(
        'FAIL [${step.id}] ${step.title} (exit=$exitCode).',
      );
      context.errorOutput.writeln('Remediation: ${step.remediation}');
      return exitCode;
    }
    context.output.writeln('\nOK [verify.runtime]');
    return 0;
  }
}
