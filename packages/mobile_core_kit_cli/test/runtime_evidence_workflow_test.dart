import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_process.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_workflow.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('captures process output in the evidence log', () async {
    if (Platform.isWindows) return;

    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_evidence_process_test_',
    );
    addTearDown(() => root.delete(recursive: true));
    final logFile = File(p.join(root.path, 'logs', 'process.log'))
      ..createSync(recursive: true);
    final output = StringBuffer();
    final errors = StringBuffer();

    final result =
        await DartRuntimeEvidenceProcessRunner(
          rootDirectory: root,
          platform: CommandPlatform.posix,
        ).run(
          command: ['sh', '-c', 'printf "out\\n"; printf "err\\n" >&2'],
          workingDirectory: root,
          logFile: logFile,
          output: output,
          errorOutput: errors,
        );

    expect(result, 0);
    expect(output.toString(), contains('out'));
    expect(errors.toString(), contains('err'));
    expect(logFile.readAsStringSync(), allOf(contains('out'), contains('err')));
  });

  test('runs discovered targets and writes evidence artifacts', () async {
    final root = await _createRepository();
    addTearDown(() => root.delete(recursive: true));
    final processRunner = FakeRuntimeEvidenceProcessRunner();
    final output = StringBuffer();
    final errors = StringBuffer();
    final artifactsDirectory = p.join(root.path, '_artifacts', 'evidence');

    final result = await RuntimeEvidenceWorkflow(
      rootDirectory: root,
      processRunner: processRunner,
      output: output,
      errorOutput: errors,
    ).run(['--device', 'emulator-5554', '--artifacts-dir', artifactsDirectory]);

    expect(result, 0);
    expect(errors, isEmpty);
    expect(processRunner.commands, [
      ['dart', 'format', _generatedConfigPath],
      [
        'flutter',
        'test',
        '-d',
        'emulator-5554',
        '--flavor',
        'dev',
        'integration_test/first_test.dart',
      ],
      [
        'flutter',
        'test',
        '-d',
        'emulator-5554',
        '--flavor',
        'dev',
        'integration_test/second_test.dart',
      ],
    ]);

    final artifacts = Directory(artifactsDirectory);
    final metadata = File(p.join(artifacts.path, 'metadata.txt'));
    final summary = File(p.join(artifacts.path, 'summary.md'));
    expect(
      metadata.readAsStringSync(),
      allOf(contains('device=emulator-5554'), contains('env_source=existing')),
    );
    expect(
      summary.readAsStringSync(),
      allOf(
        contains('✅ `integration_test/first_test.dart`'),
        contains('✅ `integration_test/second_test.dart`'),
        contains('Startup metrics'),
        contains('traceId'),
      ),
    );
    expect(
      File(p.join(artifacts.path, 'logs', 'preflight.log')).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(artifacts.path, 'logs', 'integration_test_first_test.dart.log'),
      ).existsSync(),
      isTrue,
    );
    expect(output.toString(), contains('completed successfully'));
  });

  test('copies the example environment and explicit Firebase config', () async {
    final root = await _createRepository(includeEnvironment: false);
    addTearDown(() => root.delete(recursive: true));
    File(
      p.join(root.path, '.env', 'dev.example.yaml'),
    ).writeAsStringSync('core: https://example.test\n');
    final externalGoogleServices = File(
      p.join(root.path, 'secure-google-services.json'),
    )..writeAsStringSync('{"project_id":"example"}\n');
    final processRunner = FakeRuntimeEvidenceProcessRunner();
    final artifactsDirectory = p.join(root.path, '_artifacts', 'fallback');

    final result =
        await RuntimeEvidenceWorkflow(
          rootDirectory: root,
          processRunner: processRunner,
          output: StringBuffer(),
          errorOutput: StringBuffer(),
        ).run([
          '--device',
          'emulator-5554',
          '--target',
          'integration_test/first_test.dart',
          '--artifacts-dir',
          artifactsDirectory,
          '--google-services-json',
          externalGoogleServices.path,
        ]);

    expect(result, 0);
    expect(
      File(p.join(root.path, '.env', 'dev.yaml')).readAsStringSync(),
      'core: https://example.test\n',
    );
    expect(
      File(
        p.join(root.path, 'android', 'app', 'google-services.json'),
      ).readAsStringSync(),
      externalGoogleServices.readAsStringSync(),
    );
    expect(
      File(p.join(artifactsDirectory, 'metadata.txt')).readAsStringSync(),
      allOf(
        contains('env_source=copied-from-example'),
        contains('google_services_source=copied-from-flag'),
      ),
    );
  });

  test('runs every target and reports aggregate failures', () async {
    final root = await _createRepository(includeFailingTarget: true);
    addTearDown(() => root.delete(recursive: true));
    final processRunner = FakeRuntimeEvidenceProcessRunner(
      failingTarget: 'integration_test/failing_test.dart',
    );
    final output = StringBuffer();
    final errors = StringBuffer();
    final artifactsDirectory = p.join(root.path, '_artifacts', 'failure');

    final result =
        await RuntimeEvidenceWorkflow(
          rootDirectory: root,
          processRunner: processRunner,
          output: output,
          errorOutput: errors,
        ).run([
          '--device',
          'emulator-5554',
          '--target',
          'integration_test/failing_test.dart',
          '--target',
          'integration_test/first_test.dart',
          '--artifacts-dir',
          artifactsDirectory,
        ]);

    expect(result, 1);
    expect(
      processRunner.commands.where((command) => command.first == 'flutter'),
      hasLength(2),
    );
    expect(
      File(p.join(artifactsDirectory, 'summary.md')).readAsStringSync(),
      allOf(
        contains('❌ `integration_test/failing_test.dart` (exit=7)'),
        contains('✅ `integration_test/first_test.dart`'),
      ),
    );
    expect(output.toString(), contains('completed with failures'));
  });

  test('rejects missing devices and disabled environment fallback', () async {
    final root = await _createRepository(includeEnvironment: false);
    addTearDown(() => root.delete(recursive: true));
    File(
      p.join(root.path, '.env', 'dev.example.yaml'),
    ).writeAsStringSync('core: https://example.test\n');
    final errors = StringBuffer();
    final workflow = RuntimeEvidenceWorkflow(
      rootDirectory: root,
      processRunner: FakeRuntimeEvidenceProcessRunner(),
      output: StringBuffer(),
      errorOutput: errors,
    );

    expect(await workflow.run([]), 2);
    expect(errors.toString(), contains('--device is required'));

    errors.clear();
    expect(
      await workflow.run([
        '--device',
        'emulator-5554',
        '--no-example-env-fallback',
      ]),
      1,
    );
    expect(errors.toString(), contains('Missing or empty env file'));
  });
}

