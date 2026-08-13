import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/git_worktree_client.dart';
import 'package:mobile_core_kit_cli/src/task/repository_mutation_lock.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;

class TaskWorkspaceResult {
  const TaskWorkspaceResult({required this.taskId, required this.workspace});

  final String taskId;
  final TaskWorkspace workspace;
}

class TaskWorkspaceManager {
  TaskWorkspaceManager({
    required this.checkoutRoot,
    required this.controlRoot,
    required this.service,
    required this.stateStore,
    GitWorktreeClient? git,
    RepositoryMutationLock? lock,
    DateTime Function()? now,
  }) : git = git ?? NativeGitWorktreeClient(controlRoot),
       lock = lock ?? RepositoryMutationLock(controlRoot),
       now = now ?? DateTime.now;

  final Directory checkoutRoot;
  final Directory controlRoot;
  final TaskService service;
  final TaskStateStore stateStore;
  final GitWorktreeClient git;
  final RepositoryMutationLock lock;
  final DateTime Function() now;

  Future<TaskWorkspaceResult> prepare(String taskId) async {
    final state = stateStore.read(taskId);
    if (state.workspace != null) {
      throw const TaskControlError(
        'workspace.already-owned',
        'Task workspace ownership is already recorded.',
      );
    }
    _requireControlRoot();
    await service.preflight(taskId, action: TaskAction.edit);
    final branch = 'agent/$taskId';
    final path = canonicalWorkspacePath(
      p.join(controlRoot.path, '.tmp', 'mobilekit', 'worktrees', taskId),
    );
    return lock.protect(() async {
      if (Directory(path).existsSync() || File(path).existsSync()) {
        throw const TaskControlError(
          'workspace.path-exists',
          'Deterministic task workspace path already exists.',
        );
      }
      if (await git.branchExists(branch)) {
        throw const TaskControlError(
          'workspace.branch-exists',
          'Deterministic task branch already exists.',
        );
      }
      await git.add(
        path: path,
        branch: branch,
        baseRevision: state.baseRevision,
      );
      final record = await _ownedRecord(path, branch: branch);
      if (record.head != state.baseRevision) {
        throw const TaskControlError(
          'workspace.base-mismatch',
          'Prepared task workspace does not match the recorded base.',
        );
      }
      final workspace = TaskWorkspace(
        controlRoot: canonicalWorkspacePath(controlRoot.path),
        path: path,
        branch: branch,
        baseRevision: state.baseRevision,
        lifecycle: TaskWorkspaceLifecycle.prepared,
      );
      stateStore.write(
        state.transition(
          state.lifecycle,
          at: now().toUtc(),
          reason: 'workspace-prepared',
          workspace: workspace,
        ),
      );
      return TaskWorkspaceResult(taskId: taskId, workspace: workspace);
    });
  }

  TaskWorkspaceResult status(String taskId) {
    final state = stateStore.read(taskId);
    final workspace = state.workspace;
    if (workspace == null) {
      throw const TaskControlError(
        'workspace.not-prepared',
        'Task workspace has not been prepared.',
      );
    }
    return TaskWorkspaceResult(taskId: taskId, workspace: workspace);
  }

  TaskWorkspaceResult cancel(String taskId) {
    final state = stateStore.read(taskId);
    final workspace = _requireWorkspace(
      state,
      expected: TaskWorkspaceLifecycle.prepared,
    );
    final cancelled = workspace.withLifecycle(TaskWorkspaceLifecycle.cancelled);
    stateStore.write(
      state.transition(
        state.lifecycle,
        at: now().toUtc(),
        reason: 'workspace-cancelled',
        workspace: cancelled,
      ),
    );
    return TaskWorkspaceResult(taskId: taskId, workspace: cancelled);
  }

  Future<TaskWorkspaceResult> cleanup(String taskId) async {
    final state = stateStore.read(taskId);
    final workspace = _requireWorkspace(
      state,
      expected: TaskWorkspaceLifecycle.cancelled,
    );
    _requireControlRoot();
    return lock.protect(() async {
      await _ownedRecord(workspace.path, branch: workspace.branch);
      final dirty = await git.dirtyPaths(workspace.path);
      if (dirty.isNotEmpty) {
        throw TaskControlError(
          'workspace.dirty',
          'Task workspace is dirty: ${dirty.take(5).join(', ')}.',
        );
      }
      await git.remove(workspace.path);
      final remaining = await git.list();
      if (remaining.any(
        (record) => record.path == canonicalWorkspacePath(workspace.path),
      )) {
        throw const TaskControlError(
          'workspace.cleanup-ambiguous',
          'Git still reports the removed task workspace.',
        );
      }
      final cleaned = workspace.withLifecycle(TaskWorkspaceLifecycle.cleaned);
      stateStore.write(
        state.transition(
          state.lifecycle,
          at: now().toUtc(),
          reason: 'workspace-cleaned',
          workspace: cleaned,
        ),
      );
      return TaskWorkspaceResult(taskId: taskId, workspace: cleaned);
    });
  }

  Future<GitWorktreeInfo> _ownedRecord(
    String path, {
    required String branch,
  }) async {
    final canonical = canonicalWorkspacePath(path);
    final records = (await git.list())
        .where((record) => record.path == canonical)
        .toList();
    if (records.length != 1 || records.single.branch != branch) {
      throw const TaskControlError(
        'workspace.ownership-mismatch',
        'Task workspace path or branch ownership is ambiguous.',
      );
    }
    return records.single;
  }

  TaskWorkspace _requireWorkspace(
    TaskState state, {
    required TaskWorkspaceLifecycle expected,
  }) {
    final workspace = state.workspace;
    if (workspace == null || workspace.lifecycle != expected) {
      throw TaskControlError(
        'workspace.lifecycle-invalid',
        'Workspace must be ${expected.name} for this action.',
      );
    }
    return workspace;
  }

  void _requireControlRoot() {
    if (canonicalWorkspacePath(checkoutRoot.path) !=
        canonicalWorkspacePath(controlRoot.path)) {
      throw const TaskControlError(
        'workspace.primary-required',
        'Run this workspace mutation from the primary worktree.',
      );
    }
  }
}
