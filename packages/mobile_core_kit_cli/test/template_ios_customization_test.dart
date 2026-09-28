import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_customization_engine.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'dry-run plans target-aware iOS identity and branding changes',
    () async {
      final repository = await _createIosRepository();
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
            'ios/Runner.xcodeproj/project.pbxproj',
          ),
        ),
      );
      expect(
        plan.summary.items,
        contains(
          isA<TemplatePlanItem>().having(
            (item) => item.target,
            'target',
            'ios/Runner/Info.plist',
          ),
        ),
      );
      expect(_snapshot(repository), before);
    },
  );

  test('apply updates Runner and RunnerTests independently', () async {
    final repository = await _createIosRepository();
    addTearDown(() => repository.delete(recursive: true));

    final engine = _engine(repository);
    final plan = engine.buildPlan();
    final result = engine.apply(plan);

    expect(
      result.outcome,
      TemplateLifecycleOutcome.applied,
      reason: result.message,
    );

    final project = File(
      p.join(repository.path, 'ios/Runner.xcodeproj/project.pbxproj'),
    ).readAsStringSync();
    expect(
      _count(project, 'PRODUCT_BUNDLE_IDENTIFIER = com.example.shopping;'),
      3,
    );
    expect(
      _count(
        project,
        'PRODUCT_BUNDLE_IDENTIFIER = com.example.shopping.runnertests;',
      ),
      3,
    );
    expect(
      project,
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.unrelated;'),
    );
    expect(project, contains('name = Runner;'));
    expect(project, contains('name = RunnerTests;'));
    expect(project, contains('CODE_SIGN_STYLE = Automatic;'));
    expect(project, contains('SWIFT_VERSION = 5.0;'));

    final infoPlist = File(
      p.join(repository.path, 'ios/Runner/Info.plist'),
    ).readAsStringSync();
    expect(infoPlist, contains('<string>Example Shopping</string>'));
    expect(infoPlist, isNot(contains('<string>Mobile Core Kit</string>')));

    final manifest = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    expect(
      manifest.managedFileFingerprints,
      contains('ios/Runner.xcodeproj/project.pbxproj'),
    );
    expect(manifest.managedFileFingerprints, contains('ios/Runner/Info.plist'));
    expect(
      engine.nextManifest.customization.iosTestBundleId,
      'com.example.shopping.runnertests',
    );
  });

  test('a user-edited target setting becomes an iOS conflict', () async {
    final repository = await _createIosRepository();
    addTearDown(() => repository.delete(recursive: true));
    final projectFile = File(
      p.join(repository.path, 'ios/Runner.xcodeproj/project.pbxproj'),
    );
    projectFile.writeAsStringSync(
      projectFile.readAsStringSync().replaceFirst(
        'PRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;',
        'PRODUCT_BUNDLE_IDENTIFIER = com.user.edited.tests;',
      ),
    );
    final before = _snapshot(repository);

    final engine = _engine(repository);
    final plan = engine.buildPlan();

    expect(plan.hasConflicts, isTrue);
    expect(
      plan.summary.items.any(
        (item) =>
            item.status == TemplatePlanStatus.conflicted &&
            item.target == 'ios/Runner.xcodeproj/project.pbxproj',
      ),
      isTrue,
    );
    expect(engine.apply(plan).outcome, TemplateLifecycleOutcome.failed);
    expect(_snapshot(repository), before);
  });

  test('iOS write failure restores project and plist files', () async {
    final repository = await _createIosRepository();
    addTearDown(() => repository.delete(recursive: true));
    final before = _snapshot(repository);
    final engine = _engine(repository);
    final plan = engine.buildPlan();
    var writes = 0;

    final result = engine.apply(
      plan,
      beforeWrite: (_) {
        writes++;
        if (writes == 2) throw StateError('injected iOS failure');
      },
    );

    expect(result.outcome, TemplateLifecycleOutcome.failed);
    expect(result.message, contains('rolled back'));
    expect(_snapshot(repository), before);
  });

  test('repeating iOS customization is idempotent', () async {
    final repository = await _createIosRepository();
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

  test('rejects an iOS test bundle ID equal to the app bundle ID', () {
    expect(
      () => TemplateCustomization.fromValues(
        repositorySlug: 'example-shopping',
        displayName: 'Example Shopping',
        dartPackage: 'example_app',
        androidNamespace: 'com.example.shopping',
        androidApplicationId: 'com.example.shopping',
        iosBundleId: 'com.example.shopping',
        iosTestBundleId: 'com.example.shopping',
      ),
      throwsA(isA<FormatException>()),
    );
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
    iosTestBundleId: 'com.example.shopping.runnertests',
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

Future<Directory> _createIosRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobilekit_ios_customization_test_',
  );
  _write(repository, 'pubspec.yaml', '''
name: example_app
description: 'Example Shopping'
''');
  _write(repository, 'ios/Runner/Info.plist', '''
<plist version="1.0">
<dict>
\t<key>CFBundleDisplayName</key>
\t<string>Mobile Core Kit</string>
\t<key>CFBundleName</key>
\t<string>Mobile Core Kit</string>
</dict>
</plist>
''');
  _write(
    repository,
    'ios/Runner.xcodeproj/project.pbxproj',
    _projectContents(),
  );
  return repository;
}

String _projectContents() => '''
// !\$*UTF8*\$!
{
\tobjects = {
\t\tA00000000000000000000001 /* Runner */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = C00000000000000000000001 /* Runner target configs */;
\t\t\tname = Runner;
\t\t\tproductName = Runner;
\t\t};
\t\tA00000000000000000000002 /* RunnerTests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = C00000000000000000000002 /* RunnerTests target configs */;
\t\t\tname = RunnerTests;
\t\t\tproductName = RunnerTests;
\t\t};
\t\tA00000000000000000000003 /* OtherTests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = C00000000000000000000003 /* Other target configs */;
\t\t\tname = OtherTests;
\t\t\tproductName = OtherTests;
\t\t};
\t\tC00000000000000000000001 /* Runner target configs */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tB00000000000000000000001 /* Debug */,
\t\t\t\tB00000000000000000000002 /* Release */,
\t\t\t\tB00000000000000000000003 /* Profile */,
\t\t\t);
\t\t};
\t\tC00000000000000000000002 /* RunnerTests target configs */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tB00000000000000000000004 /* Debug */,
\t\t\t\tB00000000000000000000005 /* Release */,
\t\t\t\tB00000000000000000000006 /* Profile */,
\t\t\t);
\t\t};
\t\tC00000000000000000000003 /* Other target configs */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tB00000000000000000000007 /* Debug */,
\t\t\t);
\t\t};
\t\tB00000000000000000000001 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tB00000000000000000000002 /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\tB00000000000000000000003 /* Profile */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Profile;
\t\t};
\t\tB00000000000000000000004 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tB00000000000000000000005 /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\tB00000000000000000000006 /* Profile */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Profile;
\t\t};
\t\tB00000000000000000000007 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.unrelated;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t};
}
''';

void _write(Directory root, String relativePath, String contents) {
  File(p.join(root.path, relativePath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(contents);
}

int _count(String value, String needle) => needle.allMatches(value).length;

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
