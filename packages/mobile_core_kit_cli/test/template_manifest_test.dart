import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:test/test.dart';

void main() {
  test('parses and serializes a valid customization manifest', () {
    final customization = TemplateCustomization.fromYaml('''
schema: 1
template: mobile_core_kit
repository:
  slug: example-shopping-app
  description: Example Shopping
app:
  display_name: Example Shopping
  dart_package: example_shopping
platforms:
  android:
    namespace: com.example.shopping
    application_id: com.example.shopping
    flavor_suffixes:
      dev: .dev
      staging: .staging
  ios:
    bundle_id: com.example.shopping
deep_links:
  mode: disabled
firebase:
  mode: configure
environment:
  examples_updated: false
''');

    expect(customization.repositorySlug, 'example-shopping-app');
    expect(customization.dartPackage, 'example_shopping');
    expect(customization.androidDevApplicationId, 'com.example.shopping.dev');
    expect(
      customization.androidStagingApplicationId,
      'com.example.shopping.staging',
    );
    expect(
      customization.androidProductionApplicationId,
      'com.example.shopping',
    );
    expect(customization.iosTestBundleId, 'com.example.shopping.runnertests');
    expect(customization.deepLinkMode, DeepLinkMode.disabled);
    expect(customization.deepLinkHost, isNull);

    final manifest = TemplateManifest.forMarker(
      marker: const TemplateMarker(
        schema: 1,
        template: supportedTemplateId,
        version: currentTemplateVersion,
      ),
      customization: customization,
    );
    final roundTripped = TemplateManifest.fromYaml(manifest.toYaml());

    expect(roundTripped.template, supportedTemplateId);
    expect(roundTripped.templateVersion, currentTemplateVersion);
    expect(roundTripped.managedSurfaces, contains('application_package'));
    expect(
      roundTripped.customization.androidApplicationId,
      'com.example.shopping',
    );
  });

  test('derives a Dart package from a repository slug', () {
    final customization = TemplateCustomization.fromValues(
      repositorySlug: 'Example Shopping App',
      displayName: 'Example Shopping',
      androidNamespace: 'com.example.shopping',
      androidApplicationId: 'com.example.shopping',
      iosBundleId: 'com.example.shopping',
    );

    expect(customization.repositorySlug, 'example-shopping-app');
    expect(customization.dartPackage, 'example_shopping_app');
  });

  test('rejects an enabled deep link without a host', () {
    expect(
      () => TemplateCustomization.fromValues(
        repositorySlug: 'example-app',
        displayName: 'Example App',
        androidNamespace: 'com.example.app',
        androidApplicationId: 'com.example.app',
        iosBundleId: 'com.example.app',
        deepLinkMode: DeepLinkMode.enabled,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects secret-like input fields', () {
    expect(
      () => TemplateCustomization.fromYaml('''
schema: 1
repository:
  slug: example-app
app:
  display_name: Example App
platforms:
  android:
    namespace: com.example.app
    application_id: com.example.app
  ios:
    bundle_id: com.example.app
environment:
  api_key: should-not-be-accepted
'''),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unsupported schema versions', () {
    expect(
      () => TemplateCustomization.fromYaml('''
schema: 99
repository:
  slug: example-app
app:
  display_name: Example App
platforms:
  android:
    namespace: com.example.app
    application_id: com.example.app
  ios:
    bundle_id: com.example.app
'''),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unsupported runtime environment fields', () {
    expect(
      () => TemplateCustomization.fromYaml('''
schema: 1
repository:
  slug: example-app
app:
  display_name: Example App
platforms:
  android:
    namespace: com.example.app
    application_id: com.example.app
  ios:
    bundle_id: com.example.app
environment:
  api_hosts:
    dev: https://example.test
'''),
      throwsA(isA<FormatException>()),
    );
  });

  test('validates the template marker', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mobilekit_template_marker_test_',
    );
    addTearDown(() => directory.delete(recursive: true));

    final markerFile = File(directory.path + '/template.yaml')
      ..writeAsStringSync('''
schema: 1
template: mobile_core_kit
version: 2026-08-16
''');

    final marker = TemplateMarker.fromFile(markerFile);

    expect(marker.template, supportedTemplateId);
    expect(marker.version, currentTemplateVersion);
  });

  test('rejects unsupported or secret-like marker fields', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mobilekit_invalid_marker_test_',
    );
    addTearDown(() => directory.delete(recursive: true));

    final markerFile = File(directory.path + '/template.yaml')
      ..writeAsStringSync('''
schema: 1
template: mobile_core_kit
version: 2026-08-01
api_key: must-not-be-tracked
''');

    expect(
      () => TemplateMarker.fromFile(markerFile),
      throwsA(isA<FormatException>()),
    );
  });
}
