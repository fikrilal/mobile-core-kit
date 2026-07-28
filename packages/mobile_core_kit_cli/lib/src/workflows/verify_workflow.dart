import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/duplication/duplication_runner.dart';
import 'package:mobile_core_kit_cli/src/guardrails/hardcoded_ui_colors_check.dart';
import 'package:mobile_core_kit_cli/src/guardrails/modal_entrypoints_check.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/codegen_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/environment_schema_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/l10n_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/project_map_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class VerifyWorkflow {
  const VerifyWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addOption('env', abbr: 'e', defaultsTo: 'dev')
      ..addFlag('apply-fixes', defaultsTo: false)
      ..addFlag('check-codegen', defaultsTo: false)
      ..addFlag('skip-duplication', defaultsTo: false)
      ..addFlag('skip-format', defaultsTo: false)
      ..addFlag('skip-tests', defaultsTo: false);

    final args = parser.parse(argv);
    final env = args.option('env')!;
    final applyFixes = args.flag('apply-fixes');
    final checkCodegen = args.flag('check-codegen');
    final skipDuplication = args.flag('skip-duplication');
    final skipFormat = args.flag('skip-format');
    final skipTests = args.flag('skip-tests');

    final envs = {'dev', 'staging', 'prod'};
    if (!envs.contains(env)) {
      context.errorOutput.writeln(
        "Unknown --env '$env'. Expected one of: ${envs.join(', ')}",
      );
      return 2;
    }

    var exitCode = await context.step('Flutter pub get', [
      'flutter',
      'pub',
      'get',
    ]);
    if (exitCode != 0) return exitCode;

    exitCode = await context.workflowStep(
      'Verify env schema',
      () => EnvironmentSchemaWorkflow(
        context,
      ).run(['--all', if (env == 'prod') '--strict']),
    );
    if (exitCode != 0) return exitCode;

    if (checkCodegen) {
      exitCode = await context.workflowStep(
        'Verify codegen outputs',
        () => CodegenWorkflow(context).run(const []),
      );
      if (exitCode != 0) return exitCode;
    }

    if (applyFixes) {
      exitCode = await context.step('Dart fix (apply: directives_ordering)', [
        'dart',
        'fix',
        '--apply',
        '--code',
        'directives_ordering',
      ]);
      if (exitCode != 0) return exitCode;

      if (!skipFormat) {
        exitCode = await context.step('Dart format (apply)', [
          'dart',
          'format',
          '.',
        ]);
        if (exitCode != 0) return exitCode;
      }
    }

    exitCode = await context.workflowStep(
      'Generate build config (.env/$env.yaml)',
      () => BuildConfigWorkflow(context).run(['--env', env]),
    );
    if (exitCode != 0) return exitCode;

    exitCode = await context.step('Flutter gen-l10n', ['flutter', 'gen-l10n']);
    if (exitCode != 0) return exitCode;

    exitCode = await context.workflowStep(
      'Verify untranslated messages',
      () => L10nWorkflow(context).run(const []),
    );
    if (exitCode != 0) return exitCode;

    exitCode = await context.workflowStep(
      'Verify AGENTS project map drift',
      () => ProjectMapWorkflow(context).run(const []),
    );
    if (exitCode != 0) return exitCode;

    exitCode = await context.step('Flutter analyze', ['flutter', 'analyze']);
    if (exitCode != 0) return exitCode;

    exitCode = await context.step('Custom lint', [
      'dart',
      'run',
      'custom_lint',
    ]);
    if (exitCode != 0) return exitCode;

    if (!skipDuplication) {
      final duplication = DuplicationRunner(
        rootDirectory: context.rootDirectory,
        execute: context.execute,
        output: context.output,
        errorOutput: context.errorOutput,
      );

      exitCode = await context.workflowStep(
        'Verify duplication (core)',
        () => duplication.run(DuplicationProfile.core),
      );
      if (exitCode != 0) return exitCode;

      exitCode = await context.workflowStep(
        'Verify duplication (small helpers)',
        () => duplication.run(DuplicationProfile.smallHelpers),
      );
      if (exitCode != 0) return exitCode;
    }

    exitCode = await context.workflowStep(
      'Verify modal entrypoints',
      () async => ModalEntrypointsCheck(
        rootDirectory: context.rootDirectory,
        output: context.output,
        errorOutput: context.errorOutput,
      ).run(),
    );
    if (exitCode != 0) return exitCode;

    exitCode = await context.workflowStep(
      'Verify hardcoded UI colors',
      () async => HardcodedUiColorsCheck(
        rootDirectory: context.rootDirectory,
        output: context.output,
        errorOutput: context.errorOutput,
      ).run(),
    );
    if (exitCode != 0) return exitCode;

    if (!skipTests) {
      exitCode = await context.step('Flutter test', ['flutter', 'test']);
      if (exitCode != 0) return exitCode;
    }

    if (!skipFormat) {
      exitCode = await context.step('Dart format (check)', [
        'dart',
        'format',
        '--output',
        'none',
        '--set-exit-if-changed',
        '.',
      ]);
      if (exitCode != 0) return exitCode;
    }

    context.output.writeln('\nOK');
    return 0;
  }
}
