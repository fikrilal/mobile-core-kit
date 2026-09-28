import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_customization_engine.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'dry-run plans allowlisted identity and branding changes only',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final before = _snapshot(repository);

      final plan = _engine(repository).buildPlan();

      expect(plan.hasChanges, isTrue);
      expect(plan.hasConflicts, isFalse);
      expect(
        plan.summary.items,
        contains(
          isA<TemplatePlanItem>().having(
            (item) => item.status,
            'status',
            TemplatePlanStatus.external,
          ),
        ),
      );
      expect(
        plan.summary.items.any((item) => item.target == 'residual-defaults'),
        isTrue,
      );
      expect(_snapshot(repository), before);
    },
  );

  test(
    'apply updates application files and preserves pseudo markers',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));

      final engine = _engine(repository);
      final plan = engine.buildPlan();
      final result = engine.apply(plan);

      expect(
        result.outcome,
        TemplateLifecycleOutcome.applied,
        reason: result.message,
      );
      expect(
        File(p.join(repository.path, 'pubspec.yaml')).readAsStringSync(),
        contains('name: example_app'),
      );
      expect(
        File(p.join(repository.path, 'pubspec.yaml')).readAsStringSync(),
        contains("description: 'Example App'"),
      );
      expect(
        File(p.join(repository.path, 'lib', 'app.dart')).readAsStringSync(),
        contains("package:example_app/core.dart"),
      );
      expect(
        File(
          p.join(repository.path, 'test', 'app_test.dart'),
        ).readAsStringSync(),
        contains("package:example_app/core.dart"),
      );
      expect(
        File(
          p.join(repository.path, 'integration_test', 'app_test.dart'),
        ).readAsStringSync(),
        contains("package:example_app/core.dart"),
      );
      expect(
        File(
          p.join(
            repository.path,
            'packages',
            'mobile_core_kit_cli',
            'keep.dart',
          ),
        ).readAsStringSync(),
        contains("package:mobile_core_kit/core.dart"),
      );
      expect(
        File(
          p.join(repository.path, 'lib', 'l10n', 'app_en.arb'),
        ).readAsStringSync(),
        contains('"appTitle": "Example App"'),
      );
      final pseudo = File(
        p.join(repository.path, 'lib', 'l10n', 'app_en_XA.arb'),
      ).readAsStringSync();
      expect(pseudo, contains('"appTitle": "⟪'));
      expect(pseudo, contains('⟫"'));
      expect(pseudo, contains('Ḗẋåḿρŀḗ Åρρ'));
      expect(
        File(
          p.join(repository.path, 'lib', 'l10n', 'app_ar.arb'),
        ).readAsStringSync(),
        contains('"appTitle": "⟪RTL⟫ Example App"'),
      );
      expect(
        File(p.join(repository.path, 'README.md')).readAsStringSync(),
        startsWith('# example-app'),
      );

      final manifest = TemplateManifest.fromFile(
        File(p.join(repository.path, projectManifestRelativePath)),
      );
      expect(manifest.managedFileFingerprints, isNotEmpty);
      expect(manifest.managedFileFingerprints, contains('pubspec.yaml'));
    },
  );

  test('repeating the same customization is idempotent', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final firstEngine = _engine(repository);
    final firstPlan = firstEngine.buildPlan();
    expect(firstEngine.apply(firstPlan).succeeded, isTrue);

    final manifestFile = File(
      p.join(repository.path, projectManifestRelativePath),
    );
    final existing = TemplateManifest.fromFile(manifestFile);
    final secondEngine = TemplateCustomizationEngine(
      rootDirectory: repository,
      existingManifest: existing,
      nextManifest: existing,
    );
    final secondPlan = secondEngine.buildPlan();

    expect(secondPlan.hasConflicts, isFalse);
    expect(secondPlan.hasChanges, isFalse);
    expect(
      secondEngine.apply(secondPlan).outcome,
      TemplateLifecycleOutcome.skipped,
    );
  });

  test('managed-file edits become conflicts before any write', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final firstEngine = _engine(repository);
    expect(firstEngine.apply(firstEngine.buildPlan()).succeeded, isTrue);
    final editedFile = File(p.join(repository.path, 'lib', 'app.dart'))
      ..writeAsStringSync('// user edit\n');

    final existing = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    final changed = _engine(
      repository,
      existingManifest: existing,
      displayName: 'Changed App',
    );
    final plan = changed.buildPlan();

    expect(plan.hasConflicts, isTrue);
    expect(
      plan.summary.items.any(
        (item) =>
            item.status == TemplatePlanStatus.conflicted &&
            item.target == 'lib/app.dart',
      ),
      isTrue,
    );
    expect(changed.apply(plan).outcome, TemplateLifecycleOutcome.failed);
    expect(editedFile.readAsStringSync(), '// user edit\n');
  });

  test(
    'write failure restores every file changed before the failure',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final before = _snapshot(repository);
      final engine = _engine(repository);
      final plan = engine.buildPlan();
      var writes = 0;

      final result = engine.apply(
        plan,
        beforeWrite: (_) {
          writes++;
          if (writes == 2) throw StateError('injected failure');
        },
      );

      expect(result.outcome, TemplateLifecycleOutcome.failed);
      expect(result.message, contains('rolled back'));
      expect(_snapshot(repository), before);
      expect(
        File(p.join(repository.path, projectManifestRelativePath)).existsSync(),
        isFalse,
      );
    },
  );
}

