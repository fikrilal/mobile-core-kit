import 'dart:io';

/// Result of unwiring a feature from registration files.
class UnwiringChange {
  const UnwiringChange({
    required this.filePath,
    required this.description,
    required this.hasChanges,
  });

  final String filePath;
  final String description;
  final bool hasChanges;
}

/// Unwires a feature from the repository's known registration points:
/// 1. `lib/navigation/app_router.dart`
/// 2. `lib/core/di/registrars/feature_modules_registrar.dart`
/// 3. `lib/features/home/presentation/pages/home_page.dart`
/// 4. `lint/architecture_lints.yaml`
/// 5. `harness/oracles.yaml`
class FeatureUnwiringEngine {
  const FeatureUnwiringEngine();

  /// Inspects or modifies registration points for a specific [subfeature] of [feature].
  List<UnwiringChange> unwireSubfeature(
    Directory rootDirectory, {
    required String feature,
    required String subfeature,
    bool dryRun = false,
  }) {
    final changes = <UnwiringChange>[];

    // 1. Feature module DI (e.g. lib/features/auth/di/auth_module.dart)
    final moduleFile = File(
      '${rootDirectory.path}/lib/features/$feature/di/${feature}_module.dart',
    );
    if (moduleFile.existsSync()) {
      changes.add(
        _unwireSubfeatureDi(
          moduleFile,
          feature: feature,
          subfeature: subfeature,
          dryRun: dryRun,
        ),
      );
    }

    // 2. Navigation routes list (e.g. lib/navigation/auth/auth_routes_list.dart)
    final navFile = File(
      '${rootDirectory.path}/lib/navigation/$feature/${feature}_routes_list.dart',
    );
    if (navFile.existsSync()) {
      changes.add(
        _unwireSubfeatureNav(
          navFile,
          feature: feature,
          subfeature: subfeature,
          dryRun: dryRun,
        ),
      );
    }

    // 3. Maestro flow
    final maestroFile = File('${rootDirectory.path}/maestro/$subfeature.yaml');
    if (maestroFile.existsSync()) {
      changes.add(_unwireLiveTest(maestroFile, dryRun: dryRun));
    }

    return changes;
  }

