import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_log_session.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_log_workflow.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('captures and stops a detached process on POSIX', () async {
    if (Platform.isWindows) return;

    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_process_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final logFile = File(p.join(root.path, 'stream.log'));
    final controller = DartRuntimeLogProcessController(
      platform: CommandPlatform.posix,
    );

    final pid = await controller.start(
      command: ['sh', '-c', 'printf "captured line\\n"; exec sleep 30'],
      workingDirectory: root,
      logFile: logFile,
    );
    addTearDown(() => controller.stop(pid));

    expect(await controller.isRunning(pid), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(logFile.readAsStringSync(), contains('captured line'));

    await controller.stop(pid);
    expect(await controller.isRunning(pid), isFalse);
  });

  test('starts a logs session with the pinned Flutter executable', () async {
    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_logs_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final pinnedFlutter = File(
      p.join(root.path, '.fvm', 'flutter_sdk', 'bin', 'flutter'),
    )..createSync(recursive: true);
    final controller = FakeRuntimeLogProcessController();
    final output = StringBuffer();
    final errors = StringBuffer();
    final workflow = _workflow(
      root,
      controller,
      output: output,
      errors: errors,
    );

    final result = await workflow.run([
      'start',
      '--session',
      'emulator',
      '--mode',
      'logs',
      '--device',
      'emulator-5554',
      '--',
      '--verbose',
    ]);

    expect(result, 0);
    expect(errors, isEmpty);
    expect(controller.commands, [
      [pinnedFlutter.path, 'logs', '-d', 'emulator-5554', '--verbose'],
    ]);
    expect(output.toString(), contains("Started session 'emulator'"));

    final sessionDirectory = Directory(
      p.join(root.path, '_artifacts', 'runtime_logs', 'emulator'),
    );
    expect(
      File(p.join(sessionDirectory.path, 'stream.pid')).readAsStringSync(),
      '4101\n',
    );
    expect(
      File(p.join(sessionDirectory.path, 'metadata.env')).readAsStringSync(),
      allOf(contains('mode=logs'), contains('device=emulator-5554')),
    );
    expect(
      File(p.join(sessionDirectory.path, 'command.txt')).readAsStringSync(),
      contains('${pinnedFlutter.path} logs -d emulator-5554 --verbose'),
    );
  });

  test('builds the run command and forwards extra Flutter arguments', () async {
    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_run_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final controller = FakeRuntimeLogProcessController();
    final workflow = _workflow(root, controller);

    final result = await workflow.run([
      'start',
      '--session',
      'dev-run',
      '--mode',
      'run',
      '--device',
      'emulator-5554',
      '--flavor',
      'staging',
      '--target',
      'lib/main_staging.dart',
      '--',
      '--trace-startup',
    ]);

    expect(result, 0);
    expect(controller.commands.single, [
      'flutter',
      'run',
      '-d',
      'emulator-5554',
      '--flavor',
      'staging',
      '-t',
      'lib/main_staging.dart',
      '--dart-define=ENV=staging',
      '--trace-startup',
    ]);
  });

  test('supports status, tail, stop, and stale session cleanup', () async {
    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_lifecycle_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final controller = FakeRuntimeLogProcessController();
    final startOutput = StringBuffer();
    final workflow = _workflow(root, controller, output: startOutput);
    expect(await workflow.run(['start', '--session', 'emulator']), 0);

    final statusOutput = StringBuffer();
    expect(
      await _workflow(
        root,
        controller,
        output: statusOutput,
      ).run(['status', '--session', 'emulator']),
      0,
    );
    expect(statusOutput.toString(), contains('status=running'));
    expect(statusOutput.toString(), contains('pid=4101'));

    final tailOutput = StringBuffer();
    expect(
      await _workflow(
        root,
        controller,
        output: tailOutput,
      ).run(['tail', '--session', 'emulator', '--lines', '1']),
      0,
    );
    expect(tailOutput.toString(), contains('second line'));
    expect(tailOutput.toString(), isNot(contains('first line')));

    final stopOutput = StringBuffer();
    expect(
      await _workflow(
        root,
        controller,
        output: stopOutput,
      ).run(['stop', '--session', 'emulator']),
      0,
    );
    expect(controller.running, isEmpty);
    expect(stopOutput.toString(), contains("Stopped session 'emulator'"));
    expect(
      File(
        p.join(
          root.path,
          '_artifacts',
          'runtime_logs',
          'emulator',
          'stream.pid',
        ),
      ).existsSync(),
      isFalse,
    );

    final staleDirectory = Directory(
      p.join(root.path, '_artifacts', 'runtime_logs', 'stale'),
    )..createSync(recursive: true);
    File(p.join(staleDirectory.path, 'stream.pid')).writeAsStringSync('9999\n');
    final staleOutput = StringBuffer();
    expect(
      await _workflow(
        root,
        controller,
        output: staleOutput,
      ).run(['status', '--session', 'stale']),
      0,
    );
    expect(staleOutput.toString(), contains('stale_pid=9999'));
  });

  test('rejects invalid session and tail arguments', () async {
    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_validation_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final errors = StringBuffer();
    final workflow = _workflow(
      root,
      FakeRuntimeLogProcessController(),
      errors: errors,
    );

    expect(await workflow.run(['start', '--session', '../unsafe']), 2);
    expect(errors.toString(), contains('Invalid session name'));

    errors.clear();
    expect(await workflow.run(['tail', '--lines', '-1']), 2);
    expect(
      errors.toString(),
      contains('--lines must be a non-negative integer'),
    );
  });
}

RuntimeLogWorkflow _workflow(
  Directory root,
  FakeRuntimeLogProcessController controller, {
  StringBuffer? output,
  StringBuffer? errors,
}) {
  final actualOutput = output ?? StringBuffer();
  final actualErrors = errors ?? StringBuffer();
  return RuntimeLogWorkflow(
    sessionManager: RuntimeLogSessionManager(
      rootDirectory: root,
      processController: controller,
      startupDelay: Duration.zero,
      output: actualOutput,
      errorOutput: actualErrors,
    ),
    output: actualOutput,
    errorOutput: actualErrors,
  );
}

class FakeRuntimeLogProcessController implements RuntimeLogProcessController {
  final commands = <List<String>>[];
  final running = <int>{};

  @override
  Future<int> start({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
  }) async {
    commands.add(List<String>.from(command));
    running.add(4101);
    logFile.writeAsStringSync(
      'first line\nsecond line\n',
      mode: FileMode.append,
    );
    return 4101;
  }

  @override
  Future<bool> isRunning(int pid) async => running.contains(pid);

  @override
  Future<void> stop(int pid) async {
    running.remove(pid);
  }
}
