import 'dart:io';

import 'package:mobile_core_kit_cli/src/ci/ci_classification.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test(
    'combines clean diff paths with changed V2 plan risk and impacts',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'mobilekit_ci_classify_',
      );
      addTearDown(() => root.deleteSync(recursive: true));
      final plans = _MemoryPlanReader({
        '$_head:$_planPath': taskPlanFixture(
          taskId: 'ci-runtime-plan',
          status: 'completed',
          risk: 'high',
          allowedPaths: '$_planPath, lib/features/example/',
          oracleIds: 'ui.human-review',
        ),
      });
      final service = CiClassificationService(
        root: root,
        diffs: _FixedDiffReader([_planPath, 'docs/README.md']),
        plans: plans,
      );

      final result = await service.classify(_base, _head);

      expect(result.classification.effectiveRisk, TaskRisk.high);
      expect(result.runtimeRequired, isTrue);
      expect(result.planPaths, [_planPath]);
      expect(
        renderCiOutputs(result),
        'effective_risk=high\n'
        'runtime_required=true\n'
        'changed_path_count=2\n'
        'plan_count=1\n',
      );
    },
  );

  test('harness-only changes stay out of the runtime lane', () async {
    final root = Directory.systemTemp.createTempSync('mobilekit_ci_harness_');
    addTearDown(() => root.deleteSync(recursive: true));
    final result = await CiClassificationService(
      root: root,
      diffs: _FixedDiffReader([
        'packages/mobile_core_kit_cli/lib/src/tool.dart',
      ]),
      plans: _MemoryPlanReader(const {}),
    ).classify(_base, _head);

    expect(result.classification.effectiveRisk, TaskRisk.high);
    expect(result.runtimeRequired, isFalse);
  });

  test('auth-sensitive paths select runtime without plan impacts', () async {
    for (final path in [
      'lib/features/auth/domain/token.dart',
      'lib/features/session/data/session_repository.dart',
      'lib/features/account/subfeatures/account_deletion/domain/delete.dart',
    ]) {
      final root = Directory.systemTemp.createTempSync('mobilekit_ci_auth_');
      addTearDown(() => root.deleteSync(recursive: true));
      final result = await CiClassificationService(
        root: root,
        diffs: _FixedDiffReader([path]),
        plans: _MemoryPlanReader(const {}),
      ).classify(_base, _head);

      expect(result.classification.effectiveRisk, TaskRisk.high, reason: path);
      expect(result.runtimeRequired, isTrue, reason: path);
    }
  });

  test('uses the base copy of a deleted V2 plan', () async {
    final root = Directory.systemTemp.createTempSync('mobilekit_ci_deleted_');
    addTearDown(() => root.deleteSync(recursive: true));
    final plans = _MemoryPlanReader({
      '$_base:$_planPath': taskPlanFixture(
        taskId: 'ci-deleted-plan',
        status: 'active',
        risk: 'high',
        allowedPaths: '$_planPath, lib/features/example/',
        oracleIds: 'ui.human-review',
      ),
    });
    final result = await CiClassificationService(
      root: root,
      diffs: _FixedDiffReader([_planPath]),
      plans: plans,
    ).classify(_base, _head);

    expect(result.classification.effectiveRisk, TaskRisk.high);
    expect(plans.requests, ['$_head:$_planPath', '$_base:$_planPath']);
  });

  test('fails closed on malformed changed V2 plans and revisions', () async {
    final root = Directory.systemTemp.createTempSync('mobilekit_ci_invalid_');
    addTearDown(() => root.deleteSync(recursive: true));
    final service = CiClassificationService(
      root: root,
      diffs: _FixedDiffReader([_planPath]),
      plans: _MemoryPlanReader({
        '$_head:$_planPath': '**Plan version:** 2\n**Risk:** low\n',
      }),
    );

    await expectLater(
      service.classify(_base, _head),
      throwsA(isA<TaskPlanError>()),
    );
    await expectLater(
      service.classify('HEAD', _head),
      throwsA(_controlError('ci.revision-invalid')),
    );
  });
}

const _base = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _head = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const _planPath = 'docs/exec-plans/completed/change.md';

class _FixedDiffReader implements CiDiffReader {
  const _FixedDiffReader(this.paths);

  final List<String> paths;

  @override
  Future<List<String>> changedPaths(String base, String head) async => paths;
}

class _MemoryPlanReader implements CiPlanReader {
  _MemoryPlanReader(this.sources);

  final Map<String, String> sources;
  final List<String> requests = [];

  @override
  Future<String?> read(String revision, String path) async {
    final key = '$revision:$path';
    requests.add(key);
    return sources[key];
  }
}

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);
