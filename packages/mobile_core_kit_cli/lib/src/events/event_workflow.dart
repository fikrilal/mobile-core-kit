import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/events/event_intake.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class EventWorkflow {
  const EventWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || arguments.first != 'intake') {
      context.errorOutput.writeln('ERROR: Expected `event intake --once`.');
      return 2;
    }
    final parser = ArgParser()..addFlag('once', negatable: false);
    try {
      final parsed = parser.parse(arguments.skip(1).toList());
      if (!parsed.flag('once') || parsed.rest.isNotEmpty) {
        throw const FormatException('Event intake requires only --once.');
      }
      final controlRoot = await const TaskControlRootLocator().locate(
        context.rootDirectory,
      );
      final result = await EventIntakeService(
        root: context.rootDirectory,
        controlRoot: controlRoot,
      ).runOnce();
      if (!result.accepted) {
        context.output.writeln('Event intake idle: ${result.idleReason}.');
        return 0;
      }
      context.output.writeln('Event accepted: ${result.eventId}');
      context.output.writeln('Task: ${result.taskId}');
      context.output.writeln('Plan: ${result.activePlanPath}');
      context.output.writeln('Recovered: ${result.recovered}');
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
    } on FileSystemException catch (error) {
      context.errorOutput.writeln('FAIL [event.io-failed] ${error.message}');
      return 1;
    }
  }
}
