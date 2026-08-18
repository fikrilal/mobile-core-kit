import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_binding.dart';
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

  test('bounds live process logs before the process exits', () async {
    if (Platform.isWindows) return;
    final root = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_evidence_log_limit_',
    );
    addTearDown(() => root.delete(recursive: true));
    final logFile = File(p.join(root.path, 'process.log'));

    final result =
        await DartRuntimeEvidenceProcessRunner(
          rootDirectory: root,
          platform: CommandPlatform.posix,
        ).run(
          command: ['sh', '-c', 'head -c 1100000 /dev/zero | tr "\\000" x'],
          workingDirectory: root,
          logFile: logFile,
          output: _DiscardSink(),
          errorOutput: _DiscardSink(),
        );

    expect(result, 0);
    expect(logFile.lengthSync(), runtimeEvidenceLogLimitBytes);
  });

  test('runs discovered targets and writes evidence artifacts', () async {
    final root = await _createRepository();
    addTearDown(() => root.delete(recursive: true));
    final processRunner = FakeRuntimeEvidenceProcessRunner();
    final output = StringBuffer();
    final errors = StringBuffer();
    final artifactsDirectory = p.join(root.path, '_artifacts', 'evidence');

    final result =
        await RuntimeEvidenceWorkflow(
          rootDirectory: root,
          processRunner: processRunner,
          bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
          output: output,
          errorOutput: errors,
        ).run([
          '--task',
          'runtime-task',
          '--device',
          'emulator-5554',
          '--artifacts-dir',
          artifactsDirectory,
        ]);

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
    final manifest = File(p.join(artifacts.path, 'evidence.json'));
    final summary = File(p.join(artifacts.path, 'summary.md'));
    final durable = manifest.readAsStringSync();
    expect(durable, contains('"id": "runtime-task"'));
    expect(durable, contains('"outcome": "passed"'));
    expect(durable, contains('"environmentPreparation": "existing"'));
    expect(durable, isNot(contains('emulator-5554')));
    expect(durable, isNot(contains(root.path)));
    expect(durable, isNot(contains('abc.def.secret')));
    expect(durable, isNot(contains('person@example.com')));
    expect(
      summary.readAsStringSync(),
      allOf(
        contains('PASS `oracle.first_test.dart`'),
        contains('PASS `oracle.second_test.dart`'),
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
    expect(output.toString(), contains('Mobile evidence passed'));
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
          bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
          output: StringBuffer(),
          errorOutput: StringBuffer(),
        ).run([
          '--task',
          'runtime-task',
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
    expect(File(p.join(root.path, '.env', 'dev.yaml')).existsSync(), isFalse);
    expect(
      File(
        p.join(root.path, 'android', 'app', 'google-services.json'),
      ).readAsStringSync(),
      '{"project_id":"example"}\n',
    );
    final durable = File(
      p.join(artifactsDirectory, 'evidence.json'),
    ).readAsStringSync();
    expect(durable, contains('"environmentPreparation": "temporary-example"'));
    expect(durable, contains('"firebasePreparation": "temporary-explicit"'));
    expect(durable, isNot(contains(externalGoogleServices.path)));
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
          bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
          output: output,
          errorOutput: errors,
        ).run([
          '--task',
          'runtime-task',
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
        contains('FAIL `oracle.failing_test.dart`'),
        contains('PASS `oracle.first_test.dart`'),
      ),
    );
    expect(output.toString(), contains('Mobile evidence failed'));
    expect(
      File(p.join(artifactsDirectory, 'evidence.json')).readAsStringSync(),
      contains('"outcome": "failed"'),
    );
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
      bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
      output: StringBuffer(),
      errorOutput: errors,
    );

    expect(await workflow.run([]), 2);
    expect(errors.toString(), contains('--task is required'));

    errors.clear();
    expect(await workflow.run(['--task', 'runtime-task']), 2);
    expect(errors.toString(), contains('--device is required'));

    errors.clear();
    expect(
      await workflow.run([
        '--task',
        'runtime-task',
        '--device',
        'emulator-5554',
        '--no-example-env-fallback',
      ]),
      1,
    );
    expect(errors.toString(), contains('Missing or empty env file'));
  });

  test(
    'rejects unregistered targets and repository-external artifacts',
    () async {
      final root = await _createRepository();
      final outside = await Directory.systemTemp.createTemp(
        'outside_evidence_',
      );
      addTearDown(() async {
        await root.delete(recursive: true);
        await outside.delete(recursive: true);
      });
      final errors = StringBuffer();
      final workflow = RuntimeEvidenceWorkflow(
        rootDirectory: root,
        processRunner: FakeRuntimeEvidenceProcessRunner(),
        bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
        output: StringBuffer(),
        errorOutput: errors,
      );

      expect(
        await workflow.run([
          '--task',
          'runtime-task',
          '--device',
          'secret-device',
          '--target',
          'integration_test/unregistered_test.dart',
        ]),
        2,
      );
      expect(errors.toString(), contains('not selected'));

      errors.clear();
      expect(
        await workflow.run([
          '--task',
          'runtime-task',
          '--device',
          'secret-device',
          '--artifacts-dir',
          outside.path,
        ]),
        2,
      );
      expect(errors.toString(), contains('inside the repository'));
    },
  );

  test(
    'restores temporary environment when later Firebase preparation fails',
    () async {
      final root = await _createRepository(includeEnvironment: false);
      addTearDown(() => root.delete(recursive: true));
      File(
        p.join(root.path, '.env', 'dev.example.yaml'),
      ).writeAsStringSync('core: https://example.test\n');
      final workflow = RuntimeEvidenceWorkflow(
        rootDirectory: root,
        processRunner: FakeRuntimeEvidenceProcessRunner(),
        bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
        output: StringBuffer(),
        errorOutput: StringBuffer(),
      );

      expect(
        await workflow.run([
          '--task',
          'runtime-task',
          '--device',
          'emulator',
          '--google-services-json',
          'missing.json',
        ]),
        1,
      );
      expect(File(p.join(root.path, '.env', 'dev.yaml')).existsSync(), isFalse);
    },
  );

  test('restores all temporary config after build-config failure', () async {
    final root = await _createRepository(includeEnvironment: false);
    addTearDown(() => root.delete(recursive: true));
    File(
      p.join(root.path, '.env', 'dev.example.yaml'),
    ).writeAsStringSync('core: https://example.test\n');
    final external = File(p.join(root.path, 'explicit-google.json'))
      ..writeAsStringSync('{"project_id":"temporary"}\n');
    final googleFile = File(
      p.join(root.path, 'android', 'app', 'google-services.json'),
    );
    final originalGoogle = googleFile.readAsStringSync();
    final artifacts = p.join(root.path, '_artifacts', 'preflight-failure');
    final workflow = RuntimeEvidenceWorkflow(
      rootDirectory: root,
      processRunner: FakeRuntimeEvidenceProcessRunner(failPreflight: true),
      bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
      output: StringBuffer(),
      errorOutput: StringBuffer(),
    );

    expect(
      await workflow.run([
        '--task',
        'runtime-task',
        '--device',
        'emulator',
        '--artifacts-dir',
        artifacts,
        '--google-services-json',
        external.path,
      ]),
      1,
    );
    expect(File(p.join(root.path, '.env', 'dev.yaml')).existsSync(), isFalse);
    expect(googleFile.readAsStringSync(), originalGoogle);
    expect(File(p.join(root.path, _generatedConfigPath)).existsSync(), isFalse);
    expect(
      File(p.join(artifacts, 'evidence.json')).readAsStringSync(),
      allOf(contains('"outcome": "failed"'), isNot(contains(external.path))),
    );
  });

  test('bounds every transient runtime log', () async {
    final root = await _createRepository();
    addTearDown(() => root.delete(recursive: true));
    final artifacts = p.join(root.path, '_artifacts', 'bounded');
    final workflow = RuntimeEvidenceWorkflow(
      rootDirectory: root,
      processRunner: FakeRuntimeEvidenceProcessRunner(
        logPayload: List.filled(runtimeEvidenceLogLimitBytes + 200, 'x').join(),
      ),
      bindingResolver: FakeRuntimeEvidenceBindingResolver(root),
      output: StringBuffer(),
      errorOutput: StringBuffer(),
    );

    expect(
      await workflow.run([
        '--task',
        'runtime-task',
        '--device',
        'emulator',
        '--target',
        'integration_test/first_test.dart',
        '--artifacts-dir',
        artifacts,
      ]),
      0,
    );
    for (final entity in Directory(p.join(artifacts, 'logs')).listSync()) {
      expect(
        File(entity.path).lengthSync(),
        lessThanOrEqualTo(runtimeEvidenceLogLimitBytes),
      );
      if (!Platform.isWindows) {
        final mode = Process.runSync('stat', ['-c', '%a', entity.path]);
        expect('${mode.stdout}'.trim(), '600');
      }
    }
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
  FakeRuntimeEvidenceProcessRunner({
    this.failingTarget,
    this.failPreflight = false,
    this.logPayload,
  });

  final String? failingTarget;
  final bool failPreflight;
  final String? logPayload;
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
    final log =
        logPayload ??
        (isFlutterTest
            ? 'Startup metrics: target=$target\n'
                  'traceId=$target-trace\n'
                  'Authorization: Bearer abc.def.secret\n'
                  'contact=person@example.com\n'
            : 'formatted ${command.last}\n');
    logFile.writeAsStringSync(log, mode: FileMode.append);
    output.write(log);

    if ((!isFlutterTest && failPreflight) || target == failingTarget) {
      const failure = 'integration test failed\n';
      logFile.writeAsStringSync(failure, mode: FileMode.append);
      errorOutput.write(failure);
      return 7;
    }
    return 0;
  }
}

class FakeRuntimeEvidenceBindingResolver
    implements RuntimeEvidenceBindingResolver {
  FakeRuntimeEvidenceBindingResolver(this.root);

  final Directory root;

  @override
  Future<RuntimeEvidenceBinding> resolve(String taskId) async {
    final targets =
        Directory(p.join(root.path, 'integration_test'))
            .listSync()
            .whereType<File>()
            .map((file) => p.relative(file.path, from: root.path))
            .toList()
          ..sort();
    return RuntimeEvidenceBinding(
      taskId: taskId,
      planPath: 'docs/exec-plans/active/runtime.md',
      planSourceHash:
          '1111111111111111111111111111111111111111111111111111111111111111',
      authorityHash:
          '2222222222222222222222222222222222222222222222222222222222222222',
      baseRevision: '3333333333333333333333333333333333333333',
      candidateRevision: '4444444444444444444444444444444444444444',
      taskFingerprint:
          '5555555555555555555555555555555555555555555555555555555555555555',
      oracleIds: targets.map((target) => _oracleId(target)).toList(),
      runtimeTargets: {for (final target in targets) _oracleId(target): target},
    );
  }

  String _oracleId(String target) => 'oracle.${p.basename(target)}';
}

class _DiscardSink implements StringSink {
  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}
