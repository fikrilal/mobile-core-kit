import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test('parses and fingerprints complete V2 authority', () {
    final plan = parseTaskPlan(
      'docs/exec-plans/active/test.md',
      taskPlanFixture(),
    );

    expect(plan.taskId, 'test-task-authority');
    expect(plan.status, TaskPlanStatus.active);
    expect(plan.risk, TaskRisk.medium);
    expect(plan.boundaries.maximumRisk, TaskRisk.high);
    expect(plan.boundaries.allowedActions, [
      TaskAction.edit,
      TaskAction.verify,
    ]);
    expect(plan.boundaries.timeout, const Duration(minutes: 90));
    expect(plan.impacts.ui, isTrue);
    expect(plan.sourceHash, hasLength(64));
    expect(plan.authorityHash, hasLength(64));
  });

  test('narrative edits preserve authority hash', () {
    final original = parseTaskPlan('plan.md', taskPlanFixture());
    final edited = parseTaskPlan(
      'plan.md',
      taskPlanFixture().replaceFirst(
        'Prove task authority.',
        'Prove task authority with more context.',
      ),
    );

    expect(edited.authorityHash, original.authorityHash);
    expect(edited.sourceHash, isNot(original.sourceHash));
  });

  test('rejects duplicate authority metadata', () {
    expect(
      () => parseTaskPlan('plan.md', taskPlanFixture(extra: '**Risk:** low\n')),
      throwsA(_planError('plan.metadata-cardinality')),
    );
  });

  for (final path in [
    'docs/',
    '/tmp/outside',
    '../outside',
    'lib/features/*',
    '.git/config',
  ]) {
    test('rejects unsafe allowed path $path', () {
      expect(
        () => parseTaskPlan('plan.md', taskPlanFixture(allowedPaths: path)),
        throwsA(isA<TaskPlanError>()),
      );
    });
  }

  test('rejects duplicate and unsupported actions', () {
    expect(
      () => parseTaskPlan(
        'plan.md',
        taskPlanFixture(allowedActions: 'edit, edit'),
      ),
      throwsA(_planError('plan.list-duplicate')),
    );
    expect(
      () => parseTaskPlan(
        'plan.md',
        taskPlanFixture(allowedActions: 'edit, deploy'),
      ),
      throwsA(_planError('plan.action-invalid')),
    );
  });

  test('rejects declared risk above its human ceiling', () {
    expect(
      () => parseTaskPlan(
        'plan.md',
        taskPlanFixture(risk: 'high', maximumRisk: 'medium'),
      ),
      throwsA(_planError('plan.risk-above-maximum')),
    );
  });

  test('rejects missing narrative and impact authority', () {
    expect(
      () => parseTaskPlan(
        'plan.md',
        taskPlanFixture().replaceFirst('## Rollback', '## Recovery'),
      ),
      throwsA(_planError('plan.section-cardinality')),
    );
    expect(
      () => parseTaskPlan(
        'plan.md',
        taskPlanFixture(
          impacts: validImpactFixture.replaceFirst(
            '- Auth/session: no',
            '- Auth/session: maybe',
          ),
        ),
      ),
      throwsA(_planError('plan.impact-cardinality')),
    );
  });

  test('scope matching distinguishes exact files and directory prefixes', () {
    expect(
      findScopeViolations(
        ['exact.md', 'lib/features/a/file.dart', 'lib/core/file.dart'],
        ['exact.md', 'lib/features/a/'],
      ),
      ['lib/core/file.dart'],
    );
  });
}

Matcher _planError(String code) =>
    isA<TaskPlanError>().having((error) => error.code, 'code', code);
