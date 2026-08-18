import 'dart:io';

import 'package:mobile_core_kit_cli/src/oracle/oracle_registry.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

class OracleWorkflow {
  const OracleWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isNotEmpty) {
      throw FormatException("Unexpected argument '${arguments.first}'.");
    }
    try {
      final registry = OracleRegistry.load(context.rootDirectory);
      var planCount = 0;
      for (final lifecycle in const ['active', 'queued']) {
        final planRoot = Directory(
          p.join(context.rootDirectory.path, 'docs', 'exec-plans', lifecycle),
        );
        if (!planRoot.existsSync()) continue;
        final files =
            planRoot
                .listSync()
                .whereType<File>()
                .where((file) => file.path.endsWith('.md'))
                .toList()
              ..sort((left, right) => left.path.compareTo(right.path));
        for (final file in files) {
          final source = file.readAsStringSync();
          if (!source.contains('**Plan version:** 2')) continue;
          final relativePath = p.relative(
            file.path,
            from: context.rootDirectory.path,
          );
          final plan = parseTaskPlan(relativePath, source);
          registry.validatePlan(plan);
          planCount++;
        }
      }
      context.output.writeln(
        'Oracle registry is valid: ${registry.definitions.length} registered, '
        '$planCount active/queued V2 plan(s) covered.',
      );
      return 0;
    } on OracleRegistryError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on TaskPlanError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on FileSystemException catch (error) {
      context.errorOutput.writeln('FAIL [oracle.io] ${error.message}');
      return 1;
    }
  }
}
