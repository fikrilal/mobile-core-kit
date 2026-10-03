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
