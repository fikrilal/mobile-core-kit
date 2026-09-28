import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/ci/ci_classification.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class CiWorkflow {
  const CiWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || arguments.first != 'classify') {
      context.errorOutput.writeln(
        'ERROR: Expected `ci classify --base <revision> --head <revision>`.',
      );
      return 2;
    }
    final parser = ArgParser()
      ..addOption('base')
      ..addOption('head');
    try {
      final parsed = parser.parse(arguments.skip(1).toList());
      if (parsed.rest.isNotEmpty) {
        throw FormatException("Unexpected argument '${parsed.rest.first}'.");
      }
      final base = parsed.option('base');
      final head = parsed.option('head');
      if (base == null || base.isEmpty || head == null || head.isEmpty) {
        throw const FormatException('--base and --head are required.');
      }
      final result = await CiClassificationService(
        root: context.rootDirectory,
      ).classify(base, head);
      context.output.write(renderCiOutputs(result));
      return 0;
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ${error.message}');
      return 2;
    } on TaskControlError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on TaskPlanError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    }
  }
}
