import 'dart:io';

import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_binding.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test(
    'binds only an exact verified task fingerprint and selected oracle',
    () async {
      final root = await _fixture();
      addTearDown(() => root.delete(recursive: true));
      final store = FileTaskStateStore(root);
      final service = TaskService(root: root, stateStore: store);
      await service.begin(_planPath);
      final resolver = TaskRuntimeEvidenceBindingResolver(root);

      await expectLater(
        resolver.resolve('runtime-binding-task'),
        throwsA(_controlError('runtime.task-not-verified')),
      );

      final preflight = await service.preflight(
        'runtime-binding-task',
        action: TaskAction.verify,
      );
      final state = store.read('runtime-binding-task');
      store.write(
        state.transition(
          TaskLifecycle.verified,
          at: DateTime.utc(2026, 8, 12),
          reason: 'test-verification-passed',
          lastTaskFingerprint: preflight.taskFingerprint,
        ),
      );

      final binding = await resolver.resolve('runtime-binding-task');
      expect(binding.taskFingerprint, preflight.taskFingerprint);
      expect(binding.runtimeTargets, {
        'auth.integration': 'integration_test/auth_test.dart',
      });

      File(
        p.join(root.path, 'lib', 'features', 'example', 'changed.dart'),
      ).writeAsStringSync('// changed\n');
      await expectLater(
        resolver.resolve('runtime-binding-task'),
        throwsA(_controlError('runtime.task-not-verified')),
      );
    },
  );
}

const _planPath = 'docs/exec-plans/active/runtime.md';

Future<Directory> _fixture() async {
  final root = await Directory.systemTemp.createTemp('runtime_binding_');
  await _git(root, ['init', '-q']);
  await _git(root, ['config', 'user.email', 'mobilekit@example.invalid']);
  await _git(root, ['config', 'user.name', 'Mobilekit Test']);
  File(p.join(root.path, '.gitignore')).writeAsStringSync('.tmp/\n');
  File(p.join(root.path, _planPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      taskPlanFixture(
        taskId: 'runtime-binding-task',
        allowedPaths: '$_planPath, lib/features/example/',
        oracleIds: 'auth.integration',
        impacts: validImpactFixture
            .replaceFirst('- Auth/session: no', '- Auth/session: yes')
            .replaceFirst(
              '- UI/UX/accessibility: yes',
              '- UI/UX/accessibility: no',
            ),
      ),
    );
  File(p.join(root.path, 'harness', 'oracles.yaml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('''
schemaVersion: 1
oracles:
  auth.integration:
    kind: integration-test
    target: integration_test/auth_test.dart
    covers: [auth]
''');
  File(p.join(root.path, 'integration_test', 'auth_test.dart'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('// oracle\n');
  Directory(
    p.join(root.path, 'lib', 'features', 'example'),
  ).createSync(recursive: true);
  await _git(root, ['add', '.']);
  await _git(root, ['commit', '-qm', 'seed']);
  return root;
}

Future<void> _git(Directory root, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: root.path,
  );
  if (result.exitCode != 0) throw StateError('${result.stderr}');
}

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);