const _generatedConfigPath =
    'lib/core/foundation/config/build_config_values.dart';

Future<Directory> _createRepository({
  bool includeEnvironment = true,
  bool includeFailingTarget = false,
}) async {
  final root = await Directory.systemTemp.createTemp(
    'mobile_core_kit_cli_evidence_workflow_test_',
  );
  Directory(p.join(root.path, '.env')).createSync(recursive: true);
  Directory(p.join(root.path, 'android', 'app')).createSync(recursive: true);
  Directory(
    p.join(root.path, 'lib', 'core', 'foundation', 'config'),
  ).createSync(recursive: true);
  Directory(p.join(root.path, 'integration_test')).createSync(recursive: true);
  File(
    p.join(root.path, 'integration_test', 'first_test.dart'),
  ).writeAsStringSync('// test\n');
  File(
    p.join(root.path, 'integration_test', 'second_test.dart'),
  ).writeAsStringSync('// test\n');
  if (includeFailingTarget) {
    File(
      p.join(root.path, 'integration_test', 'failing_test.dart'),
    ).writeAsStringSync('// test\n');
  }
  if (includeEnvironment) {
    File(
      p.join(root.path, '.env', 'dev.yaml'),
    ).writeAsStringSync('core: https://api.example.test\n');
  }
  File(
    p.join(root.path, 'android', 'app', 'google-services.json'),
  ).writeAsStringSync('{"project_id":"example"}\n');
  return root;
}

class FakeRuntimeEvidenceProcessRunner implements RuntimeEvidenceProcessRunner {
  FakeRuntimeEvidenceProcessRunner({this.failingTarget});

  final String? failingTarget;
  final commands = <List<String>>[];

  @override
  Future<int> run({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
    required StringSink output,
    required StringSink errorOutput,
  }) async {
    commands.add(List<String>.from(command));
    logFile.parent.createSync(recursive: true);
    final isFlutterTest =
        command.length > 1 &&
        command.first == 'flutter' &&
        command[1] == 'test';
    final target = isFlutterTest ? command.last : '';
    final log = isFlutterTest
        ? 'Startup metrics: target=$target\ntraceId=$target-trace\n'
        : 'formatted ${command.last}\n';
    logFile.writeAsStringSync(log, mode: FileMode.append);
    output.write(log);

    if (target == failingTarget) {
      const failure = 'integration test failed\n';
      logFile.writeAsStringSync(failure, mode: FileMode.append);
      errorOutput.write(failure);
      return 7;
    }
    return 0;
  }
}
