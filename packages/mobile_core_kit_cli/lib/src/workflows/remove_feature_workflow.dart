import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/workflows/arb_key_pruner.dart';
import 'package:mobile_core_kit_cli/src/workflows/feature_unwiring_engine.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

/// Foundational features that cannot be removed without --force-core.
const protectedCoreFeatures = <String>{'auth', 'account', 'home', 'onboarding'};

class RemoveFeatureWorkflow {
  const RemoveFeatureWorkflow(
    this.context, {
    this.unwiringEngine = const FeatureUnwiringEngine(),
    this.arbPruner = const ArbKeyPruner(),
  });

  final WorkflowContext context;
  final FeatureUnwiringEngine unwiringEngine;
  final ArbKeyPruner arbPruner;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Preview removals without deleting files or modifying code.',
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        negatable: false,
        help: 'Confirm deletion without interactive prompt.',
      )
      ..addFlag(
        'keep-l10n',
        negatable: false,
        help: 'Do not prune keys from lib/l10n/*.arb files.',
      )
      ..addFlag(
        'force-core',
        negatable: false,
        help:
            'Allow removal of protected core features (${protectedCoreFeatures.join(', ')}).',
      )
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature name (snake_case), e.g. "merchant_onboarding".',
      )
      ..addOption(
        'subfeature',
        abbr: 's',
        help:
            'Optional subfeature/slice name (e.g. "sign_in", "registration", "password_recovery").',
      );

    final args = parser.parse(argv);
    if (args.flag('help')) {
      context.output.writeln(
        [
          'remove feature',
          '',
          'Completely unwires and removes a feature slice from the codebase end-to-end.',
          '',
          'Usage:',
          '  mobilekit remove feature <name> [options]',
          '',
          'Options:',
          parser.usage,
        ].join('\n'),
      );
      return 0;
    }

    final dryRun = args.flag('dry-run');
    final keepL10n = args.flag('keep-l10n');
    final forceCore = args.flag('force-core');
    final subfeature = (args.option('subfeature') ?? '').trim();

    var feature = (args.option('feature') ?? '').trim();
    if (feature.isEmpty && args.rest.isNotEmpty) {
      feature = args.rest.first.trim();
    }

    if (feature.isEmpty) {
      context.errorOutput.writeln('Missing required feature name.');
      context.errorOutput.writeln('');
      context.errorOutput.writeln(
        'Usage: mobilekit remove feature <name> [options]',
      );
      context.errorOutput.writeln(
        'Example: mobilekit remove feature merchant_onboarding',
      );
      return 2;
    }

    if (!_isValidSnakeCase(feature)) {
      context.errorOutput.writeln(
        'Invalid feature name "$feature". Expected snake_case.',
      );
      context.errorOutput.writeln(
        'Example: merchant_onboarding, review, payment_methods',
      );
      return 2;
    }

    if (protectedCoreFeatures.contains(feature) &&
        !forceCore &&
        subfeature.isEmpty) {
      context.errorOutput.writeln(
        'Refusing to remove protected core feature "$feature".',
      );
      context.errorOutput.writeln(
        'Protected features: ${protectedCoreFeatures.join(', ')}.',
      );
      context.errorOutput.writeln(
        'If you really intend to remove this entire feature, pass --force-core.',
      );
      return 2;
    }

    final rootDir = context.rootDirectory;
    final isSubfeature = subfeature.isNotEmpty;

    final directoriesToDelete = <String>[];
    final filesToDelete = <String>[];

    if (isSubfeature) {
      final subfeatureDir = p.join(
        'lib',
        'features',
        feature,
        'subfeatures',
        subfeature,
      );
      final testSubfeatureDir = p.join(
        'test',
        'features',
        feature,
        'subfeatures',
        subfeature,
      );
      final maestroFile = p.join('maestro', '$subfeature.yaml');

      if (context.directory(subfeatureDir).existsSync()) {
        directoriesToDelete.add(subfeatureDir);
      }
      if (context.directory(testSubfeatureDir).existsSync()) {
        directoriesToDelete.add(testSubfeatureDir);
      }
      if (context.file(maestroFile).existsSync()) {
        filesToDelete.add(maestroFile);
      }

      if (directoriesToDelete.isEmpty && filesToDelete.isEmpty) {
        context.errorOutput.writeln(
          'Subfeature "$subfeature" does not exist under $subfeatureDir.',
        );
        return 2;
      }
    } else {
      final featureDir = p.join('lib', 'features', feature);
      final navDir = p.join('lib', 'navigation', feature);
      final testFeatureDir = p.join('test', 'features', feature);
      final testNavDir = p.join('test', 'navigation', feature);
      final maestroFile = p.join('maestro', '$feature.yaml');

      for (final dir in [featureDir, navDir, testFeatureDir, testNavDir]) {
        if (context.directory(dir).existsSync()) {
          directoriesToDelete.add(dir);
        }
      }

      if (context.file(maestroFile).existsSync()) {
        filesToDelete.add(maestroFile);
      }

      if (directoriesToDelete.isEmpty && filesToDelete.isEmpty) {
        context.errorOutput.writeln(
          'Feature "$feature" does not exist under lib/features/$feature.',
        );
        return 2;
      }
    }

    // Inspect unwiring points
    final unwiringChanges = isSubfeature
        ? unwiringEngine.unwireSubfeature(
            rootDir,
            feature: feature,
            subfeature: subfeature,
            dryRun: true,
          )
        : unwiringEngine.unwireFeature(rootDir, feature: feature, dryRun: true);

    // Inspect ARB keys
    final targetPrefix = isSubfeature
        ? _toCamelCase(subfeature)
        : _toCamelCase(feature);
    final arbDir = context.directory('lib/l10n');
    final arbResults = keepL10n
        ? const <ArbPruneResult>[]
        : arbPruner.pruneDirectory(arbDir, prefix: targetPrefix, dryRun: true);

    final totalPrunedKeys = arbResults.fold<int>(
      0,
      (sum, item) => sum + item.prunedKeysCount,
    );

    final targetLabel = isSubfeature
        ? 'subfeature "$subfeature" from feature "$feature"'
        : 'feature "$feature"';

    if (dryRun) {
      context.output.writeln('Dry run: would remove $targetLabel end-to-end.');
      context.output.writeln('');
      context.output.writeln('Directories to delete:');
      for (final dir in directoriesToDelete) {
        context.output.writeln('- $dir');
      }
      if (filesToDelete.isNotEmpty) {
        context.output.writeln('');
        context.output.writeln('Files to delete:');
        for (final file in filesToDelete) {
          context.output.writeln('- $file');
        }
      }

      final activeUnwiring = unwiringChanges
          .where((c) => c.hasChanges)
          .toList();
      if (activeUnwiring.isNotEmpty) {
        context.output.writeln('');
        context.output.writeln('Registrations to unwire:');
        for (final change in activeUnwiring) {
          final relPath = p.relative(change.filePath, from: rootDir.path);
          context.output.writeln('- $relPath (${change.description})');
        }
      }

      if (!keepL10n && totalPrunedKeys > 0) {
        context.output.writeln('');
        context.output.writeln('Localization keys to prune:');
        context.output.writeln(
          '- $totalPrunedKeys keys across ${arbResults.length} ARB files with prefix "$targetPrefix"',
        );
      }

      context.output.writeln('');
      context.output.writeln('Run without --dry-run to apply this removal.');
      return 0;
    }

    // Execute unwiring
    if (isSubfeature) {
      unwiringEngine.unwireSubfeature(
        rootDir,
        feature: feature,
        subfeature: subfeature,
        dryRun: false,
      );
    } else {
      unwiringEngine.unwireFeature(rootDir, feature: feature, dryRun: false);
    }

    // Execute directory and file deletions
    for (final file in filesToDelete) {
      context.file(file).deleteSync();
    }
    for (final dir in directoriesToDelete) {
      context.directory(dir).deleteSync(recursive: true);
    }

    // Execute ARB pruning
    if (!keepL10n && arbResults.isNotEmpty) {
      arbPruner.pruneDirectory(arbDir, prefix: targetPrefix, dryRun: false);
    }

    context.output.writeln('Successfully removed $targetLabel.');
    context.output.writeln('');
    context.output.writeln('Deleted:');
    for (final dir in directoriesToDelete) {
      context.output.writeln('- $dir');
    }
    for (final file in filesToDelete) {
      context.output.writeln('- $file');
    }

    final modified = unwiringChanges.where((c) => c.hasChanges).toList();
    if (modified.isNotEmpty) {
      context.output.writeln('');
      context.output.writeln('Unwired registrations in:');
      for (final change in modified) {
        final relPath = p.relative(change.filePath, from: rootDir.path);
        context.output.writeln('- $relPath');
      }
    }

    if (!keepL10n && totalPrunedKeys > 0) {
      context.output.writeln('');
      context.output.writeln(
        'Pruned $totalPrunedKeys localization keys prefixed with "$targetPrefix".',
      );
    }

    context.output.writeln('');
    context.output.writeln('Next steps:');
    if (!keepL10n && totalPrunedKeys > 0) {
      context.output.writeln('- Regenerate localization: fvm flutter gen-l10n');
    }
    context.output.writeln('- Format code: fvm dart format .');
    context.output.writeln(
      '- Verify codebase: dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev',
    );

    return 0;
  }
}

bool _isValidSnakeCase(String value) {
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  if (!regex.hasMatch(value)) return false;
  if (value.contains('__')) return false;
  if (value.endsWith('_')) return false;
  return true;
}

String _toCamelCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final first = parts.first;
  final rest = parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1));
  return [first, ...rest].join();
}
