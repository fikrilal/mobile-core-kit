import 'package:glob/glob.dart';
import 'package:mobile_core_kit_lints/src/restricted_imports.dart';
import 'package:test/test.dart';

void main() {
  group('RestrictedImportsConfig', () {
    test('uses defaults when options missing', () {
      final config = RestrictedImportsConfig.fromOptions(null);

      expect(
        config.firstViolation(
          sourcePath: 'lib/features/auth/data/repository/foo.dart',
          importUri: 'package:dio/dio.dart',
        ),
        isNotNull,
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/network/api/api_client.dart',
          importUri: 'package:dio/dio.dart',
        ),
        isNull,
      );
    });

    test('flags when import is not allowlisted', () {
      final config = RestrictedImportsConfig(
        include: [Glob('lib/**')],
        exclude: const [],
        rules: [
          RestrictedImportRule(
            uriPrefix: 'package:shared_preferences/shared_preferences.dart',
            allow: [Glob('lib/core/services/**')],
          ),
        ],
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/features/user/data/foo.dart',
          importUri: 'package:shared_preferences/shared_preferences.dart',
        ),
        isNotNull,
      );
    });

    test('does not flag when source path is allowlisted', () {
      final config = RestrictedImportsConfig(
        include: [Glob('lib/**')],
        exclude: const [],
        rules: [
          RestrictedImportRule(
            uriPrefix: 'dart:developer',
            allow: [Glob('lib/core/utilities/log_utils.dart')],
          ),
        ],
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/utilities/log_utils.dart',
          importUri: 'dart:developer',
        ),
        isNull,
      );
    });

    test('respects include/exclude filters', () {
      final config = RestrictedImportsConfig(
        include: [Glob('lib/**')],
        exclude: [Glob('lib/core/**')],
        rules: [
          RestrictedImportRule(
            uriPrefix: 'package:dio/dio.dart',
            allow: [Glob('lib/core/network/**')],
          ),
        ],
      );

      // Excluded: no violations reported even though rule would match.
      expect(
        config.isIncluded('lib/core/network/api/api_client.dart'),
        isFalse,
      );
      expect(
        config.firstViolation(
          sourcePath: 'lib/core/network/api/api_client.dart',
          importUri: 'package:dio/dio.dart',
        ),
        isNull,
      );

      // Included: violation is reported for disallowed source.
      expect(config.isIncluded('lib/features/auth/data/foo.dart'), isTrue);
      expect(
        config.firstViolation(
          sourcePath: 'lib/features/auth/data/foo.dart',
          importUri: 'package:dio/dio.dart',
        ),
        isNotNull,
      );
    });
  });
}
