import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:mobile_core_kit_cli/src/task/task_workspace_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test(
    'native worktree isolates dirty primary state and remains rediscoverable',
    () async {
      final fixture = await _nativeFixture();
      addTearDown(() => fixture.root.delete(recursive: true));

      final prepared = await fixture.manager.prepare(_taskId);
      final workspaceRoot = Directory(prepared.workspace.path);
      expect(workspaceRoot.existsSync(), isTrue);
      expect(
        File(p.join(workspaceRoot.path, 'user.txt')).existsSync(),
        isFalse,
      );
      expect(prepared.workspace.branch, 'agent/$_taskId');
      expect(prepared.workspace.baseRevision, fixture.baseRevision);

      final rediscovered = await const TaskControlRootLocator().locate(
        workspaceRoot,
      );
      expect(
        p.canonicalize(rediscovered.path),
        p.canonicalize(fixture.root.path),
      );

      await expectLater(
        fixture.service.preflight(_taskId, action: TaskAction.verify),
        throwsA(_error('workspace.checkout-mismatch')),
      );
      final workspaceService = TaskService(
        root: workspaceRoot,
        stateStore: fixture.store,
      );
      final workspacePreflight = await workspaceService.preflight(
        _taskId,
        action: TaskAction.verify,
      );
      expect(workspacePreflight.taskPaths, isEmpty);

      final cancelled = fixture.manager.cancel(_taskId);
      expect(cancelled.workspace.lifecycle, TaskWorkspaceLifecycle.cancelled);
      final cleaned = await fixture.manager.cleanup(_taskId);
      expect(cleaned.workspace.lifecycle, TaskWorkspaceLifecycle.cleaned);
      expect(workspaceRoot.existsSync(), isFalse);
      expect(await _branchExists(fixture.root, 'agent/$_taskId'), isTrue);
    },
  );

  test('cleanup refuses a dirty owned worktree', () async {
    final fixture = await _nativeFixture(taskId: 'dirty-workspace-task');
    addTearDown(() => fixture.root.delete(recursive: true));
    final prepared = await fixture.manager.prepare('dirty-workspace-task');
    File(
      p.join(prepared.workspace.path, 'dirty.txt'),
    ).writeAsStringSync('dirty');
    fixture.manager.cancel('dirty-workspace-task');

    await expectLater(
      fixture.manager.cleanup('dirty-workspace-task'),
      throwsA(_error('workspace.dirty')),
    );
    expect(Directory(prepared.workspace.path).existsSync(), isTrue);
  });

  test('repository mutation lock fails immediately on contention', () async {
    final fixture = await _nativeFixture(taskId: 'locked-workspace-task');
    addTearDown(() => fixture.root.delete(recursive: true));
    final lock =
        File(
            p.join(
              fixture.root.path,
              '.tmp/mobilekit/locks/repository-mutation.lock',
            ),
          )
          ..parent.createSync(recursive: true)
          ..writeAsStringSync('held');

    await expectLater(
      fixture.manager.prepare('locked-workspace-task'),
      throwsA(_error('workspace.locked')),
    );
    expect(lock.existsSync(), isTrue);
  });
}

const _taskId = 'isolated-workspace-task';

class _NativeFixture {
  const _NativeFixture({
    required this.root,
    required this.baseRevision,
    required this.store,
    required this.service,
    required this.manager,
  });

  final Directory root;
  final String baseRevision;
  final FileTaskStateStore store;
  final TaskService service;
  final TaskWorkspaceManager manager;
}

Future<_NativeFixture> _nativeFixture({String taskId = _taskId}) async {
  final root = await Directory.systemTemp.createTemp('mobilekit_workspace_');
  await _git(root, ['init', '-q']);
  await _git(root, ['config', 'user.email', 'mobilekit@example.invalid']);
  await _git(root, ['config', 'user.name', 'Mobilekit Test']);
  File(p.join(root.path, '.gitignore')).writeAsStringSync('.tmp/\n');
  final planPath = 'docs/exec-plans/active/test.md';
  File(p.join(root.path, planPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      taskPlanFixture(
        taskId: taskId,
        allowedPaths: '$planPath, lib/features/example/',
      ),
    );
  Directory(
    p.join(root.path, 'lib/features/example'),
  ).createSync(recursive: true);
  await _git(root, ['add', '.']);
  await _git(root, ['commit', '-qm', 'seed']);
  final baseRevision = (await _git(root, ['rev-parse', 'HEAD'])).trim();
  File(p.join(root.path, 'user.txt')).writeAsStringSync('user-owned');
  final store = FileTaskStateStore(root);
  final service = TaskService(root: root, stateStore: store);
  await service.begin(planPath);
  return _NativeFixture(
    root: root,
    baseRevision: baseRevision,
    store: store,
    service: service,
    manager: TaskWorkspaceManager(
      checkoutRoot: root,
      controlRoot: root,
      service: service,
      stateStore: store,
    ),
  );
}

Future<String> _git(Directory root, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: root.path,
  );
  if (result.exitCode != 0) {
    throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
  }
  return '${result.stdout}';
}

Future<bool> _branchExists(Directory root, String branch) async {
  final result = await Process.run('git', [
    'show-ref',
    '--verify',
    '--quiet',
    'refs/heads/$branch',
  ], workingDirectory: root.path);
  return result.exitCode == 0;
}

Matcher _error(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);
