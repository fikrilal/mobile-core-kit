import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/workflows/scaffold_data_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/scaffold_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

/// End-to-end scaffolding workflow that creates a feature skeleton (if not
/// present) and scaffolds OpenAPI-driven data layer (DTOs, endpoints, datasource).
class ScaffoldAllWorkflow {
  const ScaffoldAllWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Preview all operations without writing files to disk.',
      )
      ..addFlag(
        'force',
        negatable: false,
        help: 'Overwrite existing model/DTO files.',
      )
      ..addFlag(
        'no-codegen',
        negatable: false,
        help: 'Skip running build_runner codegen.',
      )
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature name in snake_case (e.g. "order_tracking").',
      )
      ..addOption(
        'operation',
        abbr: 'o',
        help: 'OpenAPI operationId (e.g. "orders.create").',
      )
      ..addOption(
        'slice',
        abbr: 's',
        help: 'Optional slice name (defaults to feature name).',
      )
      ..addOption(
        'openapi-spec',
        abbr: 'c',
        help: 'Path to OpenAPI specification file (relative to root).',
        defaultsTo: 'docs/contracts/openapi/backend.openapi.yaml',
      );

    final args = parser.parse(argv);
    if (args.flag('help')) {
      context.output.writeln(
        [
          'scaffold all',
          '',
          'End-to-end scaffolding: creates the feature architecture skeleton (if not',
          'already existing) and scaffolds the OpenAPI-driven data layer (Freezed DTOs,',
          'endpoint constants, and remote datasource methods).',
          '',
          'Usage:',
          '  mobilekit scaffold all --feature <name> --operation <id> [options]',
          '',
          'Examples:',
          '  mobilekit scaffold all --feature order_tracking --operation orders.get',
          '  mobilekit scaffold all -f order_tracking -o orders.get --dry-run',
          '',
          'Options:',
          parser.usage,
        ].join('\n'),
      );
      return 0;
    }

    final feature = (args.option('feature') ?? '').trim();
    final operation = (args.option('operation') ?? '').trim();
    final slice = (args.option('slice') ?? '').trim();
    final openApiSpec = (args.option('openapi-spec') ?? '').trim();
    final dryRun = args.flag('dry-run');
    final force = args.flag('force');
    final noCodegen = args.flag('no-codegen');

    if (feature.isEmpty) {
      context.errorOutput.writeln('ERROR: Missing required option: --feature');
      context.errorOutput.writeln(
        'Usage: mobilekit scaffold all --feature <name> --operation <id>',
      );
      return 2;
    }

    if (operation.isEmpty) {
      context.errorOutput.writeln(
        'ERROR: Missing required option: --operation',
      );
      context.errorOutput.writeln(
        'Usage: mobilekit scaffold all --feature <name> --operation <id>',
      );
      return 2;
    }

    context.output.writeln(
      '=== [1/2] Checking Feature Architecture Skeleton ===',
    );
    final featureDir = context.directory('lib/features/$feature');

    if (featureDir.existsSync()) {
      context.output.writeln(
        'Feature "lib/features/$feature" already exists; skipping skeleton creation.',
      );
    } else {
      context.output.writeln('Scaffolding feature skeleton for "$feature"...');
      final featureArgs = [
        '--feature',
        feature,
        if (slice.isNotEmpty) ...['--slice', slice],
        if (dryRun) '--dry-run',
      ];
      final featureWorkflow = ScaffoldWorkflow(context);
      final featureExit = await featureWorkflow.run(featureArgs);
      if (featureExit != 0) {
        context.errorOutput.writeln(
          'ERROR: Feature scaffolding failed with code $featureExit.',
        );
        return featureExit;
      }
    }

    context.output.writeln('\n=== [2/2] Scaffolding OpenAPI Data Layer ===');
    final dataArgs = [
      if (openApiSpec.isNotEmpty) ...['--openapi-spec', openApiSpec],
      '--feature',
      feature,
      '--operation',
      operation,
      if (dryRun) '--dry-run',
      if (force) '--force',
      if (noCodegen) '--no-codegen',
    ];

    final dataWorkflow = ScaffoldDataWorkflow(context);
    final dataExit = await dataWorkflow.run(dataArgs);
    if (dataExit != 0) {
      context.errorOutput.writeln(
        'ERROR: OpenAPI data scaffolding failed with code $dataExit.',
      );
      return dataExit;
    }

    context.output.writeln(
      '\nAll scaffolding completed successfully for "$feature" ($operation).',
    );
    return 0;
  }
}
