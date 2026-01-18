import 'package:mobile_core_kit_lints/src/architecture_imports.dart';
import 'package:test/test.dart';

void main() {
  group('ArchitectureImportsConfig', () {
    test('flags disallowed imports but honors exceptions', () {
      const yaml = '''
version: 1
package_name: mobile_core_kit
rules:
  - id: core_no_features
    reason: Core code must not import feature code.
    from: lib/core/**
    deny:
      - lib/features/**
    exceptions:
      - from: lib/core/di/**
        allow:
          - lib/features/*/di/**
''';

      final config = ArchitectureImportsConfig.tryParseYaml(
        yaml: yaml,
        fallbackPackageName: 'fallback_pkg',
      );
      expect(config, isNotNull);
      expect(config!.packageName, 'mobile_core_kit');

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/foo.dart',
          targetPath: 'lib/features/auth/domain/foo.dart',
        ),
        isNotNull,
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/di/app_module.dart',
          targetPath: 'lib/features/auth/di/auth_module.dart',
        ),
        isNull,
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/di/app_module.dart',
          targetPath: 'lib/features/auth/domain/foo.dart',
        ),
        isNotNull,
      );
    });

    test('uses fallback package name when missing', () {
      const yaml = '''
version: 1
rules: []
''';

      final config = ArchitectureImportsConfig.tryParseYaml(
        yaml: yaml,
        fallbackPackageName: 'fallback_pkg',
      );
      expect(config, isNotNull);
      expect(config!.packageName, 'fallback_pkg');
    });

    test('returns null when YAML is invalid', () {
      final config = ArchitectureImportsConfig.tryParseYaml(
        yaml: 'rules: [',
        fallbackPackageName: 'fallback_pkg',
      );
      expect(config, isNull);
    });
  });

  group('resolveImportToProjectRelativePath', () {
    test('returns lib-relative path for same-package imports', () {
      final resolved = resolveImportToProjectRelativePath(
        uri: 'package:mobile_core_kit/features/auth/di/auth_module.dart',
        sourceFileAbsolutePath: '/repo/lib/core/foo.dart',
        projectRoot: '/repo',
        packageName: 'mobile_core_kit',
      );
      expect(resolved, 'lib/features/auth/di/auth_module.dart');
    });

    test('returns null for other-package imports', () {
      final resolved = resolveImportToProjectRelativePath(
        uri: 'package:other_pkg/anything.dart',
        sourceFileAbsolutePath: '/repo/lib/core/foo.dart',
        projectRoot: '/repo',
        packageName: 'mobile_core_kit',
      );
      expect(resolved, isNull);
    });

    test('resolves relative imports against the source file', () {
      final resolved = resolveImportToProjectRelativePath(
        uri: '../features/auth/di/auth_module.dart',
        sourceFileAbsolutePath: '/repo/lib/core/foo.dart',
        projectRoot: '/repo',
        packageName: 'mobile_core_kit',
      );
      expect(resolved, 'lib/features/auth/di/auth_module.dart');
    });
  });
}
