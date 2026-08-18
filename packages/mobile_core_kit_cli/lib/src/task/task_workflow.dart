import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/process/deadline_command_runner.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/task/task_controller.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:mobile_core_kit_cli/src/task/task_workspace_manager.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_result.dart';
import 'package:mobile_core_kit_cli/src/workflows/verify_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class TaskWorkflow {
  TaskWorkflow(this.context);

  final WorkflowContext context;
  late final Directory controlRoot;
  late final TaskStateStore stateStore;
  late final TaskService service;
  late final TaskController controller;
  late final TaskWorkspaceManager workspaceManager;

  Future<void> _initialize() async {
    controlRoot = await const TaskControlRootLocator().locate(
      context.rootDirectory,
    );
    stateStore = FileTaskStateStore(controlRoot);
    service = TaskService(root: context.rootDirectory, stateStore: stateStore);
    controller = TaskController(
      service: service,
      stateStore: stateStore,
      episodeStore: FileTaskEpisodeStore(controlRoot),
    );
    workspaceManager = TaskWorkspaceManager(
      checkoutRoot: context.rootDirectory,
      controlRoot: controlRoot,
      service: service,
      stateStore: stateStore,
    );
  }

  Future<int> run(List<String> arguments) async {
    await _initialize();
    if (arguments.isEmpty) {
      context.errorOutput.writeln(
        'ERROR: Expected `task begin`, `task preflight`, `task verify`, '
        '`task repair`, `task workspace`, or `task status`.',
      );
      return 2;
    }
    try {
      return await switch (arguments.first) {
        'begin' => _begin(arguments.skip(1).toList()),
        'preflight' => _preflight(arguments.skip(1).toList()),
        'verify' => _verify(arguments.skip(1).toList()),
        'repair' => _repair(arguments.skip(1).toList()),
        'workspace' => _workspace(arguments.skip(1).toList()),
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
    context.output.writeln('Verification attempts: ${state.attemptCount}');
    context.output.writeln(
      'Repair opportunities: ${state.repairCount}/${state.boundaries.repairLimit}',
    );
    if (state.selectedLanes.isNotEmpty) {
      context.output.writeln(
        'Selected lanes: ${state.selectedLanes.join(', ')}',
      );
    }
    if (state.failure case final failure?) {
      context.output.writeln('Last failure: ${failure.boundary}');
      context.output.writeln('Category: ${failure.category.name}');
    }
    if (state.escalationReason case final reason?) {
      context.output.writeln('Escalation: $reason');
    }
    return 0;
  }

  Future<int> _verify(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('task')
      ..addOption('env', defaultsTo: 'dev');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final env = parsed.option('env')!;
    if (!const {'dev', 'staging', 'prod'}.contains(env)) {
      throw FormatException("Unknown --env '$env'.");
    }
    final result = await controller.verify(
      taskId,
      runLane: (profile, deadline) async {
        final commandRunner = DeadlineCommandRunner(
          rootDirectory: context.rootDirectory,
          deadline: deadline,
          output: context.output,
          errorOutput: context.errorOutput,
        );
        VerificationStepOutcome? failed;
        final stopwatch = Stopwatch()..start();
        final exitCode = await VerifyWorkflow(
          WorkflowContext(
            rootDirectory: context.rootDirectory,
            execute: commandRunner.run,
            output: context.output,
            errorOutput: context.errorOutput,
          ),
          observer: (outcome) {
            if (!outcome.passed) failed = outcome;
          },
        ).run(['--profile', profile.label, '--env', env]);
        stopwatch.stop();
        return TaskLaneExecution(
          exitCode: exitCode,
          duration: stopwatch.elapsed,
          timedOut: commandRunner.lastResult?.timedOut ?? false,
          diagnostic: failed == null
              ? ''
              : '${failed!.step.title} failed with exit '
                    '${failed!.exitCode}.',
          failedStep: failed?.step,
        );
      },
    );
    context.output.writeln(
      'Task verification: ${result.lifecycle.name} '
      '(profile=${result.profile.label}, attempt=${result.attempt}).',
    );
    if (result.failure case final failure?) {
      context.errorOutput.writeln(
        'FAIL [${failure.boundary}] ${failure.diagnostic}',
      );
      context.errorOutput.writeln('Remediation: ${failure.remediation}');
    }
    return result.exitCode;
  }

  Future<int> _repair(List<String> arguments) async {
    final parser = ArgParser()..addOption('task');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final result = await controller.recordRepair(taskId);
    context.output.writeln(
      'Repair recorded: ${result.candidateChanged ? 'candidate changed' : 'no candidate change'}.',
    );
    context.output.writeln(
      'Repair opportunities: ${result.repairCount}/${result.repairLimit}.',
    );
    context.output.writeln('Task lifecycle: ${result.lifecycle.name}.');
    return result.lifecycle == TaskLifecycle.escalated ||
            !result.candidateChanged
        ? 1
        : 0;
  }

  Future<int> _workspace(List<String> arguments) async {
    if (arguments.isEmpty) {
      throw const FormatException(
        'Expected workspace prepare, status, cancel, or cleanup.',
      );
    }
    final parser = ArgParser()..addOption('task');
    final parsed = parser.parse(arguments.skip(1).toList());
    _rejectRest(parsed.rest);
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final result = switch (arguments.first) {
      'prepare' => await workspaceManager.prepare(taskId),
      'status' => workspaceManager.status(taskId),
      'cancel' => workspaceManager.cancel(taskId),
      'cleanup' => await workspaceManager.cleanup(taskId),
      _ => throw FormatException(
        "Unknown workspace command '${arguments.first}'.",
      ),
    };
    context.output.writeln('Task workspace: ${result.taskId}');
    context.output.writeln('Lifecycle: ${result.workspace.lifecycle.name}');
    context.output.writeln('Path: ${result.workspace.path}');
    context.output.writeln('Branch: ${result.workspace.branch}');
    context.output.writeln('Base revision: ${result.workspace.baseRevision}');
    if (arguments.first == 'prepare') {
      context.output.writeln(
        'Continue the current agent session from the workspace path above.',
      );
    }
    if (arguments.first == 'cancel') {
      context.output.writeln('The host coding agent was not terminated.');
    }
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