  UnwiringChange _unwireSubfeatureDi(
    File file, {
    required String feature,
    required String subfeature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();
    final subfeaturePascal = _toPascalCase(subfeature);

    // Remove imports referencing subfeature
    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*features/' +
          RegExp.escape(feature) +
          '/subfeatures/' +
          RegExp.escape(subfeature) +
          '/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    // Remove cubit/state registration blocks
    final cubitRegex = RegExp(
      r'^\s*if\s*\(!getIt\.isRegistered<[^\>]*' +
          RegExp.escape(subfeaturePascal) +
          r'[^\>]*>\(\)\)\s*\{\s*getIt\.registerFactory<[^\>]*>\(\s*\(\)\s*=>\s*[a-zA-Z0-9_]+\([^\)]*\),\s*\);\s*\}\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(cubitRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove DI registration for subfeature "$subfeature"',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireSubfeatureNav(
    File file, {
    required String feature,
    required bool dryRun,
    required String subfeature,
  }) {
    final content = file.readAsStringSync();
    final subfeaturePascal = _toPascalCase(subfeature);

    // Remove imports referencing subfeature
    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*features/' +
          RegExp.escape(feature) +
          '/subfeatures/' +
          RegExp.escape(subfeature) +
          '/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    // Remove GoRoute block referencing this subfeature
    final goRouteRegex = RegExp(
      r'^\s*GoRoute\(\s*(?:(?!GoRoute\()[\s\S])*?' +
          RegExp.escape(subfeaturePascal) +
          r'(?:Page|Cubit)[\s\S]*?\),\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(goRouteRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove GoRoute entry for subfeature "$subfeature"',
      hasChanges: hasChanges,
    );
  }

  /// Inspects or modifies all known registration points for [feature] (snake_case).
  ///
  /// If [dryRun] is true, files are read but not modified on disk.
  List<UnwiringChange> unwireFeature(
    Directory rootDirectory, {
    required String feature,
    bool dryRun = false,
  }) {
    final changes = <UnwiringChange>[];

    // 1. app_router.dart
    final routerFile = File(
      '${rootDirectory.path}/lib/navigation/app_router.dart',
    );
    if (routerFile.existsSync()) {
      changes.add(_unwireRouter(routerFile, feature: feature, dryRun: dryRun));
    }

    // 2. feature_modules_registrar.dart
    final diFile = File(
      '${rootDirectory.path}/lib/core/di/registrars/feature_modules_registrar.dart',
    );
    if (diFile.existsSync()) {
      changes.add(_unwireDiRegistrar(diFile, feature: feature, dryRun: dryRun));
    }

    // 3. home_page.dart
    final homeFile = File(
      '${rootDirectory.path}/lib/features/home/presentation/pages/home_page.dart',
    );
    if (homeFile.existsSync()) {
      changes.add(_unwireHomePage(homeFile, feature: feature, dryRun: dryRun));
    }

    // 4. architecture_lints.yaml
    final archLintsFile = File(
      '${rootDirectory.path}/lint/architecture_lints.yaml',
    );
    if (archLintsFile.existsSync()) {
      changes.add(
        _unwireArchitectureLints(
          archLintsFile,
          feature: feature,
          dryRun: dryRun,
        ),
      );
    }

    // 5. oracles.yaml
    final oraclesFile = File('${rootDirectory.path}/harness/oracles.yaml');
    if (oraclesFile.existsSync()) {
      changes.add(
        _unwireOracles(oraclesFile, feature: feature, dryRun: dryRun),
      );
    }

    // 6. registrars_smoke_test.dart
    final smokeTestFile = File(
      '${rootDirectory.path}/test/core/di/registrars/registrars_smoke_test.dart',
    );
    if (smokeTestFile.existsSync()) {
      changes.add(
        _unwireSmokeTest(smokeTestFile, feature: feature, dryRun: dryRun),
      );
    }

    // 7. Live integration test file (if exists, e.g. integration_test/<feature>_live_test.dart)
    final liveTestFile = File(
      '${rootDirectory.path}/integration_test/${feature}_live_test.dart',
    );
    if (liveTestFile.existsSync()) {
      changes.add(_unwireLiveTest(liveTestFile, dryRun: dryRun));
    }

    // 8. home_page_test.dart
    final homePageTestFile = File(
      '${rootDirectory.path}/test/features/home/home_page_test.dart',
    );
    if (homePageTestFile.existsSync()) {
      changes.add(
        _unwireHomePageTest(homePageTestFile, feature: feature, dryRun: dryRun),
      );
    }

    return changes;
  }

  UnwiringChange _unwireRouter(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();
    final featureCamel = _toCamelCase(feature);

    // Remove import lines referencing the feature's navigation or presentation
    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*navigation/' +
          RegExp.escape(feature) +
          '/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    // Remove route list injection: e.g. `...merchantOnboardingRoutes,`
    final routeListRegex = RegExp(
      r'^\s*\.\.\.' + RegExp.escape(featureCamel) + r'Routes,\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(routeListRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove route list and import for "$feature"',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireDiRegistrar(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();
    final featurePascal = _toPascalCase(feature);

    // Remove import lines referencing the feature DI
    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*features/' +
          RegExp.escape(feature) +
          '/di/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    // Remove Module.register(locator); call
    final callRegex = RegExp(
      r'^\s*' +
          RegExp.escape(featurePascal) +
          r'Module\.register\([^\)]*\);\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(callRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove DI registration and import for "$feature"',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireHomePage(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();
    final featurePascal = _toPascalCase(feature);

    // Remove imports for the feature routes or pages
    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*(?:navigation|features)/' +
          RegExp.escape(feature) +
          '/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    // Remove AppButton blocks that push to this feature's routes
    // e.g.:
    // AppButton.primary(
    //   ...
    //   onPressed: () => context.push(MerchantOnboardingRoutes.root),
    // ),
    final buttonBlockRegex = RegExp(
      r'(?:const\s+SizedBox\(height:\s+AppSpacing\.[^\)]+\),\s*)?'
              r'AppButton\.[a-zA-Z]+\(\s*'
              r'(?:(?!AppButton\.)[\s\S])*?' +
          RegExp.escape(featurePascal) +
          r'Routes\.[a-zA-Z]+\s*\),\s*\),?\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(buttonBlockRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove entrypoint navigation trigger from HomePage',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireArchitectureLints(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();

    // In architecture_lints.yaml, exception blocks under features_no_cross_feature_imports look like:
    //       - from: lib/features/<feature>/**
    //         allow:
    //           - lib/features/<feature>/**
    final yamlBlockRegex = RegExp(
      r'^\s*-\s+from:\s+lib/features/' +
          RegExp.escape(feature) +
          r'/\*\*\r?\n\s+allow:\r?\n(?:\s+-\s+lib/features/[^\r\n]+\r?\n)+',
      multiLine: true,
    );

    final updated = content.replaceAll(yamlBlockRegex, '');
    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove architecture lint exception block',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireOracles(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();

    // In oracles.yaml, oracle blocks look like:
    //   merchant.onboarding-journey:
    //     kind: maestro-flow
    //     target: maestro/merchant_onboarding.yaml
    //     covers: [auth, ui]
    //     ...
    // Match any oracle block whose target references the feature or maestro flow
    final oracleBlockRegex = RegExp(
      r'^\s*[a-zA-Z0-9_\-\.]+:\r?\n'
              r'(?:[ \t]+[^\r\n]+\r?\n)*?'
              r'[ \t]+target:\s+(?:maestro/' +
          RegExp.escape(feature) +
          r'\.yaml|(?:test|lib)/features/' +
          RegExp.escape(feature) +
          r'/[^\r\n]+)\r?\n'
              r'(?:[ \t]+(?:covers|logSignals|id|contains):[^\r\n]*\r?\n)*'
              r'(?:[ \t]+-[^\r\n]*\r?\n)*',
      multiLine: true,
    );

    final updated = content.replaceAll(oracleBlockRegex, '');
    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove behavioral oracle registration',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireLiveTest(File file, {required bool dryRun}) {
    final hasFile = file.existsSync();
    if (!dryRun && hasFile) {
      file.deleteSync();
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Delete integration test file',
      hasChanges: hasFile,
    );
  }

  UnwiringChange _unwireSmokeTest(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();
    final featurePascal = _toPascalCase(feature);

    final importRegex = RegExp(
      '^import\\s+[\'"][^\'"]*features/' +
          RegExp.escape(feature) +
          '/[^\'"]*[\'"];\\r?\\n',
      multiLine: true,
    );

    final expectRegex = RegExp(
      r'^\s*expect\(locator\.isRegistered<[^\>]*' +
          RegExp.escape(featurePascal) +
          r'[^\>]*>\(\),\s*isTrue\);\r?\n',
      multiLine: true,
    );

    var updated = content.replaceAll(importRegex, '');
    updated = updated.replaceAll(expectRegex, '');

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove DI smoke test assertions and imports',
      hasChanges: hasChanges,
    );
  }

  UnwiringChange _unwireHomePageTest(
    File file, {
    required String feature,
    required bool dryRun,
  }) {
    final content = file.readAsStringSync();

    final featureCamel = _toCamelCase(feature);
    final expectRegex = RegExp(
      r'^\s*expect\(find\.text\([^\)]*' +
          RegExp.escape(featureCamel) +
          r'[^\)]*\),\s*findsOneWidget\);\r?\n',
      multiLine: true,
      caseSensitive: false,
    );
    final literalExpectRegex = RegExp(
      r'^\s*expect\(find\.text\([^\)]*merchant[^\)]*\),\s*findsOneWidget\);\r?\n',
      multiLine: true,
      caseSensitive: false,
    );

    var updated = content.replaceAll(expectRegex, '');
    if (feature == 'merchant_onboarding') {
      updated = updated.replaceAll(literalExpectRegex, '');
    }

    final hasChanges = updated != content;
    if (hasChanges && !dryRun) {
      file.writeAsStringSync(updated);
    }

    return UnwiringChange(
      filePath: file.path,
      description: 'Remove HomePage test assertion for "$feature"',
      hasChanges: hasChanges,
    );
  }

  static String _toPascalCase(String snake) {
    final parts = snake.split('_').where((p) => p.isNotEmpty);
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  static String _toCamelCase(String snake) {
    final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first;
    final rest = parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1));
    return [first, ...rest].join();
  }
}
