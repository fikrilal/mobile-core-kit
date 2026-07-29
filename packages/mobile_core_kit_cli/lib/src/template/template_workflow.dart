import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/template/template_customization_engine.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

typedef TemplateInputReader = String? Function();

enum TemplateLifecycleCommand {
  init,
  customize;

  String get label => name;
}

class TemplateLifecycleWorkflow {
  TemplateLifecycleWorkflow(this.context, {TemplateInputReader? inputReader})
    : _inputReader = inputReader ?? (() => stdin.readLineSync());

  final WorkflowContext context;
  final TemplateInputReader _inputReader;

  static void writeUsage(StringSink output, TemplateLifecycleCommand command) {
    output.writeln('Usage: mobilekit ' + command.label + ' [options]');
    output.writeln();
    output.writeln('Options:');
    output.writeln(
      '  --config <path>  Read customization values from a YAML file.',
    );
    output.writeln(
      '  --dry-run        Print the manifest plan without writing files.',
    );
    output.writeln(
      '  --yes, -y        Apply without the final confirmation prompt.',
    );
    output.writeln();
    output.writeln(
      'Without --config, values are collected interactively. '
      'API endpoints and OIDC client IDs are not requested.',
    );
  }

  Future<int> run(TemplateLifecycleCommand command, List<String> argv) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('config')
      ..addFlag('dry-run', negatable: false)
      ..addFlag('yes', abbr: 'y', negatable: false);

    final args = parser.parse(argv);
    if (args.flag('help')) {
      writeUsage(context.output, command);
      return 0;
    }
    if (args.rest.isNotEmpty) {
      throw FormatException('Unexpected argument "' + args.rest.first + '".');
    }

    final marker = _readMarker();
    if (marker == null) return 1;

    final manifestFile = context.file(projectManifestRelativePath);
    final TemplateManifest? existingManifest;
    try {
      existingManifest = _readExistingManifest(manifestFile);
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ' + error.message);
      return 1;
    }
    if (existingManifest == null &&
        command == TemplateLifecycleCommand.customize &&
        args.option('config') == null) {
      context.errorOutput.writeln(
        'ERROR: No project manifest found. Run mobilekit init first.',
      );
      return 1;
    }

    final customization = _readCustomization(
      configPath: args.option('config'),
      existing: existingManifest?.customization,
    );
    if (customization == null) return 1;

    final manifest = TemplateManifest.forMarker(
      marker: marker,
      customization: customization,
      managedFileFingerprints:
          existingManifest?.managedFileFingerprints ?? const {},
    );
    final engine = TemplateCustomizationEngine(
      rootDirectory: context.rootDirectory,
      existingManifest: existingManifest,
      nextManifest: manifest,
    );
    final customizationPlan = engine.buildPlan();
    final plan = customizationPlan.summary;
    _writePlan(command, manifest, customizationPlan);

    if (args.flag('dry-run')) {
      context.output.writeln('Dry run: no files were changed.');
      return TemplateLifecycleResult(
        plan: plan,
        outcome: TemplateLifecycleOutcome.dryRun,
      ).exitCode;
    }

    if (plan.hasConflicts) {
      context.errorOutput.writeln(
        'ERROR: The customization plan contains conflicts.',
      );
      return TemplateLifecycleResult(
        plan: plan,
        outcome: TemplateLifecycleOutcome.failed,
      ).exitCode;
    }

    if (!plan.hasChanges) {
      context.output.writeln('No manifest changes needed.');
      return TemplateLifecycleResult(
        plan: plan,
        outcome: TemplateLifecycleOutcome.skipped,
      ).exitCode;
    }

    if (!args.flag('yes') && !_confirm()) {
      context.output.writeln('No changes applied.');
      return TemplateLifecycleResult(
        plan: plan,
        outcome: TemplateLifecycleOutcome.skipped,
      ).exitCode;
    }

