import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class TaskWorkflow {
  TaskWorkflow(this.context)
    : service = TaskService(root: context.rootDirectory);

  final WorkflowContext context;
  final TaskService service;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      context.errorOutput.writeln(
        'ERROR: Expected `task begin`, `task preflight`, or `task status`.',
      );
      return 2;
    }
    try {
      return switch (arguments.first) {
        'begin' => _begin(arguments.skip(1).toList()),
        'preflight' => _preflight(arguments.skip(1).toList()),
        'status' => _status(arguments.skip(1).toList()),
        _ => _unknown(arguments.first),
      };
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

  Future<int> _begin(List<String> arguments) async {
    final parser = ArgParser()..addOption('plan');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final plan = parsed.option('plan');
    if (plan == null || plan.isEmpty) {
      throw const FormatException('--plan is required.');
    }
    final result = await service.begin(plan);
    context.output.writeln('Task authorized: ${result.taskId}');
    context.output.writeln('Plan: ${result.planPath}');
    context.output.writeln('Base revision: ${result.baseRevision}');
    context.output.writeln('Declared risk: ${result.declaredRisk.name}');
    context.output.writeln(
      'Pre-existing paths protected: ${result.preexistingPathCount}',
    );
    return 0;
  }

  Future<int> _preflight(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('task')
      ..addOption(
        'action',
        defaultsTo: TaskAction.verify.label,
        allowed: TaskAction.values.map((action) => action.label),
      );
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final result = await service.preflight(
      taskId,
      action: TaskAction.parse(parsed.option('action')!),
    );
    context.output.writeln('Task preflight passed: ${result.taskId}');
    context.output.writeln('Action: ${result.action.label}');
    context.output.writeln(
      'Effective risk: ${result.classification.effectiveRisk.name}',
    );
    context.output.writeln('Task-owned paths: ${result.taskPaths.length}');
    for (final path in result.taskPaths) {
      context.output.writeln('- $path');
    }
    context.output.writeln(
      'Protected pre-existing paths: ${result.preexistingPaths.length}',
    );
    context.output.writeln('Task fingerprint: ${result.taskFingerprint}');
    return 0;
  }

  Future<int> _status(List<String> arguments) async {
    final parser = ArgParser()..addOption('task');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final state = service.status(taskId);
    context.output.writeln('Task: ${state.taskId}');
    context.output.writeln('Status: ${state.status}');
    context.output.writeln('Plan: ${state.planPath}');
    context.output.writeln('Base revision: ${state.baseRevision}');
    context.output.writeln('Started at: ${state.startedAt.toIso8601String()}');
    context.output.writeln('Declared risk: ${state.declaredRisk.name}');
    context.output.writeln(
      'Maximum risk: ${state.boundaries.maximumRisk.name}',
    );
    context.output.writeln(
      'Pre-existing paths protected: ${state.preexistingChanges.length}',
    );
    return 0;
  }

  int _unknown(String command) {
    context.errorOutput.writeln("ERROR: Unknown task command '$command'.");
    return 2;
  }

  void _rejectRest(List<String> rest) {
    if (rest.isNotEmpty) {
      throw FormatException("Unexpected argument '${rest.first}'.");
    }
  }
}

class RiskWorkflow {
  RiskWorkflow(this.context)
    : service = TaskService(root: context.rootDirectory);

  final WorkflowContext context;
  final TaskService service;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || arguments.first != 'classify') {
      context.errorOutput.writeln('ERROR: Expected `risk classify`.');
      return 2;
    }
    final parser = ArgParser()..addOption('plan');
    try {
      final parsed = parser.parse(arguments.skip(1).toList());
      if (parsed.rest.isNotEmpty) {
        throw FormatException("Unexpected argument '${parsed.rest.first}'.");
      }
      final result = await service.classifyCurrent(
        planPath: parsed.option('plan'),
      );
      context.output.writeln('Effective risk: ${result.effectiveRisk.name}');
      context.output.writeln('Path risk: ${result.pathRisk.name}');
      for (final reason in result.reasons) {
        context.output.writeln(
          '- [${reason.ruleId}] ${reason.path}: ${reason.description}',
        );
      }
      return 0;
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ${error.message}');
      return 2;
    } on TaskControlError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    }
  }
}
