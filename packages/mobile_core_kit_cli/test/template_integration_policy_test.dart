import 'dart:io';

import 'package:mobile_core_kit_cli/src/doctor/doctor.dart';
import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/template/template_customization_engine.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/environment_schema_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('enabled deep-link policy updates all managed surfaces', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));
    final protectedBefore = _protectedSnapshot(repository);

    final engine = _engine(
      repository,
      deepLinkMode: DeepLinkMode.enabled,
      deepLinkHost: 'links.example.app',
    );
    final plan = engine.buildPlan();

    expect(plan.hasConflicts, isFalse, reason: _conflicts(plan));
    expect(
      plan.summary.items,
      contains(
        isA<TemplatePlanItem>().having(
          (item) => item.target,
          'target',
          'Firebase',
        ),
      ),
    );
    expect(
      plan.summary.items
          .where((item) => item.target == 'Firebase')
          .single
          .description,
      contains('flutterfire configure'),
    );
    expect(
      plan.summary.items.map((item) => item.target),
      containsAll(<String>[
        'API endpoints',
        'OIDC client IDs',
        'signing',
        'CI secrets',
        'store metadata',
      ]),
    );

    final result = engine.apply(plan);
    expect(result.succeeded, isTrue, reason: result.message);

    expect(
      _read(repository, '.env/dev.example.yaml'),
      contains('  - links.example.app'),
    );
    expect(
      _read(repository, 'android/app/src/main/AndroidManifest.xml'),
      contains('android:host="links.example.app"'),
    );
    expect(
      _read(repository, 'ios/Runner/Runner.entitlements'),
      contains('<string>applinks:links.example.app</string>'),
    );
    expect(
      _read(
        repository,
        'test/core/runtime/navigation/deep_link_parser_test.dart',
      ),
      contains('links.example.app'),
    );
    expect(
      _read(repository, 'docs/template/deep_linking.md'),
      contains('links.example.app'),
    );
    expect(
      _read(repository, 'docs/template/deep_linking.md'),
      contains('Project policy'),
    );

    final protectedAfter = _protectedSnapshot(repository);
    expect(protectedAfter, protectedBefore);

    final manifest = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    expect(manifest.customization.environmentExamplesUpdated, isTrue);
    expect(manifest.customization.deepLinkHost, 'links.example.app');
  });

  test(
    'disabled deep-link policy removes claims and clears examples',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final protectedBefore = _protectedSnapshot(repository);

      final engine = _engine(repository, deepLinkMode: DeepLinkMode.disabled);
      final plan = engine.buildPlan();

      expect(plan.hasConflicts, isFalse, reason: _conflicts(plan));
      final result = engine.apply(plan);
      expect(result.succeeded, isTrue, reason: result.message);

      expect(
        _read(repository, '.env/dev.example.yaml'),
        contains('deepLinkAllowedHosts: []'),
      );
      final android = _read(
        repository,
        'android/app/src/main/AndroidManifest.xml',
      );
      expect(android, isNot(contains('android:autoVerify="true"')));
      expect(android, isNot(contains('links.fikril.dev')));

      final entitlements = _read(repository, 'ios/Runner/Runner.entitlements');
      expect(entitlements, isNot(contains('associated-domains')));
      expect(entitlements, isNot(contains('links.fikril.dev')));

      final fixture = _read(
        repository,
        'test/core/runtime/navigation/deep_link_parser_test.dart',
      );
      expect(fixture, isNot(contains('links.fikril.dev')));
      expect(fixture, contains('example.test'));
      final docs = _read(repository, 'docs/template/deep_linking.md');
      expect(docs, isNot(contains('links.fikril.dev')));
      expect(docs, contains('deep links are disabled'));

      expect(_protectedSnapshot(repository), protectedBefore);
    },
  );

  test('repeating integration customization is idempotent', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));
    final first = _engine(
      repository,
      deepLinkMode: DeepLinkMode.enabled,
      deepLinkHost: 'links.example.app',
    );
    expect(first.apply(first.buildPlan()).succeeded, isTrue);

    final existing = TemplateManifest.fromFile(
      File(p.join(repository.path, projectManifestRelativePath)),
    );
    final requested = _engine(
      repository,
      deepLinkMode: DeepLinkMode.enabled,
      deepLinkHost: 'links.example.app',
    );
    final second = TemplateCustomizationEngine(
      rootDirectory: repository,
      existingManifest: existing,
      nextManifest: requested.nextManifest,
    );
    final plan = second.buildPlan();

    expect(plan.hasConflicts, isFalse, reason: _conflicts(plan));
    expect(plan.hasChanges, isFalse);
  });

  test('keep-demo Firebase mode reports a production blocker', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final plan = _engine(
      repository,
      firebaseMode: FirebaseMode.keepDemo,
    ).buildPlan();
    final firebaseItem = plan.summary.items
        .where((item) => item.target == 'Firebase')
        .single;

    expect(firebaseItem.status, TemplatePlanStatus.external);
    expect(firebaseItem.description, contains('BLOCKING'));
    expect(firebaseItem.description, contains('demo project'));
  });

  test(
    'environment schema accepts disabled deep links and enforces manifest policy',
    () async {
      final repository = await Directory.systemTemp.createTemp(
        'mobilekit_environment_policy_test_',
      );
      addTearDown(() => repository.delete(recursive: true));
      _write(repository, '.env/dev.yaml', _environmentYaml(deepLinkHost: null));

      final output = StringBuffer();
      final errors = StringBuffer();
      final noManifestResult = await EnvironmentSchemaWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (_) async => 0,
          output: output,
          errorOutput: errors,
        ),
      ).run(['--env', 'dev']);
      expect(noManifestResult, 0, reason: errors.toString());

      Directory(
        p.join(repository.path, 'lib/core/foundation/config'),
      ).createSync(recursive: true);
      final generatedResult = await BuildConfigWorkflow(
        WorkflowContext(rootDirectory: repository, execute: (_) async => 0),
      ).run(['--env', 'dev']);
      expect(generatedResult, 0);
      expect(
        _read(
          repository,
          'lib/core/foundation/config/build_config_values.dart',
        ),
        contains('const List<String> _devDeepLinkAllowedHosts = [];'),
      );

      _writeManifest(
        repository,
        deepLinkMode: DeepLinkMode.disabled,
        deepLinkHost: null,
      );
      final disabledErrors = StringBuffer();
      final disabledResult = await EnvironmentSchemaWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (_) async => 0,
          errorOutput: disabledErrors,
        ),
      ).run(['--env', 'dev']);
      expect(disabledResult, 0, reason: disabledErrors.toString());

      _write(
        repository,
        '.env/dev.yaml',
        _environmentYaml(deepLinkHost: 'links.example.app'),
      );
      final staleErrors = StringBuffer();
      final staleResult = await EnvironmentSchemaWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (_) async => 0,
          errorOutput: staleErrors,
        ),
      ).run(['--env', 'dev']);
      expect(staleResult, 1);
      expect(
        staleErrors.toString(),
        contains('must be empty when deep links are disabled'),
      );

      _writeManifest(
        repository,
        deepLinkMode: DeepLinkMode.enabled,
        deepLinkHost: 'links.example.app',
      );
      final enabledErrors = StringBuffer();
      final enabledResult = await EnvironmentSchemaWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (_) async => 0,
          errorOutput: enabledErrors,
        ),
      ).run(['--env', 'dev']);
      expect(enabledResult, 0, reason: enabledErrors.toString());
    },
  );

  test('doctor marks keep-demo as a production blocker', () async {
    final repository = await Directory.systemTemp.createTemp(
      'mobilekit_doctor_integration_test_',
    );
    addTearDown(() => repository.delete(recursive: true));
    _write(repository, 'pubspec.yaml', 'name: mobile_core_kit\n');
    _write(
      repository,
      '.mobilekit/template.yaml',
      'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
    );
    _write(repository, '.fvmrc', '{"flutter":"3.41.4"}\n');
    _write(repository, 'firebase.json', '{"projectId":"mobile-kit-5f1d6"}\n');
    _write(repository, 'lib/firebase_options.dart', 'mobile-kit-5f1d6\n');
    _writeManifest(repository, firebaseMode: FirebaseMode.keepDemo);

    final pathDirectory = Directory(p.join(repository.path, 'bin'))
      ..createSync();
    for (final executable in ['dart', 'flutter', 'git', 'npx']) {
      File(p.join(pathDirectory.path, executable)).writeAsStringSync('');
    }
    final report = Doctor(
      executableFinder: ExecutableFinder(
        environment: {'PATH': pathDirectory.path},
        isWindows: false,
      ),
      platform: CommandPlatform.posix,
    ).inspect(startDirectory: repository);

    final firebaseCheck = report.checks
        .where((check) => check.label == 'Firebase policy')
        .single;
    expect(firebaseCheck.status, DoctorCheckStatus.error);
    expect(firebaseCheck.detail, contains('BLOCKING'));
  });
}