    final applyResult = engine.apply(customizationPlan);
    if (!applyResult.succeeded) {
      context.errorOutput.writeln(
        'ERROR: ' + (applyResult.message ?? 'Customization was not applied.'),
      );
      return applyResult.exitCode;
    }
    context.output.writeln('Wrote ' + projectManifestRelativePath + '.');
    context.output.writeln(
      'Managed application package, branding, metadata, and documentation '
      'changes were applied.',
    );
    return TemplateLifecycleResult(
      plan: plan,
      outcome: TemplateLifecycleOutcome.applied,
    ).exitCode;
  }

  TemplateMarker? _readMarker() {
    try {
      return TemplateMarker.fromFile(context.file(templateMarkerRelativePath));
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ' + error.message);
      return null;
    }
  }

  TemplateManifest? _readExistingManifest(File file) {
    if (!file.existsSync()) return null;

    try {
      return TemplateManifest.fromFile(file);
    } on FormatException catch (error) {
      throw FormatException('Invalid project manifest: ' + error.message);
    }
  }

  TemplateCustomization? _readCustomization({
    required String? configPath,
    required TemplateCustomization? existing,
  }) {
    try {
      if (configPath != null) {
        final file = _resolveConfigFile(configPath);
        if (!file.existsSync()) {
          context.errorOutput.writeln(
            'ERROR: Customization config not found: ' + file.path,
          );
          return null;
        }
        return TemplateCustomization.fromYaml(file.readAsStringSync());
      }

      return _prompt(existing);
    } on FormatException catch (error) {
      context.errorOutput.writeln('ERROR: ' + error.message);
      return null;
    }
  }

  File _resolveConfigFile(String path) {
    if (p.isAbsolute(path)) return File(path);
    return context.file(path);
  }

  TemplateCustomization _prompt(TemplateCustomization? existing) {
    final slug = _directorySlug();
    final repositorySlug = _ask(
      'Repository slug',
      existing?.repositorySlug ?? slug,
    );
    final displayName = _ask(
      'App display name',
      existing?.displayName ?? 'Mobile Core Kit',
    );
    final dartPackage = _ask(
      'Dart package name',
      existing?.dartPackage ??
          TemplateCustomization.dartPackageForSlug(repositorySlug),
    );
    final androidNamespace = _ask(
      'Android namespace',
      existing?.androidNamespace ??
          TemplateCustomization.defaultAndroidNamespace,
    );
    final androidApplicationId = _ask(
      'Android application ID',
      existing?.androidApplicationId ??
          TemplateCustomization.defaultAndroidApplicationId,
    );
    final iosBundleId = _ask(
      'iOS bundle ID',
      existing?.iosBundleId ?? TemplateCustomization.defaultIosBundleId,
    );
    final deepLinkMode = DeepLinkMode.parse(
      _ask(
        'Deep-link mode (enabled/disabled)',
        existing?.deepLinkMode.wireValue ?? 'disabled',
      ),
    );
    final deepLinkHost = deepLinkMode == DeepLinkMode.enabled
        ? _ask('Deep-link host', existing?.deepLinkHost ?? '')
        : null;
    final firebaseMode = FirebaseMode.parse(
      _ask(
        'Firebase mode (configure/keep-demo/disabled)',
        existing?.firebaseMode.wireValue ?? 'configure',
      ),
    );

    return TemplateCustomization.fromValues(
      repositorySlug: repositorySlug,
      repositoryDescription: existing?.repositoryDescription ?? displayName,
      displayName: displayName,
      dartPackage: dartPackage,
      androidNamespace: androidNamespace,
      androidApplicationId: androidApplicationId,
      androidDevSuffix: existing?.androidDevSuffix ?? '.dev',
      androidStagingSuffix: existing?.androidStagingSuffix ?? '.staging',
      iosBundleId: iosBundleId,
      iosTestBundleId: existing?.iosTestBundleId,
      deepLinkMode: deepLinkMode,
      deepLinkHost: deepLinkHost,
      firebaseMode: firebaseMode,
      environmentExamplesUpdated: existing?.environmentExamplesUpdated ?? false,
    );
  }

  String _ask(String label, String defaultValue) {
    final prompt = defaultValue.isEmpty
        ? label + ': '
        : label + ' [' + defaultValue + ']: ';
    context.output.write(prompt);
    final input = _inputReader();
    if (input == null) {
      throw FormatException(
        'Interactive input ended while asking for ' +
            label +
            '. Use --config for non-interactive setup.',
      );
    }

    final value = input.trim();
    return value.isEmpty ? defaultValue : value;
  }

  bool _confirm() {
    context.output.write('Apply this manifest plan? [y/N]: ');
    final input = _inputReader();
    return input?.trim().toLowerCase() == 'y' ||
        input?.trim().toLowerCase() == 'yes';
  }

  String _directorySlug() {
    final basename = p.basename(
      p.normalize(context.rootDirectory.absolute.path),
    );
    final slug = basename
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? 'mobile-app' : slug;
  }

  void _writePlan(
    TemplateLifecycleCommand command,
    TemplateManifest manifest,
    TemplateCustomizationPlan customizationPlan,
  ) {
    final plan = customizationPlan.summary;
    final customization = manifest.customization;
    context.output.writeln('mobilekit ' + command.label + ' plan');
    context.output.writeln(
      '- repository slug: ' + customization.repositorySlug,
    );
    context.output.writeln('- app display name: ' + customization.displayName);
    context.output.writeln('- Dart package: ' + customization.dartPackage);
    context.output.writeln(
      '- Android application ID: ' + customization.androidApplicationId,
    );
    context.output.writeln('- iOS bundle ID: ' + customization.iosBundleId);
    context.output.writeln(
      '- deep-link mode: ' + customization.deepLinkMode.wireValue,
    );
    context.output.writeln(
      '- Android dev application ID: ' + customization.androidDevApplicationId,
    );
    context.output.writeln(
      '- Android staging application ID: ' +
          customization.androidStagingApplicationId,
    );
    context.output.writeln(
      '- Android production application ID: ' +
          customization.androidProductionApplicationId,
    );
    context.output.writeln(
      '- Firebase mode: ' + customization.firebaseMode.wireValue,
    );
    context.output.writeln('- changes:');
    for (final item in plan.items) {
      context.output.writeln(
        '  - ' +
            item.status.name +
            ': ' +
            item.target +
            ' — ' +
            item.description,
      );
    }
  }
}
