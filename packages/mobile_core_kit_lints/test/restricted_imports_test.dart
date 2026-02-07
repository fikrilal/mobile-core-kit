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
          sourcePath: 'lib/core/infra/network/api/api_client.dart',
          importUri: 'package:dio/dio.dart',
        ),
        isNull,
      );
    });

    test('defaults restrict firebase messaging to push wrappers and main', () {
      final config = RestrictedImportsConfig.fromOptions(null);

      expect(
        config.firstViolation(
          sourcePath: 'lib/features/auth/data/repository/foo.dart',
          importUri: 'package:firebase_messaging/firebase_messaging.dart',
        ),
        isNotNull,
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/platform/push/fcm_token_provider_impl.dart',
          importUri: 'package:firebase_messaging/firebase_messaging.dart',
        ),
        isNull,
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/main_dev.dart',
          importUri: 'package:firebase_messaging/firebase_messaging.dart',
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
            allow: [Glob('lib/core/infra/storage/prefs/**')],
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
            allow: [Glob('lib/core/foundation/utilities/log_utils.dart')],
          ),
        ],
      );

      expect(
        config.firstViolation(
          sourcePath: 'lib/core/foundation/utilities/log_utils.dart',
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
            allow: [Glob('lib/core/infra/network/**')],
          ),
        ],
      );

      // Excluded: no violations reported even though rule would match.
      expect(
        config.isIncluded('lib/core/infra/network/api/api_client.dart'),
        isFalse,
      );
      expect(
        config.firstViolation(
          sourcePath: 'lib/core/infra/network/api/api_client.dart',
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