TemplateCustomizationEngine _engine(
  Directory repository, {
  DeepLinkMode deepLinkMode = DeepLinkMode.disabled,
  String? deepLinkHost,
  FirebaseMode firebaseMode = FirebaseMode.configure,
}) {
  const marker = TemplateMarker(
    schema: 1,
    template: supportedTemplateId,
    version: currentTemplateVersion,
  );
  final customization = TemplateCustomization.fromValues(
    repositorySlug: 'example-app',
    repositoryDescription: 'Example App',
    displayName: 'Example App',
    dartPackage: 'example_app',
    androidNamespace: TemplateCustomization.defaultAndroidNamespace,
    androidApplicationId: TemplateCustomization.defaultAndroidApplicationId,
    iosBundleId: TemplateCustomization.defaultIosBundleId,
    deepLinkMode: deepLinkMode,
    deepLinkHost: deepLinkHost,
    firebaseMode: firebaseMode,
  );
  return TemplateCustomizationEngine(
    rootDirectory: repository,
    nextManifest: TemplateManifest.forMarker(
      marker: marker,
      customization: customization,
    ),
  );
}

Future<Directory> _createRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobilekit_integration_policy_test_',
  );
  _write(
    repository,
    'pubspec.yaml',
    "name: mobile_core_kit\ndescription: 'A new Flutter project.'\n",
  );
  _write(repository, 'README.md', '# mobile-core-kit\n');
  _write(
    repository,
    '.mobilekit/template.yaml',
    'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
  );
  for (final env in ['dev', 'staging', 'prod']) {
    _write(
      repository,
      '.env/$env.example.yaml',
      _environmentYaml(deepLinkHost: TemplateCustomization.defaultDeepLinkHost),
    );
  }
  _write(
    repository,
    '.env/dev.yaml',
    _environmentYaml(deepLinkHost: TemplateCustomization.defaultDeepLinkHost),
  );
  _write(repository, 'android/app/build.gradle.kts', '''
android {
    namespace = "com.example.mobile_core_kit"
    defaultConfig {
        applicationId = "dev.fikril.mobile.corekit"
    }
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
        }
    }
}
''');
  _write(
    repository,
    'android/app/src/main/kotlin/com/example/mobile_core_kit/MainActivity.kt',
    'package com.example.mobile_core_kit\n',
  );
  _write(repository, 'android/app/src/main/AndroidManifest.xml', '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Mobile Core Kit"
        android:name="\${applicationName}">
        <activity android:name=".MainActivity">
            <!-- HTTPS App Links (allowlisted host + paths). -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https" android:host="links.fikril.dev" android:pathPrefix="/home" />
                <data android:scheme="https" android:host="links.fikril.dev" android:pathPrefix="/profile" />
            </intent-filter>
        </activity>
    </application>
</manifest>
''');
  _write(repository, 'ios/Runner/Info.plist', '''
<plist><dict>
<key>CFBundleDisplayName</key><string>Mobile Core Kit</string>
<key>CFBundleName</key><string>Mobile Core Kit</string>
</dict></plist>
''');
  _write(repository, 'ios/Runner/Runner.entitlements', '''
<plist><dict>
<key>com.apple.developer.associated-domains</key>
<array><string>applinks:links.fikril.dev</string></array>
</dict></plist>
''');
  _write(repository, 'ios/Runner.xcodeproj/project.pbxproj', _pbxProject());
  _write(
    repository,
    'test/core/runtime/navigation/deep_link_parser_test.dart',
    '''
final parserHost = 'links.fikril.dev';
final link = 'https://links.fikril.dev/profile';
''',
  );
  _write(repository, 'docs/template/deep_linking.md', '''
# Deep Linking

   - Android: `https://links.fikril.dev/.well-known/assetlinks.json`
   - iOS: `https://links.fikril.dev/.well-known/apple-app-site-association`
- External deep links support **HTTPS** for `links.fikril.dev` only (strict allowlist).
''');
  _write(
    repository,
    'android/app/google-services.json',
    'demo native config\n',
  );
  _write(
    repository,
    'ios/Runner/GoogleService-Info.plist',
    'demo native config\n',
  );
  _write(repository, 'lib/firebase_options.dart', 'mobile-kit-5f1d6\n');
  _write(repository, 'firebase.json', '{"projectId":"mobile-kit-5f1d6"}\n');
  return repository;
}

void _writeManifest(
  Directory repository, {
  DeepLinkMode deepLinkMode = DeepLinkMode.disabled,
  String? deepLinkHost,
  FirebaseMode firebaseMode = FirebaseMode.configure,
}) {
  const marker = TemplateMarker(
    schema: 1,
    template: supportedTemplateId,
    version: currentTemplateVersion,
  );
  final customization = TemplateCustomization.fromValues(
    repositorySlug: 'example-app',
    displayName: 'Example App',
    dartPackage: 'example_app',
    androidNamespace: TemplateCustomization.defaultAndroidNamespace,
    androidApplicationId: TemplateCustomization.defaultAndroidApplicationId,
    iosBundleId: TemplateCustomization.defaultIosBundleId,
    deepLinkMode: deepLinkMode,
    deepLinkHost: deepLinkHost,
    firebaseMode: firebaseMode,
  );
  TemplateManifest.forMarker(
    marker: marker,
    customization: customization,
  ).writeTo(File(p.join(repository.path, projectManifestRelativePath)));
}

String _environmentYaml({required String? deepLinkHost}) {
  final host = deepLinkHost == null
      ? 'deepLinkAllowedHosts: []'
      : 'deepLinkAllowedHosts:\n  - $deepLinkHost';
  return '''
core: https://core.example.com/v1
auth: https://auth.example.com/v1
profile: https://profile.example.com/v1
enableLogging: true
reminderExperiment: false
analyticsEnabledDefault: true
analyticsDebugLoggingEnabled: true
googleOidcServerClientId: client.example.com
netLogMode: full
netLogBodyLimitBytes: 8192
netLogLargeThresholdBytes: 65536
netLogSlowMs: 800
netLogRedact: true
$host
''';
}

Map<String, String> _protectedSnapshot(Directory repository) {
  const paths = [
    '.env/dev.yaml',
    'android/app/google-services.json',
    'ios/Runner/GoogleService-Info.plist',
    'lib/firebase_options.dart',
    'firebase.json',
  ];
  return {for (final path in paths) path: _read(repository, path)};
}

String _read(Directory root, String relativePath) {
  return File(p.join(root.path, relativePath)).readAsStringSync();
}

String _conflicts(TemplateCustomizationPlan plan) {
  return plan.summary.items
      .where((item) => item.status == TemplatePlanStatus.conflicted)
      .map((item) => '${item.target}: ${item.description}')
      .join('\n');
}

void _write(Directory root, String relativePath, String contents) {
  File(p.join(root.path, relativePath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(contents);
}

String _pbxProject() => '''
{
\tobjects = {
\t\tA00000000000000000000001 /* Runner */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = C00000000000000000000001 /* Runner configs */;
\t\t\tname = Runner;
\t\t};
\t\tA00000000000000000000002 /* RunnerTests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = C00000000000000000000002 /* Tests configs */;
\t\t\tname = RunnerTests;
\t\t};
\t\tC00000000000000000000001 /* Runner configs */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (B00000000000000000000001 /* Debug */);
\t\t};
\t\tC00000000000000000000002 /* Tests configs */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (B00000000000000000000002 /* Debug */);
\t\t};
\t\tB00000000000000000000001 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tB00000000000000000000002 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = dev.fikril.mobile.corekit.runnertests;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t};
}
''';
