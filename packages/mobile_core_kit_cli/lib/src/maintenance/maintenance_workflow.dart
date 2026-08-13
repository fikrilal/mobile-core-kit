import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/maintenance/maintenance_service.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class MaintenanceWorkflow {
  const MaintenanceWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || arguments.first != 'run') {
      context.errorOutput.writeln('ERROR: Expected `maintenance run --once`.');
      return 2;
    }
    final parser = ArgParser()..addFlag('once', negatable: false);
    try {
      final parsed = parser.parse(arguments.skip(1).toList());
      if (!parsed.flag('once') || parsed.rest.isNotEmpty) {
        throw const FormatException('Maintenance requires only --once.');
      }
      final controlRoot = await const TaskControlRootLocator().locate(
        context.rootDirectory,
      );
      final result = await MaintenanceService(
        root: context.rootDirectory,
        controlRoot: controlRoot,
        runCommand: maintenanceCommandRunner(
          output: context.output,
          errorOutput: context.errorOutput,
        ),
      ).runOnce();
      context.output.writeln(
        'Maintenance ${result.passed ? 'passed' : 'failed'}: ${result.reportPath}',
      );
      return result.passed ? 0 : 1;
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ${error.message}');
      return 2;
    } on TaskControlError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    }
  }
}
