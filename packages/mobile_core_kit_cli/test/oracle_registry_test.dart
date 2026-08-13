import 'dart:io';

import 'package:mobile_core_kit_cli/src/oracle/oracle_registry.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test('validates registered impact-compatible plan oracles', () async {
    final root = await _fixture();
    addTearDown(() => root.delete(recursive: true));

    expect(
      () => OracleRegistry.load(
        root,
      ).validatePlan(parseTaskPlan('plan.md', taskPlanFixture())),
      returnsNormally,
    );
  });

  test('rejects unknown and incomplete plan oracle coverage', () async {
    final root = await _fixture();
    addTearDown(() => root.delete(recursive: true));
    final registry = OracleRegistry.load(root);

    expect(
      () => registry.validatePlan(
        parseTaskPlan('plan.md', taskPlanFixture(oracleIds: 'missing.oracle')),
      ),
      throwsA(_error('oracle.plan-unknown')),
    );
    expect(
      () => registry.validatePlan(
        parseTaskPlan('plan.md', taskPlanFixture(oracleIds: 'harness.full')),
      ),
      throwsA(_error('oracle.plan-coverage-missing')),
    );
  });

  test('rejects missing target and malformed registry', () async {
    final root = await _fixture();
    addTearDown(() => root.delete(recursive: true));
    File(p.join(root.path, 'docs', 'oracle.md')).deleteSync();

    expect(
      () => OracleRegistry.load(root),
      throwsA(_error('oracle.target-missing')),
    );
  });
}

Future<Directory> _fixture() async {
  final root = await Directory.systemTemp.createTemp('mobilekit_oracles_');
  File(p.join(root.path, 'docs', 'oracle.md'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('procedure\n');
  File(p.join(root.path, 'harness', 'oracles.yaml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('''
schemaVersion: 1
oracles:
  ui.human-review:
    kind: manual-review
    target: docs/oracle.md
    covers: [ui]
  harness.full:
    kind: verification-profile
    target: full
    covers: [harness]
''');
  return root;
}

Matcher _error(String code) =>
    isA<OracleRegistryError>().having((error) => error.code, 'code', code);
