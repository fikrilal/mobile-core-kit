import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/remove_feature_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:test/test.dart';

void main() {
  group('RemoveFeatureWorkflow', () {
    late Directory tempRoot;
    late StringBuffer outBuffer;
    late StringBuffer errBuffer;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('remove_feature_test_');
      outBuffer = StringBuffer();
      errBuffer = StringBuffer();
    });

    tearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    WorkflowContext createContext() {
      return WorkflowContext(
        rootDirectory: tempRoot,
        execute: (cmd) async => 0,
        output: outBuffer,
        errorOutput: errBuffer,
      );
    }

    void setupMockFeature(String feature) {
      // 1. Feature directories
      Directory(
        '${tempRoot.path}/lib/features/$feature',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/lib/features/$feature/dummy.dart',
      ).writeAsStringSync('// feature');

      Directory(
        '${tempRoot.path}/lib/navigation/$feature',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/lib/navigation/$feature/routes.dart',
      ).writeAsStringSync('// nav');

      Directory(
        '${tempRoot.path}/test/features/$feature',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/test/features/$feature/test.dart',
      ).writeAsStringSync('// test');

      Directory(
        '${tempRoot.path}/test/navigation/$feature',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/test/navigation/$feature/nav_test.dart',
      ).writeAsStringSync('// nav test');

      Directory('${tempRoot.path}/maestro').createSync(recursive: true);
      File(
        '${tempRoot.path}/maestro/$feature.yaml',
      ).writeAsStringSync('# flow');

      // 2. Registration files
      Directory('${tempRoot.path}/lib/navigation').createSync(recursive: true);
      File('${tempRoot.path}/lib/navigation/app_router.dart').writeAsStringSync(
        '''
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/navigation/$feature/${feature}_routes_list.dart';

final routes = [
  ...${feature}Routes,
];
''',
      );

      Directory(
        '${tempRoot.path}/lib/core/di/registrars',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/lib/core/di/registrars/feature_modules_registrar.dart',
      ).writeAsStringSync('''
import 'package:mobile_core_kit/features/$feature/di/${feature}_module.dart';

void registerFeatureModules(locator) {
  ReviewModule.register(locator);
}
''');

      Directory(
        '${tempRoot.path}/lib/features/home/presentation/pages',
      ).createSync(recursive: true);
      File(
        '${tempRoot.path}/lib/features/home/presentation/pages/home_page.dart',
      ).writeAsStringSync('''
import 'package:mobile_core_kit/navigation/$feature/${feature}_routes.dart';

Widget build() {
  return AppButton.primary(
    text: 'Demo',
    onPressed: () => context.push(ReviewRoutes.root),
  );
}
''');

      Directory('${tempRoot.path}/lint').createSync(recursive: true);
      File('${tempRoot.path}/lint/architecture_lints.yaml').writeAsStringSync(
        '''
rules:
  - id: features_no_cross_feature_imports
    exceptions:
      - from: lib/features/$feature/**
        allow:
          - lib/features/$feature/**
''',
      );

      Directory('${tempRoot.path}/harness').createSync(recursive: true);
      File('${tempRoot.path}/harness/oracles.yaml').writeAsStringSync('''
schemaVersion: 1
oracles:
  $feature.journey:
    kind: maestro-flow
    target: maestro/$feature.yaml
    covers: [ui]
''');

      Directory('${tempRoot.path}/lib/l10n').createSync(recursive: true);
      File('${tempRoot.path}/lib/l10n/app_en.arb').writeAsStringSync('''
{
  "appTitle": "App",
  "${feature}Title": "Review Title",
  "@${feature}Title": {
    "description": "desc"
  }
}
''');
    }

    test('help prints usage', () async {
      final workflow = RemoveFeatureWorkflow(createContext());
      final result = await workflow.run(['--help']);

      expect(result, 0);
      expect(outBuffer.toString(), contains('remove feature'));
      expect(outBuffer.toString(), contains('--dry-run'));
    });

    test('fails when feature name is missing', () async {
      final workflow = RemoveFeatureWorkflow(createContext());
      final result = await workflow.run([]);

      expect(result, 2);
      expect(errBuffer.toString(), contains('Missing required feature name'));
    });

    test('fails when feature name is not valid snake_case', () async {
      final workflow = RemoveFeatureWorkflow(createContext());
      final result = await workflow.run(['InvalidName']);

      expect(result, 2);
      expect(errBuffer.toString(), contains('Expected snake_case'));
    });

    test(
      'refuses to remove protected core feature without --force-core',
      () async {
        final workflow = RemoveFeatureWorkflow(createContext());
        final result = await workflow.run(['auth']);

        expect(result, 2);
        expect(
          errBuffer.toString(),
          contains('Refusing to remove protected core feature "auth"'),
        );
      },
    );

    test('dry-run reports planned deletions without touching disk', () async {
      setupMockFeature('review');
      final workflow = RemoveFeatureWorkflow(createContext());
      final result = await workflow.run(['review', '--dry-run']);

      expect(result, 0);
      final out = outBuffer.toString();
      expect(out, contains('Dry run: would remove feature "review"'));
      expect(out, contains('lib/features/review'));
      expect(out, contains('lib/navigation/review'));
      expect(out, contains('maestro/review.yaml'));
      expect(out, contains('app_router.dart'));
      expect(out, contains('feature_modules_registrar.dart'));
      expect(out, contains('architecture_lints.yaml'));
      expect(out, contains('oracles.yaml'));

      // Check that files are NOT deleted
      expect(
        Directory('${tempRoot.path}/lib/features/review').existsSync(),
        isTrue,
      );
      expect(File('${tempRoot.path}/maestro/review.yaml').existsSync(), isTrue);
    });

    test('successfully removes feature and unwires registrations', () async {
      setupMockFeature('review');
      final workflow = RemoveFeatureWorkflow(createContext());
      final result = await workflow.run(['review', '--yes']);

      expect(result, 0);
      expect(
        outBuffer.toString(),
        contains('Successfully removed feature "review"'),
      );

      // Directories and files should be deleted
      expect(
        Directory('${tempRoot.path}/lib/features/review').existsSync(),
        isFalse,
      );
      expect(
        Directory('${tempRoot.path}/lib/navigation/review').existsSync(),
        isFalse,
      );
      expect(
        Directory('${tempRoot.path}/test/features/review').existsSync(),
        isFalse,
      );
      expect(
        Directory('${tempRoot.path}/test/navigation/review').existsSync(),
        isFalse,
      );
      expect(
        File('${tempRoot.path}/maestro/review.yaml').existsSync(),
        isFalse,
      );

      // Registrations should be unwired
      final routerContent = File(
        '${tempRoot.path}/lib/navigation/app_router.dart',
      ).readAsStringSync();
      expect(routerContent, isNot(contains('review_routes_list.dart')));
      expect(routerContent, isNot(contains('...reviewRoutes')));

      final diContent = File(
        '${tempRoot.path}/lib/core/di/registrars/feature_modules_registrar.dart',
      ).readAsStringSync();
      expect(diContent, isNot(contains('review_module.dart')));
      expect(diContent, isNot(contains('ReviewModule.register')));

      final lintsContent = File(
        '${tempRoot.path}/lint/architecture_lints.yaml',
      ).readAsStringSync();
      expect(lintsContent, isNot(contains('lib/features/review/**')));

      final oraclesContent = File(
        '${tempRoot.path}/harness/oracles.yaml',
      ).readAsStringSync();
      expect(oraclesContent, isNot(contains('review.journey')));

      final arbContent = File(
        '${tempRoot.path}/lib/l10n/app_en.arb',
      ).readAsStringSync();
      expect(arbContent, isNot(contains('reviewTitle')));
      expect(arbContent, contains('appTitle'));
    });
  });
}
