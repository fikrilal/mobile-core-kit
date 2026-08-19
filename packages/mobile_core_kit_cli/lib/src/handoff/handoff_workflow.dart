import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/handoff/handoff_service.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class HandoffWorkflow {
  const HandoffWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      context.errorOutput.writeln('ERROR: Expected a handoff operation.');
      return 2;
    }
    try {
      final controlRoot = await const TaskControlRootLocator().locate(
        context.rootDirectory,
      );
      final service = HandoffService(
        root: context.rootDirectory,
        controlRoot: controlRoot,
      );
      return switch (arguments.first) {
        'dry-run' => _dryRun(service, arguments.skip(1).toList()),
        'commit' => _commit(service, arguments.skip(1).toList()),
        'push' => _push(service, arguments.skip(1).toList()),
        'draft-pr' => _draftPr(service, arguments.skip(1).toList()),
        _ => throw FormatException(
          "Unknown handoff operation '${arguments.first}'.",
        ),
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

  Future<int> _dryRun(HandoffService service, List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('task')
      ..addOption('action', allowed: const ['commit', 'push', 'draft-pr']);
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final taskId = _required(parsed, 'task');
    final action = TaskAction.parse(_required(parsed, 'action'));
    final result = await service.dryRun(taskId, action);
    context.output.writeln('Handoff ready: ${result.action.label}');
    context.output.writeln('Task: ${result.taskId}');
    context.output.writeln('Branch: ${result.branch}');
    context.output.writeln('Remote: ${result.remote}');
    context.output.writeln('Paths: ${result.changedPaths.length}');
    context.output.writeln('Expires: ${result.expiresAt.toIso8601String()}');
    context.output.writeln('Approval: ${result.challenge}');
    context.output.writeln(
      'No Git or GitHub mutation was made. The current agent may use this '
      'one-time approval only after explicit user authorization.',
    );
    return 0;
  }

  Future<int> _commit(HandoffService service, List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('task')
      ..addOption('message');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final result = await service.commit(
      _required(parsed, 'task'),
      _approval(),
      _required(parsed, 'message'),
    );
    _writeMutation(result);
    return 0;
  }

  Future<int> _push(HandoffService service, List<String> arguments) async {
    final parser = ArgParser()..addOption('task');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final result = await service.push(_required(parsed, 'task'), _approval());
    _writeMutation(result);
    return 0;
  }

  Future<int> _draftPr(HandoffService service, List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('task')
      ..addOption('base')
      ..addOption('title');
    final parsed = parser.parse(arguments);
    _rejectRest(parsed.rest);
    final result = await service.draftPr(
      _required(parsed, 'task'),
      _approval(),
      base: _required(parsed, 'base'),
      title: _required(parsed, 'title'),
    );
    _writeMutation(result);
    return 0;
  }

  String _required(ArgResults parsed, String name) {
    final value = parsed.option(name);
    if (value == null || value.isEmpty) {
      throw FormatException('--$name is required.');
    }
    return value;
  }

  String _approval() {
    final value = Platform.environment['MOBILEKIT_HANDOFF_APPROVAL'];
    if (value == null || value.isEmpty) {
      throw const FormatException(
        'MOBILEKIT_HANDOFF_APPROVAL is required for a mutating handoff.',
      );
    }
    return value;
  }

  void _writeMutation(HandoffMutationResult result) {
    context.output.writeln('Handoff completed: ${result.action.label}');
    context.output.writeln('Task: ${result.taskId}');
    context.output.writeln('Outcome: ${result.outcome}');
  }

  void _rejectRest(List<String> rest) {
    if (rest.isNotEmpty) {
      throw FormatException("Unexpected argument '${rest.first}'.");
    }
  }
}
