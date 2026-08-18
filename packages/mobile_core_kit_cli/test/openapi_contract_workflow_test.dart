import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/contracts/openapi_contract_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('verifies a locked OpenAPI snapshot', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.delete(recursive: true));

    expect(await fixture.workflow.run(const ['verify']), 0);
    expect(fixture.output.toString(), contains('OpenAPI snapshot is valid'));
  });

  test('rejects snapshot drift and malformed lock data', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.delete(recursive: true));
    fixture.snapshot.writeAsStringSync('$_validOpenApi\n# changed\n');

    expect(await fixture.workflow.run(const ['verify']), 1);
    expect(fixture.errors.toString(), contains('contract.openapi-drift'));

    fixture.errors.clear();
    fixture.lock.writeAsStringSync('{"schemaVersion":1,"sourcePath":"/tmp"}');
    expect(await fixture.workflow.run(const ['verify']), 1);
    expect(
      fixture.errors.toString(),
      contains('contract.openapi-lock-invalid'),
    );
  });

  test(
    'explicit sync writes canonical path-free lock and is idempotent',
    () async {
      final fixture = await _fixture();
      addTearDown(() => fixture.root.delete(recursive: true));
      final external = File(p.join(fixture.root.path, 'incoming.yaml'))
        ..writeAsStringSync('$_validOpenApi\n# accepted\n');
      const revision = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

      expect(
        await fixture.workflow.run([
          'sync',
          '--source',
          external.path,
          '--source-revision',
          revision,
          '--accept',
        ]),
        0,
      );
      final firstLock = fixture.lock.readAsStringSync();
      expect(firstLock, isNot(contains(external.path)));
      expect(firstLock, isNot(contains(fixture.root.path)));
      expect(jsonDecode(firstLock)['sourceRevision'], revision);

      fixture.output.clear();
      expect(
        await fixture.workflow.run([
          'sync',
          '--source',
          external.path,
          '--source-revision',
          revision,
          '--accept',
        ]),
        0,
      );
      expect(fixture.lock.readAsStringSync(), firstLock);
      expect(fixture.output.toString(), contains('already current'));
    },
  );

  test(
    'sync validates before writing and requires explicit acceptance',
    () async {
      final fixture = await _fixture();
      addTearDown(() => fixture.root.delete(recursive: true));
      final before = fixture.snapshot.readAsBytesSync();
      final invalid = File(p.join(fixture.root.path, 'invalid.yaml'))
        ..writeAsStringSync('not: openapi\n');

      expect(
        () => fixture.workflow.run([
          'sync',
          '--source',
          invalid.path,
          '--source-revision',
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        ]),
        throwsA(isA<FormatException>()),
      );
      expect(fixture.snapshot.readAsBytesSync(), before);

      expect(
        await fixture.workflow.run([
          'sync',
          '--source',
          invalid.path,
          '--source-revision',
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          '--accept',
        ]),
        1,
      );
      expect(fixture.snapshot.readAsBytesSync(), before);
    },
  );
}

Future<_Fixture> _fixture() async {
  final root = await Directory.systemTemp.createTemp('mobilekit_openapi_');
  final snapshot = File(p.join(root.path, openApiSnapshotPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(_validOpenApi);
  final digest = sha256.convert(snapshot.readAsBytesSync()).toString();
  final lock = File(p.join(root.path, openApiLockPath))
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({'schemaVersion': 1, 'artifact': openApiSnapshotPath, 'sha256': digest, 'sourceRevision': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'})}\n',
    );
  final output = StringBuffer();
  final errors = StringBuffer();
  final context = WorkflowContext(
    rootDirectory: root,
    execute: (_) async => 0,
    output: output,
    errorOutput: errors,
  );
  return _Fixture(
    root: root,
    snapshot: snapshot,
    lock: lock,
    output: output,
    errors: errors,
    workflow: OpenApiContractWorkflow(context),
  );
}

class _Fixture {
  const _Fixture({
    required this.root,
    required this.snapshot,
    required this.lock,
    required this.output,
    required this.errors,
    required this.workflow,
  });

  final Directory root;
  final File snapshot;
  final File lock;
  final StringBuffer output;
  final StringBuffer errors;
  final OpenApiContractWorkflow workflow;
}

const _validOpenApi = '''
openapi: 3.0.0
info:
  title: Fixture
  version: 1.0.0
paths: {}
''';