TemplateCustomizationEngine _engine(
  Directory repository, {
  TemplateManifest? existingManifest,
  String displayName = 'Example App',
}) {
  final customization = TemplateCustomization.fromValues(
    repositorySlug: 'example-app',
    displayName: displayName,
    dartPackage: 'example_app',
    androidNamespace: 'com.example.app',
    androidApplicationId: 'com.example.app',
    iosBundleId: 'com.example.app',
  );
  final marker = const TemplateMarker(
    schema: 1,
    template: supportedTemplateId,
    version: currentTemplateVersion,
  );
  return TemplateCustomizationEngine(
    rootDirectory: repository,
    existingManifest: existingManifest,
    nextManifest: TemplateManifest.forMarker(
      marker: marker,
      customization: customization,
      managedFileFingerprints:
          existingManifest?.managedFileFingerprints ?? const {},
    ),
  );
}

Future<Directory> _createRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobilekit_customization_engine_test_',
  );
  _write(repository, 'pubspec.yaml', '''
name: mobile_core_kit
description: 'A new Flutter project.'
''');
  _write(repository, 'README.md', '# mobile-core-kit\n');
  _write(
    repository,
    'lib/app.dart',
    "import 'package:mobile_core_kit/core.dart';\n",
  );
  _write(
    repository,
    'test/app_test.dart',
    "import 'package:mobile_core_kit/core.dart';\n",
  );
  _write(
    repository,
    'integration_test/app_test.dart',
    "import 'package:mobile_core_kit/core.dart';\n",
  );
  _write(
    repository,
    'packages/mobile_core_kit_cli/keep.dart',
    "import 'package:mobile_core_kit/core.dart';\n",
  );
  _write(
    repository,
    'lib/l10n/app_en.arb',
    '{\n  "appTitle": "Mobile Core Kit"\n}\n',
  );
  _write(
    repository,
    'lib/l10n/app_id.arb',
    '{\n  "appTitle": "Mobile Core Kit"\n}\n',
  );
  _write(
    repository,
    'lib/l10n/app_en_XA.arb',
    '{\n  "appTitle": "⟪Ḿǿƀīŀḗ Ḉǿŗḗ Ḳīŧ⟫"\n}\n',
  );
  _write(
    repository,
    'lib/l10n/app_ar.arb',
    '{\n  "appTitle": "⟪RTL⟫ Mobile Core Kit"\n}\n',
  );
  _write(
    repository,
    'lib/l10n/app_ar_XB.arb',
    '{\n  "appTitle": "⟪RTL⟫ Mobile Core Kit"\n}\n',
  );
  _write(
    repository,
    'docs/history.md',
    'Historical package:mobile_core_kit/core.dart reference.\n',
  );
  return repository;
}

void _write(Directory root, String relativePath, String contents) {
  File(p.join(root.path, relativePath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(contents);
}

Map<String, String> _snapshot(Directory root) {
  final result = <String, String>{};
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && !entity.path.contains('.dart_tool')) {
      result[p.relative(entity.path, from: root.path)] = entity
          .readAsStringSync();
    }
  }
  return result;
}
