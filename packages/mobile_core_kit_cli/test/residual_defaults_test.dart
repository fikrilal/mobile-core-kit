import 'dart:io';

import 'package:mobile_core_kit_cli/src/doctor/residual_defaults.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'classifies application defaults as blocking and docs as historical',
    () async {
      final repository = await Directory.systemTemp.createTemp(
        'mobilekit_residual_defaults_test_',
      );
      addTearDown(() => repository.delete(recursive: true));

      _write(
        repository,
        'lib/main.dart',
        "import 'package:mobile_core_kit/app.dart';\n",
      );
      _write(
        repository,
        'android/app/build.gradle.kts',
        'namespace = "com.example.mobile_core_kit"\n',
      );
      _write(repository, 'docs/engineering/example.md', 'Mobile Core Kit\n');

      final findings = ResidualDefaultScanner().scan(
        repository,
        _customization(),
      );

      expect(
        findings,
        contains(
          isA<ResidualDefaultFinding>()
              .having(
                (finding) => finding.marker,
                'marker',
                'template Dart package',
              )
              .having(
                (finding) => finding.severity,
                'severity',
                ResidualDefaultSeverity.blocking,
              ),
        ),
      );
      expect(
        findings,
        contains(
          isA<ResidualDefaultFinding>()
              .having(
                (finding) => finding.marker,
                'marker',
                'template display name',
              )
              .having(
                (finding) => finding.severity,
                'severity',
                ResidualDefaultSeverity.historical,
              ),
        ),
      );
    },
  );

  test(
    'marks production placeholders as blocking and examples as review-required',
    () async {
      final repository = await Directory.systemTemp.createTemp(
        'mobilekit_residual_environment_test_',
      );
      addTearDown(() => repository.delete(recursive: true));

      _write(
        repository,
        '.env/dev.example.yaml',
        'googleOidcServerClientId: <your-google-web-client-id>.apps.googleusercontent.com\n',
      );
      _write(
        repository,
        '.env/prod.yaml',
        'core: https://prod-core.example.com/api\n',
      );

      final findings = ResidualDefaultScanner().scan(
        repository,
        _customization(),
      );

      expect(
        findings,
        contains(
          isA<ResidualDefaultFinding>()
              .having(
                (finding) => finding.severity,
                'severity',
                ResidualDefaultSeverity.reviewRequired,
              )
              .having(
                (finding) => finding.marker,
                'marker',
                'placeholder environment value',
              ),
        ),
      );
      expect(
        findings,
        contains(
          isA<ResidualDefaultFinding>()
              .having(
                (finding) => finding.severity,
                'severity',
                ResidualDefaultSeverity.blocking,
              )
              .having(
                (finding) => finding.marker,
                'marker',
                'placeholder environment value',
              ),
        ),
      );
    },
  );
}

TemplateCustomization _customization({
  FirebaseMode firebaseMode = FirebaseMode.configure,
}) {
  return TemplateCustomization.fromValues(
    repositorySlug: 'example-app',
    displayName: 'Example App',
    dartPackage: 'example_app',
    androidNamespace: 'com.example.app',
    androidApplicationId: 'com.example.app',
    iosBundleId: 'com.example.app',
    firebaseMode: firebaseMode,
  );
}

void _write(Directory root, String relativePath, String contents) {
  File(p.join(root.path, relativePath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(contents);
}
