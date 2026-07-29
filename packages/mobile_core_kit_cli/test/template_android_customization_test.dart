import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_customization_engine.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'dry-run plans Android identity and package moves without writing',
    () async {
      final repository = await _createAndroidRepository();
      addTearDown(() => repository.delete(recursive: true));
      final before = _snapshot(repository);

      final plan = _engine(repository).buildPlan();

      expect(plan.hasChanges, isTrue);
      expect(plan.hasConflicts, isFalse);
      expect(
        plan.summary.items,
        contains(
          isA<TemplatePlanItem>().having(
            (item) => item.target,
            'target',
            'android/app/build.gradle.kts',
          ),
        ),
      );
      expect(
        plan.changes.map((change) => change.relativePath),
        containsAll(<String>[
          'android/app/src/main/kotlin/com/example/shopping/MainActivity.kt',
          'android/app/src/main/kotlin/com/example/mobile_core_kit/MainActivity.kt',
        ]),
      );
      expect(_snapshot(repository), before);
    },
  );

  test('apply updates Android IDs, label, and Kotlin package path', () async {
    final repository = await _createAndroidRepository();
    addTearDown(() => repository.delete(recursive: true));

    final engine = _engine(repository);
    final plan = engine.buildPlan();
    final result = engine.apply(plan);

    expect(
      result.outcome,
      TemplateLifecycleOutcome.applied,
      reason: result.message,
    );

    final gradle = File(
      p.join(repository.path, 'android/app/build.gradle.kts'),
    ).readAsStringSync();
    expect(gradle, contains('namespace = "com.example.shopping"'));
    expect(gradle, contains('applicationId = "com.example.shopping"'));
    expect(gradle, contains('applicationIdSuffix = ".dev"'));
    expect(gradle, contains('applicationIdSuffix = ".staging"'));
    expect(gradle, contains('versionNameSuffix = "-dev"'));
    expect(gradle, contains('versionNameSuffix = "-staging"'));
    expect(
      gradle,
      contains('signingConfig = signingConfigs.getByName("debug")'),
    );
    expect(gradle, contains('id("com.google.firebase.crashlytics")'));

    expect(
      File(
        p.join(repository.path, 'android/app/src/main/AndroidManifest.xml'),
      ).readAsStringSync(),
      contains('android:label="Example Shopping"'),
    );
    expect(
      File(
        p.join(
          repository.path,
          'android/app/src/main/kotlin/com/example/shopping/MainActivity.kt',
        ),
      ).readAsStringSync(),
      contains('package com.example.shopping'),
    );
    expect(
      File(
        p.join(
          repository.path,
          'android/app/src/main/kotlin/com/example/mobile_core_kit/MainActivity.kt',
        ),
      ).existsSync(),
      isFalse,
    );

    final manifest = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    expect(
      manifest.managedFileFingerprints,
      contains(
        'android/app/src/main/kotlin/com/example/shopping/MainActivity.kt',
      ),
    );
    expect(
      manifest.managedFileFingerprints,
      isNot(
        contains(
          'android/app/src/main/kotlin/com/example/mobile_core_kit/MainActivity.kt',
        ),
      ),
    );
    expect(
      _engine(repository).nextManifest.customization.androidDevApplicationId,
      'com.example.shopping.dev',
    );
    expect(
      _engine(
        repository,
      ).nextManifest.customization.androidStagingApplicationId,
      'com.example.shopping.staging',
    );
    expect(
      _engine(
        repository,
      ).nextManifest.customization.androidProductionApplicationId,
      'com.example.shopping',
    );
  });

  test('repeating Android customization is idempotent', () async {
    final repository = await _createAndroidRepository();
    addTearDown(() => repository.delete(recursive: true));

    final first = _engine(repository);
    expect(first.apply(first.buildPlan()).succeeded, isTrue);
    final existing = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    final second = _engine(repository, existingManifest: existing);
    final secondPlan = second.buildPlan();

    expect(secondPlan.hasConflicts, isFalse);
    expect(secondPlan.hasChanges, isFalse);
    expect(second.apply(secondPlan).outcome, TemplateLifecycleOutcome.skipped);
  });

  test(
    'destination package collisions are reported before any write',
    () async {
      final repository = await _createAndroidRepository();
      addTearDown(() => repository.delete(recursive: true));
      _write(
        repository,
        'android/app/src/main/kotlin/com/example/shopping/MainActivity.kt',
        'package user.owned\nclass MainActivity\n',
      );
      final before = _snapshot(repository);

      final engine = _engine(repository);
      final plan = engine.buildPlan();

      expect(plan.hasConflicts, isTrue);
      expect(
        plan.summary.items.any(
          (item) =>
              item.status == TemplatePlanStatus.conflicted &&
              item.target == 'android/app/src',
        ),
        isTrue,
      );
      expect(engine.apply(plan).outcome, TemplateLifecycleOutcome.failed);
      expect(_snapshot(repository), before);
    },
  );

  test('Android write failure restores Gradle and package files', () async {
    final repository = await _createAndroidRepository();
    addTearDown(() => repository.delete(recursive: true));
    final before = _snapshot(repository);
    final engine = _engine(repository);
    final plan = engine.buildPlan();
    var writes = 0;

    final result = engine.apply(
      plan,
      beforeWrite: (_) {
        writes++;
        if (writes == 2) throw StateError('injected Android failure');
      },
    );

    expect(result.outcome, TemplateLifecycleOutcome.failed);
    expect(result.message, contains('rolled back'));
    expect(_snapshot(repository), before);
  });
}

TemplateCustomizationEngine _engine(
  Directory repository, {
  TemplateManifest? existingManifest,
}) {
  final customization = TemplateCustomization.fromValues(
    repositorySlug: 'example-shopping',
    repositoryDescription: 'Example Shopping',
    displayName: 'Example Shopping',
    dartPackage: 'example_app',
    androidNamespace: 'com.example.shopping',
    androidApplicationId: 'com.example.shopping',
    iosBundleId: 'com.example.shopping',
    androidDevSuffix: '.dev',
    androidStagingSuffix: '.staging',
  );
  const marker = TemplateMarker(
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

Future<Directory> _createAndroidRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobilekit_android_customization_test_',
  );
  _write(repository, 'pubspec.yaml', '''
name: example_app
description: 'A new Flutter project.'
''');
  _write(repository, 'android/app/build.gradle.kts', '''
plugins {
    id("com.android.application")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.mobile_core_kit"

    defaultConfig {
        applicationId = "dev.fikril.mobile.corekit"
        minSdk = 24
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
        }
        create("prod") {
            dimension = "env"
        }
    }
}
''');
  _write(repository, 'android/app/src/main/AndroidManifest.xml', '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Mobile Core Kit"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity" android:exported="true" />
    </application>
</manifest>
''');
  _write(
    repository,
    'android/app/src/main/kotlin/com/example/mobile_core_kit/MainActivity.kt',
    '''
package com.example.mobile_core_kit

class MainActivity
''',
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
    if (entity is File) {
      result[p.relative(entity.path, from: root.path)] = entity
          .readAsStringSync();
    }
  }
  return result;
}
