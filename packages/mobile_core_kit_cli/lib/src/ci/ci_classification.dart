import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/policy/risk_classifier.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';

class CiClassification {
  const CiClassification({
    required this.classification,
    required this.runtimeRequired,
    required this.changedPaths,
    required this.planPaths,
  });

  final RiskClassification classification;
  final bool runtimeRequired;
  final List<String> changedPaths;
  final List<String> planPaths;
}

abstract interface class CiDiffReader {
  Future<List<String>> changedPaths(String base, String head);
}

abstract interface class CiPlanReader {
  Future<String?> read(String revision, String path);
}

class NativeCiDiffReader implements CiDiffReader {
  const NativeCiDiffReader(this.root);

  final Directory root;

  @override
  Future<List<String>> changedPaths(String base, String head) async {
    _validateRevision(base, 'base');
    _validateRevision(head, 'head');
    final result = await Process.run(
      'git',
      [
        'diff',
        '--name-only',
        '--diff-filter=ACMRDT',
        '-z',
        '$base...$head',
        '--',
      ],
      workingDirectory: root.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw const TaskControlError(
        'ci.diff-failed',
        'Could not classify the clean base/head Git diff.',
      );
    }
    final paths =
        (result.stdout as String)
            .split('\x00')
            .where((path) => path.isNotEmpty)
            .map(normalizeRepositoryPath)
            .toSet()
            .toList()
          ..sort();
    return paths;
  }
}

class NativeCiPlanReader implements CiPlanReader {
  const NativeCiPlanReader(this.root);

  static const maximumPlanBytes = 64 * 1024;

  final Directory root;

  @override
  Future<String?> read(String revision, String path) async {
    _validateRevision(revision, 'plan');
    final normalized = normalizeRepositoryPath(path);
    final result = await Process.run(
      'git',
      ['show', '$revision:$normalized'],
      workingDirectory: root.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    final source = result.stdout as String;
    if (utf8.encode(source).length > maximumPlanBytes) {
      throw TaskControlError(
        'ci.plan-too-large',
        'Changed execution plan exceeds $maximumPlanBytes bytes.',
      );
    }
    return source;
  }
}

class CiClassificationService {
  CiClassificationService({
    required this.root,
    CiDiffReader? diffs,
    CiPlanReader? plans,
  }) : diffs = diffs ?? NativeCiDiffReader(root),
       plans = plans ?? NativeCiPlanReader(root);

  final Directory root;
  final CiDiffReader diffs;
  final CiPlanReader plans;

  Future<CiClassification> classify(String base, String head) async {
    _validateRevision(base, 'base');
    _validateRevision(head, 'head');
    final changedPaths = await diffs.changedPaths(base, head);
    final planPaths = changedPaths.where(_isExecutionPlan).toList();
    final parsedPlans = <TaskPlan>[];
    for (final path in planPaths) {
      final headSource = await plans.read(head, path);
      final source = headSource ?? await plans.read(base, path);
      if (source == null ||
          !RegExp(
            r'^\*\*Plan version:\*\*',
            multiLine: true,
          ).hasMatch(source)) {
        continue;
      }
      parsedPlans.add(parseTaskPlan(path, source));
    }
    final declaredRisk = parsedPlans.isEmpty
        ? null
        : TaskRisk.maximum(parsedPlans.map((plan) => plan.risk));
    final impacts = _combineImpacts(parsedPlans);
    final classification = classifyRisk(
      changedPaths,
      declaredRisk: declaredRisk,
      impacts: impacts,
    );
    return CiClassification(
      classification: classification,
      runtimeRequired: _runtimeRequired(changedPaths, impacts),
      changedPaths: List.unmodifiable(changedPaths),
      planPaths: List.unmodifiable(planPaths..sort()),
    );
  }
}

String renderCiOutputs(CiClassification result) =>
    'effective_risk=${result.classification.effectiveRisk.name}\n'
    'runtime_required=${result.runtimeRequired}\n'
    'changed_path_count=${result.changedPaths.length}\n'
    'plan_count=${result.planPaths.length}\n';

TaskImpactAreas _combineImpacts(List<TaskPlan> plans) => TaskImpactAreas(
  auth: plans.any((plan) => plan.impacts.auth),
  navigation: plans.any((plan) => plan.impacts.navigation),
  api: plans.any((plan) => plan.impacts.api),
  database: plans.any((plan) => plan.impacts.database),
  platform: plans.any((plan) => plan.impacts.platform),
  ui: plans.any((plan) => plan.impacts.ui),
  harness: plans.any((plan) => plan.impacts.harness),
  externalSystems: plans.any((plan) => plan.impacts.externalSystems),
);

bool _runtimeRequired(List<String> paths, TaskImpactAreas impacts) {
  if (impacts.auth ||
      impacts.navigation ||
      impacts.platform ||
      impacts.ui ||
      impacts.externalSystems) {
    return true;
  }
  return paths.any(
    (path) =>
        path.startsWith('android/') ||
        path.startsWith('ios/') ||
        path.startsWith('integration_test/') ||
        path.contains('/goldens/') ||
        path.contains('/auth/') ||
        path.startsWith('lib/navigation/') ||
        path.contains('deep_link') ||
        path.contains('app_startup'),
  );
}

bool _isExecutionPlan(String path) => RegExp(
  r'^docs/exec-plans/(?:active|queued|completed)/[^/]+\.md$',
).hasMatch(path);

void _validateRevision(String revision, String label) {
  if (!RegExp(r'^[0-9a-f]{40,64}$').hasMatch(revision) ||
      RegExp(r'^0+$').hasMatch(revision)) {
    throw TaskControlError(
      'ci.revision-invalid',
      'CI $label revision is invalid.',
    );
  }
}
