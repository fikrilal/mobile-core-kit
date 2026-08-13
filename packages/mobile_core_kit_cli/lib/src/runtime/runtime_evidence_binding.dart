import 'dart:io';

import 'package:mobile_core_kit_cli/src/oracle/oracle_registry.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_control_root.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';

class RuntimeEvidenceBinding {
  const RuntimeEvidenceBinding({
    required this.taskId,
    required this.planPath,
    required this.planSourceHash,
    required this.authorityHash,
    required this.baseRevision,
    required this.candidateRevision,
    required this.taskFingerprint,
    required this.oracleIds,
    required this.runtimeTargets,
  });

  final String taskId;
  final String planPath;
  final String planSourceHash;
  final String authorityHash;
  final String baseRevision;
  final String candidateRevision;
  final String taskFingerprint;
  final List<String> oracleIds;
  final Map<String, String> runtimeTargets;
}

abstract interface class RuntimeEvidenceBindingResolver {
  Future<RuntimeEvidenceBinding> resolve(String taskId);
}

class TaskRuntimeEvidenceBindingResolver
    implements RuntimeEvidenceBindingResolver {
  const TaskRuntimeEvidenceBindingResolver(this.root);

  final Directory root;

  @override
  Future<RuntimeEvidenceBinding> resolve(String taskId) async {
    final controlRoot = await const TaskControlRootLocator().locate(root);
    final store = FileTaskStateStore(controlRoot);
    final service = TaskService(root: root, stateStore: store);
    final preflight = await service.preflight(
      taskId,
      action: TaskAction.verify,
    );
    final state = store.read(taskId);
    if (state.lifecycle != TaskLifecycle.verified ||
        state.lastTaskFingerprint != preflight.taskFingerprint) {
      throw const TaskControlError(
        'runtime.task-not-verified',
        'Runtime evidence requires the exact current task fingerprint to pass controlled verification first.',
      );
    }
    late final OracleRegistry registry;
    try {
      registry = OracleRegistry.load(root);
    } on OracleRegistryError catch (error) {
      throw TaskControlError(error.code, error.message);
    }
    final targets = <String, String>{};
    for (final id in state.oracleIds) {
      final oracle = registry.definitions[id];
      if (oracle?.kind == 'integration-test') {
        targets[id] = oracle!.target;
      }
    }
    if (targets.isEmpty) {
      throw const TaskControlError(
        'runtime.oracle-missing',
        'The task must select at least one registered integration-test oracle.',
      );
    }
    return RuntimeEvidenceBinding(
      taskId: taskId,
      planPath: state.planPath,
      planSourceHash: state.planSourceHash,
      authorityHash: state.authorityHash,
      baseRevision: state.baseRevision,
      candidateRevision: await NativeGitRepository(root).head(),
      taskFingerprint: preflight.taskFingerprint,
      oracleIds: state.oracleIds,
      runtimeTargets: Map.unmodifiable(targets),
    );
  }
}
